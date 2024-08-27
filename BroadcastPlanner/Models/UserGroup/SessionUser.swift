// Data model for authenticated user

import Foundation
import FirebaseAuth
import Firebase

struct SessionUser {
    
    let id: String
    
    let displayName: String?
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
        self.startSessionDate = Date()
    }
}

extension SessionUser: Equatable{
    static func == (lhs: SessionUser, rhs: SessionUser) -> Bool {
        return lhs.id == rhs.id
    }
}
