//
//  AuthViewManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.01.2024.
//

import Foundation

@MainActor
final class AuthViewManager: ObservableObject{
    
    @Published var email: String
    @Published var password: String
    
    init(email: String = "", password: String = "", isLogged: Bool = false) {
        self.email = email
        self.password = password
    }
    
    func  signInWithEmailAndPassword() async throws  {
        try await AuthenticationManager.shared.signIn(withEmail: email, password: password)
    }
    
    func signUpwithEmailAndPassword() async throws{
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
}
