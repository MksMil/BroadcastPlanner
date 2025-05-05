import Foundation
import FirebaseFirestore


struct UserDTO: Identifiable, Codable,BPDataProtocol {
    
    var id: String
    var lastUpdated: Date = .now
    
    var firstName : String = "empty first name"
    var lastName: String = "empty last name"
    var isOnline: Bool = false
    
    var phoneNumber: String = "1234567890"
    var email: String = "email"
    var homeAddress: String = "homeAddress"
    var specialization = [String]()
    
    var creationDate: Date = .now
    
    var leaveDate: Date = .now
    
    var ownedEventIds = [String]()
    var participatedEventIds = [String]()
    
    init(id: String = UUID().uuidString){
        self.id = id
    }

}





