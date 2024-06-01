//
//  AuthenticationManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.01.2024.
//

import AuthenticationServices
import Firebase
import GoogleSignIn
import FirebaseAuth
import _AuthenticationServices_SwiftUI


final class AuthenticationManager {
    
    static let shared: AuthenticationManager = AuthenticationManager()
    
    init(){
        
    }
    
    // MARK: - SU SI with Apple
    
    func signInWithAppleWithResult(_ result: Result<ASAuthorization,Error>, currentNonce: String) async throws -> SessionUser{
        switch result {
            case .success(let auth):
                switch auth.credential {
                    case let credential as ASAuthorizationAppleIDCredential:
                        let firCredential = try AppleHelper.makeCredentialFromAppleID(credential: credential, andNounce: currentNonce)
                        let currentUserSession = try await signIn(credential: firCredential)
                        return currentUserSession
                        
                    default:
                        print("DEBUG: Error in retrieving auth info")
                        throw BPError.unableToComplete
                }
            case .failure(let error):
                print("DEBUG: Sign in with Apple failed: \(error.localizedDescription)")
                throw BPError.unableToComplete
        }
    }
    
    // MARK: - SU SI with Google
    
    func signWithGgl() async throws -> SessionUser{
        let credential = try await getGoogleCredential()
        return  try await signIn(credential: credential)
    }
    
    //google credentials
    @MainActor
    func getGoogleCredential() async throws -> AuthCredential {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw BPError.unableToComplete }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topController = topViewController() else {
            throw BPError.invalidData
        }
        // Start the sign in flow!
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topController)
        
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw BPError.invalidData
        }
        
        let accesToken = signInResult.user.accessToken.tokenString
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken,
                                                        accessToken: accesToken)
        return credentials
    }
    

}

// MARK: - SU SI with Email/Password
extension AuthenticationManager {
    
    func createUser(email: String, password: String) async throws -> SessionUser?{
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let currentUserSession = SessionUser(user: result.user)
        return currentUserSession
    }
    
    func signIn(withEmail email: String, password: String) async throws -> SessionUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let currentUserSession = SessionUser(user: result.user)
        return currentUserSession
    }
    
    
    
    // MARK: change password
    func updatePass(pass: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: pass)
    }
    // MARK: change email
    func updateEmail(newEmail: String) async throws {
        //        try await Auth.auth().currentUser?.updateEmail(to: newEmail)
    }
    // MARK: forget password handler
    func sendResetPassword(with email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
                   if let error = error {
                       //show 'error received'
                       print("Error: \(error.localizedDescription)")
                   } else {
                       //show confirmation
                       print("Password reset email sent.")
                   }
               }
    }
    // MARK: - Delete user
    func deleteUser() async throws{
        guard let user = Auth.auth().currentUser else { throw BPError.authError }
        try await user.delete()
    }
    // MARK: - Log Out
    func logOut() throws{
        try Auth.auth().signOut()
    }
}


// MARK: - SI with Credential
extension AuthenticationManager {
    func signIn(credential: AuthCredential) async throws-> SessionUser{
        let result = try await Auth.auth().signIn(with: credential)
        let currentUserSession = SessionUser(user: result.user)
        return currentUserSession
    }
}

// MARK: - Linking account
extension AuthenticationManager {
    func linkWith(credential: AuthCredential){
        guard let user = Auth.auth().currentUser else { return }
        user.link(with: credential)
    }
    
    //link with e-mail
    func linkWithEmail(email: String, password: String) throws{
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        linkWith(credential: credential)
    }
    
    // link with Google
    func linkWithGoogle() async {
        do{
            let credential = try await getGoogleCredential()
            linkWith(credential: credential)
        } catch {
#if DEBUG
            print("DEBUG: Error linked google account: \(error.localizedDescription)")
#endif
        }
    }
    //link with Apple
    func linkWithApple(result: ASAuthorizationResult, currentNonce: String){
        switch result {
            case .appleID(let credential):
                do {
                    let firCred = try AppleHelper.makeCredentialFromAppleID(credential: credential, andNounce: currentNonce)
                    linkWith(credential: firCred)
                } catch {
#if DEBUG
                    print(error.localizedDescription)
#endif
                }
            default :
                print("another result type received")
        }
    }
}
