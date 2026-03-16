import Foundation
import _AuthenticationServices_SwiftUI
import FirebaseAuth
import FirebaseCore
import CryptoKit
import AuthenticationServices
import GoogleSignIn

// MARK: - AuthService
// Чистая логика аутентификации — без состояния UI, без @Published.
// Все методы бросают ошибки — SessionManager их ловит и выставляет алерт.

actor AuthService {

    // MARK: Nonce (Apple Sign In)
    // Храним внутри actor — безопасно без дополнительной синхронизации.

    // MARK: - Generic credential sign in

    func signIn(with credential: AuthCredential) async throws -> SessionUser {
        let result = try await Auth.auth().signIn(with: credential)
        return SessionUser(user: result.user)
    }

    // MARK: - Email / Password

    func signUp(email: String, password: String) async throws -> SessionUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return SessionUser(user: result.user)
    }

    func signIn(email: String, password: String) async throws -> SessionUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return SessionUser(user: result.user)
    }

    func sendPasswordReset(to email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Update credentials
    // Принимает текущие credentials явно — не берёт из состояния.

    func updateEmailOrPassword(
        currentEmail: String,
        currentPassword: String,
        newEmail: String?,
        newPassword: String?
    ) async throws {
        guard let user = Auth.auth().currentUser else { throw BPError.authError }

        let credential = EmailAuthProvider.credential(
            withEmail: currentEmail,
            password: currentPassword
        )
        try await user.reauthenticate(with: credential)

        if let newEmail, newEmail != currentEmail {
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        }
        if let newPassword, newPassword != currentPassword {
            try await user.updatePassword(to: newPassword)
        }
    }

    // MARK: - Apple Sign In
    // Nonce не хранится в actor — генерируется и возвращается вместе с request.
    // SessionManager держит его у себя (@MainActor, безопасно) и передаёт при signIn.

    nonisolated func makeAppleRequest() -> (request: ASAuthorizationAppleIDRequest, nonce: String) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = Self.generateNonce()
        request.nonce = Self.sha256(nonce)
        return (request, nonce)
    }

    func signInWithApple(
        result: Result<ASAuthorization, Error>,
        nonce: String
    ) async throws -> SessionUser {
        switch result {
        case .success(let auth):
            guard let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
                throw BPError.unableToComplete
            }
            let firebaseCredential = try Self.makeFirebaseCredential(
                from: appleCredential,
                nonce: nonce
            )
            return try await signIn(with: firebaseCredential)

        case .failure:
            throw BPError.unableToComplete
        }
    }

    private static func makeFirebaseCredential(
        from credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) throws -> AuthCredential {
        guard let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8)
        else { throw BPError.unableToComplete }

        return OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
    }

    // MARK: - Google Sign In

    @MainActor
    func signInWithGoogle() async throws -> SessionUser {
        let credential = try await makeGoogleCredential()
        // signIn(with:) — метод actor, переключаемся обратно
        return try await signIn(with: credential)
    }

    @MainActor
    private func makeGoogleCredential() async throws -> AuthCredential {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw BPError.unableToComplete
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let topVC = topViewController() else { throw BPError.invalidData }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw BPError.invalidData
        }
        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: signInResult.user.accessToken.tokenString
        )
    }

    // MARK: - Account Linking

    func link(with credential: AuthCredential) async throws {
        guard let user = Auth.auth().currentUser else { throw BPError.authError }
        try await user.link(with: credential)
    }

    func linkWithEmail(email: String, password: String) async throws {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await link(with: credential)
    }

    @MainActor
    func linkWithGoogle() async throws {
        let credential = try await makeGoogleCredential()
        try await link(with: credential)
    }

    func linkWithApple(result: ASAuthorizationResult, nonce: String) async throws {
        switch result {
        case .appleID(let credential):
            let firCred = try Self.makeFirebaseCredential(from: credential, nonce: nonce)
            try await link(with: firCred)
        default:
            throw BPError.unableToComplete
        }
    }

    // MARK: - User management

    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else { throw BPError.authError }
        try await user.delete()
    }

    nonisolated func signOut() throws {
        try Auth.auth().signOut()
    }

    func currentSessionUser() -> SessionUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return SessionUser(user: user)
    }

    // MARK: - Crypto helpers (static — не зависят от состояния actor)

    private static func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            fatalError("SecRandomCopyBytes failed: \(status)")
        }
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
