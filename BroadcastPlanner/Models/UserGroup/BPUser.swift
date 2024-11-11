import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreData

struct BPUser: Identifiable, Codable,BPDataProtocol {
    
    var id: String
    
    var firstName : String = "empty first name"
    var lastName: String = "empty last name"
    var isOnline: Bool = false
    
    var phoneNumber: String = "1234567890"
    var email: String = "email"
    var homeAddress: String = "homeAddress"
    var specialization = [String]()
    
    var creationDate: Timestamp = Timestamp(date: Date())
    var creationDateConverted: Date {
        creationDate.dateValue()
    }
    var leaveDate: Timestamp = Timestamp(date: Date())
    var leaveDateConverted: Date {
        leaveDate.dateValue()
    }
    var ownedEventIds = [String]()
    var participatedEventIds = [String]()
    
    init(id: String = UUID().uuidString){
        self.id = id
    }
    
    func toLocalUser(user: LocalUser){
        user.firstName = firstName
        user.lastName = lastName
        user.isOnline = isOnline
        user.phoneNumber = phoneNumber
        user.email = email
        user.homeAddress = homeAddress
        user.specializations = specialization.joined(separator: ",")
        user.creationDate = creationDate.dateValue()
        user.leaveDate = leaveDate.dateValue()
    }
    
    static func makeBPUser(localUser: LocalUser) -> BPUser{
        var user = BPUser(id: localUser.userId)
        user.firstName = localUser.userFirstName
        user.lastName = localUser.userLastName
        user.email = localUser.userEmail
        user.phoneNumber = localUser.userPhoneNumber
        user.homeAddress = localUser.userAddress
        user.specialization = localUser.userSpecialization.map{ $0.rawValue}
        user.isOnline = true
        if let date = localUser.creationDate{
            user.creationDate = Timestamp(date: date )
        }
        if let date = localUser.leaveDate{
            user.leaveDate = Timestamp(date: date)
        }
        user.ownedEventIds = localUser.userOwnedEvents.compactMap{$0.id}
        user.participatedEventIds = localUser.userParticipatedEvents.compactMap{$0.id}
        
        return user
    }
}



//extension BPUser {
//    static func createUserFromData(data: [String: Any]) -> BPUser?{
//        guard let id = data["id"] as? String,
//        let firstName = data["firstNname"] as? String,
//        let lastName = data["lastName"] as? String,
//        let isOnline = data["isOnline"] as? Bool,
//        let phoneNumber = data["phoneNumber"] as? String,
//        let email = data["email"] as? String,
//        let homeAddress = data["homeAddress"] as? String,
//        let specialization = data["specialization"] as? [String],
//        let creationDate = data["creationDate"] as? Timestamp,
//        let leaveDate = data["leaveDate"] as? Timestamp,
//        let participetedEventIds = data["participatedEventIds"] as? [String],
//        let ownedEventIds = data["ownedEventIds"] as? [String]
//        else { return nil }
//        
//        var user = BPUser(id: id)
//        user.firstName = firstName
//        user.lastName = lastName
//        user.isOnline = isOnline
//        user.phoneNumber = phoneNumber
//        user.email = email
//        user.homeAddress = homeAddress
//        user.specialization = specialization
//        user.creationDate = creationDate
//        user.leaveDate = leaveDate
//        user.participatedEventIds = participetedEventIds
//        user.ownedEventIds = ownedEventIds
//        
//        return user
//    }
//}

 //MARK: - Hashable/Equatable
extension BPUser: Hashable, Equatable{
    //equatable conformance
    static func == (lhs: BPUser, rhs: BPUser) -> Bool {
        lhs.id == rhs.id
    }
    //hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - computed compactFullName
    
    
    
}




