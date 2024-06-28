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

struct SessionUser {
    
    let id: String
    
    let displayName: String?
    let photoUrl: URL?
    let email: String?
    let phoneNumber: String?

    let creationDate: Date?
    let lastSignInDate: Date?
    let startSessionDate: Date?
    //computed properties
    var firstName: String {
        guard let displayName else { return "emptyFirstName"}
        let firstName = displayName.prefix { $0 != " " }
        return String(firstName)
    }
    
    var lastName: String {
        guard let displayName else { return "emptyLastName"}
        return String(displayName.trimmingPrefix { $0 != " " }.trimmingPrefix{ $0 == " "})
    }
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.phoneNumber = user.phoneNumber
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
        self.photoUrl = user.photoURL
        self.startSessionDate = Date()
    }
}

// MARK: - for TDD init version
//extension SessionUser {
//    init(id: String = UUID().uuidString, email: String? = nil,  displayName: String? = nil, phoneNumber: String? = nil, creationDate: Date? = nil, lastSignInDate: Date? = nil, photoUrl: URL? = nil) {
//        self.id = id
//        self.email = email
//        self.displayName = displayName
//        self.phoneNumber = phoneNumber
//        self.creationDate = creationDate
//        self.lastSignInDate = lastSignInDate
//        self.photoUrl = photoUrl
//    }
//}

extension SessionUser: Equatable{
    static func == (lhs: SessionUser, rhs: SessionUser) -> Bool {
        return lhs.id == rhs.id
    }
}
