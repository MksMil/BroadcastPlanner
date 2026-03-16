import Foundation
import _AuthenticationServices_SwiftUI
import FirebaseAuth
import AuthenticationServices


// MARK: - SessionManager
// Фасад: владеет AuthService, публикует состояние UI, ловит все ошибки.
// Форм-поля (email/password) вынесены — SessionManager не хранит пароль в памяти.

@MainActor
final class SessionManager: ObservableObject {

    // MARK: Published state

    @Published var sessionUser: SessionUser?
    @Published var alertItem: AlertItem?
    @Published var isLoading: Bool = false

    // MARK: Private

    private let authService = AuthService()

    // MARK: - Init / restore session

    func restoreSession() async {
        sessionUser = await authService.currentSessionUser()
    }

    // MARK: - Email / Password

    func signUp(email: String, password: String) async {
        await perform {
            try await self.authService.signUp(email: email, password: password)
        }
    }

    func signIn(email: String, password: String) async {
        await perform {
            try await self.authService.signIn(email: email, password: password)
        }
    }

    func sendPasswordReset(to email: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.sendPasswordReset(to: email)
            alertItem = .passwordResetSent
        } catch {
            alertItem = .from(error)
        }
    }

    // MARK: - Update credentials

    func updateEmailOrPassword(
        currentEmail: String,
        currentPassword: String,
        newEmail: String? = nil,
        newPassword: String? = nil
    ) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.updateEmailOrPassword(
                currentEmail: currentEmail,
                currentPassword: currentPassword,
                newEmail: newEmail,
                newPassword: newPassword
            )
            if newEmail != nil { alertItem = .emailVerificationSent }
        } catch {
            alertItem = .from(error)
        }
    }

    // MARK: - Apple Sign In

    // nonce живёт здесь (@MainActor) — генерируется синхронно вместе с request,
    // передаётся в signInWithApple. Actor AuthService nonce не хранит.
    private var appleNonce: String = ""

    // nonisolated в AuthService — вызывается синхронно из @MainActor контекста View.
    func makeAppleRequestSync() -> ASAuthorizationAppleIDRequest {
        let (request, nonce) = authService.makeAppleRequest()
        appleNonce = nonce
        return request
    }

    func signInWithApple(result: Result<ASAuthorization, Error>) async {
        await perform {
            try await self.authService.signInWithApple(result: result, nonce: self.appleNonce)
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle() async {
        await perform {
            try await self.authService.signInWithGoogle()
        }
    }

    // MARK: - User management

    func logOut() {
        do {
            try authService.signOut()
            sessionUser = nil
        } catch {
            alertItem = .from(error)
        }
    }

    func deleteUser() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.deleteUser()
            sessionUser = nil
            alertItem = .accountDeleted
        } catch {
            alertItem = .from(error)
        }
    }

    // MARK: - Account Linking

    func linkWithEmail(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.linkWithEmail(email: email, password: password)
        } catch {
            alertItem = .from(error)
        }
    }

    func linkWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.linkWithGoogle()
        } catch {
            alertItem = .from(error)
        }
    }

    func linkWithApple(result: ASAuthorizationResult) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.linkWithApple(result: result, nonce: appleNonce)
        } catch {
            alertItem = .from(error)
        }
    }

    // MARK: - Private helper
    // Центральный обработчик: выставляет isLoading, ловит ошибки, обновляет sessionUser.

    private func perform(_ action: () async throws -> SessionUser) async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessionUser = try await action()
        } catch {
            alertItem = .from(error)
        }
    }
}

// MARK: - SwiftUI Usage Example
//
// struct SomeView: View {
//     @EnvironmentObject var session: SessionManager
//
//     var body: some View {
//         Button("Sign In") {
//             Task { await session.signIn(email: email, password: password) }
//         }
//         .disabled(session.isLoading)
//         .alert(item: $session.alertItem) { alert in
//             Alert(title: Text(alert.title), message: Text(alert.message))
//         }
//     }
// }
