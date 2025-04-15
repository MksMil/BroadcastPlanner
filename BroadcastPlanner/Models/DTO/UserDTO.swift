import SwiftUI
import FirebaseFirestore
import CoreData

struct UserDTO: Identifiable, Codable,BPDataProtocol {
    
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

}





