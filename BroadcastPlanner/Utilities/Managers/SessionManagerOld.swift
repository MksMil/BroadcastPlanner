//import Foundation
//import FirebaseAuth
//import CryptoKit
//
//import AuthenticationServices
//import FirebaseCore
//import GoogleSignIn
//import _AuthenticationServices_SwiftUI
//
////object for manage authentication and session information
//
//@MainActor
//final class SessionManager: ObservableObject{
//    
//    @Published var sessionUser: SessionUser?
//    
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var confirmPassword: String = ""
//    
//    var appleCurrentNonce: String = ""
//    
//    func getUserSession() async {
//        guard let currentUser = Auth.auth().currentUser else {
//            sessionUser = nil
//            return }
//        sessionUser = SessionUser(user: currentUser)
//        email = sessionUser?.email ?? "invalid data"
//        //TODO: fix with UserDefaults or smthng
//        password = "123456"
//    }
//    
//    func cleanFields(){
//        email = ""
//        password = ""
//    }
//}
//// MARK: - with Credential
//extension SessionManager {
//    func signIn(credential: AuthCredential) async throws-> SessionUser{
//        let result = try await Auth.auth().signIn(with: credential)
//        let currentUserSession = SessionUser(user: result.user)
//        return currentUserSession
//    }
//}
//
//// MARK: - with Apple
//extension SessionManager{
//    
//    @MainActor
//    func signInWithAppleWithResult(_ result: Result<ASAuthorization,Error>) async throws{
//        switch result {
//            case .success(let auth):
//                switch auth.credential {
//                    case let credential as ASAuthorizationAppleIDCredential:
//                        let credential = try makeCredentialFromAppleID(credential: credential)
//                        sessionUser = try await signIn(credential: credential)
//                    default:
//                        print("DEBUG: Error in retrieving auth info")
//                        throw BPError.unableToComplete
//                }
//            case .failure(let error):
//                print("DEBUG: Sign in with Apple failed: \(error.localizedDescription)")
//                throw BPError.unableToComplete
//        }
//    }
//    
//    func makeCredentialFromAppleID(credential: ASAuthorizationAppleIDCredential) throws-> AuthCredential{
//        guard let appleIDToken = credential.identityToken else {  throw BPError.unableToComplete }
//        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw BPError.unableToComplete }
//        
//        let newCredential = OAuthProvider.appleCredential(
//            withIDToken: idTokenString,
//            rawNonce: appleCurrentNonce,
//            fullName: credential.fullName
//        )
//        return newCredential
//    }
//    
//    //Request
//    @MainActor func makeRequest() -> ASAuthorizationAppleIDRequest{
//        let provider = ASAuthorizationAppleIDProvider()
//        let request = provider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        getRandomNonceString()
//        request.nonce = getSha256()
//        return request
//    }
//    
//    // MARK: Crypto part
//    func getRandomNonceString(length: Int = 32) {
//        precondition(length > 0)
//        var randomBytes = [UInt8](repeating: 0, count: length)
//        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
//        if errorCode != errSecSuccess {
//            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//        }
//        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        let nonce = randomBytes.map { byte in
//            // Pick a random character from the set, wrapping around if needed.
//            charset[Int(byte) % charset.count]
//        }
//        appleCurrentNonce = String(nonce)
//    }
//    
//    func getSha256() -> String {
//        let inputData = Data(appleCurrentNonce.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap {
//            String(format: "%02x", $0)
//        }.joined()
//        return hashString
//    }
//}
//
//// MARK: - with Google
//extension SessionManager {
//    @MainActor
//    func signInWithGoogle() async {
//        do{
//            let credential = try await getGoogleCredential()
//            sessionUser = try await signIn(credential: credential)
//        } catch {
//            //alert?
//#if DEBUG
//            print("DEBUG: GlobalSessopnStorage/func signInWithGoogle/ - sign in with google failed: \(error)")
//#endif
//        }
//    }
//    
//    //MARK: - Google credentials
//    @MainActor
//    func getGoogleCredential() async throws -> AuthCredential {
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//            throw BPError.unableToComplete }
//        
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        
//        guard let topController = topViewController() else {
//            throw BPError.invalidData
//        }
//        // Start the sign in flow!
//        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topController)
//        
//        guard let idToken = signInResult.user.idToken?.tokenString else {
//            throw BPError.invalidData
//        }
//        
//        let accesToken = signInResult.user.accessToken.tokenString
//        let credentials = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                        accessToken: accesToken)
//        return credentials
//    }
//}
//
//// MARK: - with Email/Password
//extension SessionManager {
//    
//    @MainActor
//    func signUp()async{
//        do{
//            let result = try await Auth.auth().createUser(withEmail: email,
//                                                          password: password)
//            sessionUser = SessionUser(user: result.user)
//        } catch {
//            //alert?
//#if DEBUG
//            print("DEBUG: SessionManager:/func signUp/ - member creation failed: \(error)")
//#endif
//        }
//    }
//    
//    @MainActor
//    func signInWithEmailAndPassword() async {
//        do {
//            let result = try await Auth.auth().signIn(withEmail: email,
//                                                      password: password)
//            sessionUser = SessionUser(user: result.user)
//        } catch {
//            //alert?
//#if DEBUG
//            print("DEBUG:GlobalSession/func signInWithEmailAndPassword failed: \(error)")
//#endif
//        }
//    }
//}
//
//// MARK: - User Managment
//extension SessionManager{
//    // MARK: Delete member
//    func deleteUser() async throws{
//        guard let user = Auth.auth().currentUser else { throw BPError.authError }
//        try await user.delete()
//        sessionUser = nil
//    }
//    // MARK: Log Out
//    func logOut() throws{
//        try Auth.auth().signOut()
//        sessionUser = nil
//    }
//    // MARK: Update password email
//    //TODO: fix
//    func updateEmailOrPassword(newEmailValue: String, newPasswordValue: String) async{
//        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email,
//                                                                      password: password)
//        if let user = Auth.auth().currentUser{
//            do{
//                let _ = try await user.reauthenticate(with: credential)
//                if newEmailValue != email{
//                    print("email verification started with \(newEmailValue)")
//                    try await user.sendEmailVerification(beforeUpdatingEmail: newEmailValue)
//                }
//                if newPasswordValue != password{
//                    print("password changed to \(newPasswordValue)")
//                    try await user.updatePassword(to: newPasswordValue)
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//}
//    // MARK: forget password handler
//    func sendResetPassword(with email: String){
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            if let error = error {
//                //show 'error received'
//                print("Error: \(error.localizedDescription)")
//            } else {
//                //show confirmation
//                print("Password reset email sent.")
//            }
//        }
//    }
//}
//
//// MARK: - Linking account
//extension SessionManager {
//    func linkWith(credential: AuthCredential){
//        guard let user = Auth.auth().currentUser else { return }
//        user.link(with: credential)
//    }
//    
//    // MARK: link with e-mail
//    func linkWithEmail(email: String, password: String) throws{
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        linkWith(credential: credential)
//    }
//    
//    // MARK: link with Google
//    func linkWithGoogle() async {
//        do{
//            let credential = try await getGoogleCredential()
//            linkWith(credential: credential)
//        } catch {
//#if DEBUG
//            print("DEBUG: Error linked google account: \(error.localizedDescription)")
//#endif
//        }
//    }
//    //MARK: link with Apple
//    func linkWithApple(result: ASAuthorizationResult){
//        switch result {
//            case .appleID(let credential):
//                do {
//                    let firCred = try makeCredentialFromAppleID(credential: credential)
//                    linkWith(credential: firCred)
//                } catch {
//#if DEBUG
//                    print(error.localizedDescription)
//#endif
//                }
//            default :
//                print("another result type received")
//        }
//    }
//}
//
