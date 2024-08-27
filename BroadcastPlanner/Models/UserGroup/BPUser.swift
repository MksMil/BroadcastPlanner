import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class BPUser: Identifiable, Codable {
    
    var id: String?
    
    var firstName : String = "empty first name"
    var lastName: String = "empty last name"
    var isOnline: Bool = false
    
    var phoneNumber: String = "1234567890"
    var email: String = ""
    var homeAddress: String = "homeAddress"
    var specialization = [String]()
    
    var creationDate: Date = Date()
    var leaveDate: Timestamp = Timestamp(date: Date())
    var leaveDateConverted: Date {
        leaveDate.dateValue()
    }
    var ownedEventIds = [String]()
    var memberEventIds = [String]()
    
    init(){
        
    }
    
   required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.isOnline = try container.decode(Bool.self, forKey: .isOnline)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.email = try container.decode(String.self, forKey: .email)
        self.homeAddress = try container.decode(String.self, forKey: .homeAddress)
        self.specialization = try container.decode([String].self, forKey: .specialization)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.leaveDate = try container.decode(Timestamp.self, forKey: .leaveDate)
        self.ownedEventIds = try container.decode([String].self, forKey: .ownedEventIds)
        self.memberEventIds = try container.decode([String].self, forKey: .memberEventIds)
    }
}

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
    var fullCompactName: String {
        firstName.prefix(1) + "." + lastName
    }
}




