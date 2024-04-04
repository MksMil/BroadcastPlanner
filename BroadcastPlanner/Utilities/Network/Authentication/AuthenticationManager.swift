//
//  AuthenticationManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.01.2024.
//

import AuthenticationServices
import CryptoKit
import Firebase
import GoogleSignIn
import UIKit
import FirebaseAuth


protocol BPAuthProvider {
    
    //    func createUser() throws
    //
    //    func signUp() throws
    //    func logIn() throws
    //    func logOut() throws
    //
    //    func deleteUser() throws
}

enum BPOuterStorage{
    case firebase
    //for more storage options
}

final class AuthenticationManager: BPAuthProvider {
    
    static let shared: AuthenticationManager = AuthenticationManager()
    
    private init(){}
    
    func getUser() -> UserAuthInfo?{
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return UserAuthInfo(user: currentUser)
    }
    
    func deleteUser() async throws{
        guard let user = Auth.auth().currentUser else { throw BPError.authError }
        try await user.delete()
    }
    
    // MARK: - SU SI with Apple
    
    func signInWithAppleWithResult(_ result: Result<ASAuthorization,Error>, currentNonce: String) async throws -> UserAuthInfo{
        switch result {
        case .success(let auth):
            switch auth.credential {
            case let credential as ASAuthorizationAppleIDCredential:
                
                guard let appleIDToken = credential.identityToken else {  throw BPError.unableToComplete }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw BPError.unableToComplete }
                
                let credential = OAuthProvider.appleCredential(
                    withIDToken: idTokenString,
                    rawNonce: currentNonce,
                    fullName: credential.fullName
                )
                
                let currentUser = try await signIn(credential: credential)
                return currentUser

            default:
                print("Error in retrieving auth info")
                throw BPError.unableToComplete
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
            throw BPError.unableToComplete
        }
    }
    
    func getRandomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    func getSha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func linkWithApple(credential: AuthCredential){
        guard let user = Auth.auth().currentUser else { return }
        user.link(with: credential)
    }
    
    // MARK: - SU SI with Google
    
    func signWithGgl() async throws -> UserAuthInfo{
        let credential = try await getGoogleCredential()
        return  try await signIn(credential: credential)
    }
    
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
    
    func linkWithGoogle() async {
        guard let user = Auth.auth().currentUser else { return }
        do{
            let credential = try await getGoogleCredential()
            try await user.link(with: credential)
        } catch {
            print("Error linked google account: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Log Out
    func logOut() throws{
        try Auth.auth().signOut()
    }
}

// MARK: - SU SI with Email/Password
extension AuthenticationManager {
    
    func createUser(email: String, password: String) async throws -> UserAuthInfo?{
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let currentUser = UserAuthInfo(user: result.user)
        return currentUser
    }
    
    func signIn(withEmail email: String, password: String) async throws -> UserAuthInfo {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let currentUser = UserAuthInfo(user: result.user)
        return currentUser
    }
    
    //link with e-mail
    func linkWithEmail(email: String, password: String) throws{
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        guard let user = Auth.auth().currentUser else { throw BPError.authError }
        user.link(with: credential)
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
    func forgetPass(){
        
    }
}


// MARK: - SI with Credential
extension AuthenticationManager {
    func signIn(credential: AuthCredential) async throws-> UserAuthInfo{
        let result = try await Auth.auth().signIn(with: credential)
        let currentUser = UserAuthInfo(user: result.user)
        return currentUser
    }
}
