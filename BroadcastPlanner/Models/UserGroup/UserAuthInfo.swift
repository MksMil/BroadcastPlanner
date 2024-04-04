//
//  AuthDataResultModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 17.01.2024.
//
// Data model for authenticated user

import Foundation
import FirebaseAuth
import Firebase

struct UserAuthInfo {
    
    let id: String
    let email: String?

    let displayName: String?
    
    let phoneNumber: String?
    
    let creationDate: Date?
    let lastSignInDate: Date?
    
    let photoUrl: URL?
    
    
    init(id: String, email: String? = nil,  displayName: String? = nil, phoneNumber: String? = nil, creationDate: Date? = nil, lastSignInDate: Date? = nil, photoUrl: URL? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.photoUrl = photoUrl
    }
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email ?? ""
        self.displayName = user.displayName ?? ""
        self.phoneNumber = user.phoneNumber ?? ""
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate ?? Date()
        self.photoUrl = user.photoURL
    }
}

