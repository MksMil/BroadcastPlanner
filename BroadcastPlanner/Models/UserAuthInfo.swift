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
    
    let uid: String
    
    let email: String?
    
    let firstName: String?
    let secondName: String?
    let displayName: String?
    
    let phoneNumber: String?
    
    let creationDate: Date?
    let lastSignInDate: Date?
    let photoUrl: URL?
    
    //computed
    var fullName: String {
        (secondName ?? "") + " " + (firstName ?? "")
    }
    
    init(uid: String, email: String?, firstName: String?, secondName: String?, displayName: String?, phoneNumber: String?, creationDate: Date?, lastSignInDate: Date?, photoUrl: URL?) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.secondName = secondName
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.photoUrl = photoUrl
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.firstName = ""
        self.secondName = ""
        self.displayName = user.displayName
        self.phoneNumber = user.phoneNumber
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
        self.photoUrl = user.photoURL
    }
}
