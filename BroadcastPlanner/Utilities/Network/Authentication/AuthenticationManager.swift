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

final class AuthenticationManager {
    
    static let shared: AuthenticationManager = AuthenticationManager()
    
    
    private init(){}
    
    func getUser() throws -> AuthDataResultModel{
        guard let currentUser = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        return AuthDataResultModel(user: currentUser)
    }
    
    // MARK: - SU SI with Apple
    func signWithAppl(){
        
    }
    
    // MARK: - SU SI with Google
    
    func signWithGgl() async throws -> AuthDataResultModel{
        let credential = try await getGoogleCredential()
        return  try await signIn(credential: credential)
    }
    
    @MainActor func getGoogleCredential() async throws -> AuthCredential {
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
        print("\(UIApplication.shared.connectedScenes.count)")
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

// MARK: - SU SI with Email/Password
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel?{
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let currentUser = AuthDataResultModel(user: result.user)
        return currentUser
    }
    @discardableResult
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResultModel {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let currentUser = AuthDataResultModel(user: result.user)
        return currentUser
    }
    // MARK: change password
    func updatePass(pass: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: pass)
    }
    // MARK: change email
    func updateEmail(newEmail: String) async throws {
        try await Auth.auth().currentUser?.updateEmail(to: newEmail)
    }
    // MARK: forget password handler
    func forgetPass(){
        
    }
}


// MARK: - SI with Credential
extension AuthenticationManager {
    func signIn(credential: AuthCredential) async throws-> AuthDataResultModel{
        let result = try await Auth.auth().signIn(with: credential)
        let currentUser = AuthDataResultModel(user: result.user)
        return currentUser
    }
}
