//
//  AuthenticationManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.01.2024.
//

import Foundation
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import UIKit
import CryptoKit
import AuthenticationServices


protocol BPAuthProvider {
    
    //    func createUser() throws
    //
    //    func logIn() throws
    //    func logOut() throws
    //
    //    func deleteUser() throws
}

enum BPOuterStorage{
    case firebase
    //for more storage options
}


/**
 To sign in users using Apple, first configure Sign In with Apple on Apple's developer site, then enable Apple as a sign-in provider for your Firebase project.
 To authenticate with an Apple account, first sign the user in to their Apple account using Apple's AuthenticationServices framework,
 and then use the ID token from Apple's response to create a Firebase AuthCredential object.
 */

final class AuthenticationManager: BPAuthProvider {
    
    static let shared: AuthenticationManager = AuthenticationManager()
    
    private init(){}
    
    func getUser() throws -> UserAuthInfo{
        guard let currentUser = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        return UserAuthInfo(user: currentUser)
    }
    
    // MARK: - SU SI with Apple
    func signWithAppl() async throws -> UserAuthInfo{
        let credential = try await getAppleCredential()
        let currentUser = try await signIn(credential: credential)
        return currentUser
    }
    @MainActor
    func getAppleCredential() async throws -> AuthCredential{
        // TODO: Implement apple credential generating
        
        //temporary credential placeholder
        let credential = OAuthProvider.appleCredential(withIDToken: "", rawNonce: "", fullName: PersonNameComponents())
        //
        
        return credential
    }
    
    func handleResult(_ result: Result<ASAuthorization,Error>, currentNonce: String) async throws -> UserAuthInfo{
        switch result {
        case .success(let auth):
            switch auth.credential {
            case let credential as ASAuthorizationAppleIDCredential:
                
                guard let appleIDToken = credential.identityToken else {  throw BPError.unableToComplete }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw BPError.unableToComplete }
                
                // Initialize a Firebase credential, including the user's full name.
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
            // TODO: make throwing custom error, not fatal error
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
    // MARK: - Log Out
    func logOut() throws{
        try Auth.auth().signOut()
    }
    
    // MARK: - UIApplication: TopViewController
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        
        guard let rootviewcontroller = windowScene.windows.first?.rootViewController else { return nil}
        
        if let navigationController = rootviewcontroller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = rootviewcontroller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = rootviewcontroller.presentedViewController {
            return topViewController(controller: presented)
        }
        return rootviewcontroller
    }
    
}

// MARK: - SU SI with Email/Password
extension AuthenticationManager {
    //    @discardableResult
    func createUser(email: String, password: String) async throws -> UserAuthInfo?{
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let currentUser = UserAuthInfo(user: result.user)
        return currentUser
    }
    //    @discardableResult
    func signIn(withEmail email: String, password: String) async throws -> UserAuthInfo {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let currentUser = UserAuthInfo(user: result.user)
        return currentUser
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
