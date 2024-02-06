//
//  AuthenticationManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.01.2024.
//

import Foundation
import FirebaseAuth

final class AuthenticationManager {
    
    static let shared: AuthenticationManager = AuthenticationManager()
    
    
    private init(){}
    
    func getUser() throws -> AuthDataResultModel{
        guard let currentUser = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        return AuthDataResultModel(user: currentUser)
    }
    
    // MARK: - SU SI with Email/Password
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
    
    // MARK: - SU SI with Apple
    func signWithAppl(){
        
    }
    
    // MARK: - SU SI with Google
    
    func signWithGgl(){
        
    }
    // MARK: - Log Out
    func logOut() throws{
        try Auth.auth().signOut()
    }
    
    // MARK: - forget password handler
    func forgetPass(){

    }
    
    // MARK: - change password
    
    func updatePass(pass: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: pass)
    }
    
    // MARK: - change email
    func updateEmail(newEmail: String) async throws {
        try await Auth.auth().currentUser?.updateEmail(to: newEmail)
    }
}
