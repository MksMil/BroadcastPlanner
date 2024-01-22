//
//  AuthDataResultModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 17.01.2024.
//
// Data model for authenticated user

import Foundation
//import Firebase
import FirebaseAuth

struct AuthDataResultModel {
    
    let uid: String
    let email: String?
    
    init(user:FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email
    }
}
