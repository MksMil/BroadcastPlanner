import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class BPUser: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    var firstName : String = "empty first name"
    var lastName: String = "empty last name"
    var isOnline: Bool = false
    
    var phoneNumber: String = "1234567890"
    var email: String = ""
    var homeAddress: String = "homeAddress"
    var specialization = [String]()
    var photoURL: String = ""
    
    var creationDate: Date = Date()
    var leaveDate: Timestamp = Timestamp(date: Date())
    var leaveDateConverted: Date {
        leaveDate.dateValue()
    }
    var ownedEventIds = [String]()
    var memberEventIds = [String]()
    
    // TODO: Refactor reserved to [Events]
//    var reserved: Bool = false


    // MARK: - Initialization
//    init(authInfo: SessionUser){
//
//        //fetch data from firebase and fill all fields
//    }
 
    //just for test functionality
//    init(id: String = UUID().uuidString,firstName: String = "Empty", lastName: String = "NoName",specialization: [String] = []){
//        self.firstName = firstName
//        self.lastName = lastName
//        self.specialization = specialization
//    }
//    
//    init(email: String, firstName: String, phNum: String, homeAddress: String, specialization: [UserSpecialization]){
//        self.email = email
//        self.firstName = firstName
//        self.phoneNumber = phNum
//        self.homeAddress = homeAddress
//        self.specialization = specialization.map{$0.rawValue}
//    }
    
    init(){
        
    }
    
   required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.isOnline = try container.decode(Bool.self, forKey: .isOnline)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.email = try container.decode(String.self, forKey: .email)
        self.homeAddress = try container.decode(String.self, forKey: .homeAddress)
        self.specialization = try container.decode([String].self, forKey: .specialization)
        self.photoURL = try container.decode(String.self, forKey: .photoURL)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.leaveDate = try container.decode(Timestamp.self, forKey: .leaveDate)
        self.ownedEventIds = try container.decode([String].self, forKey: .ownedEventIds)
        self.memberEventIds = try container.decode([String].self, forKey: .memberEventIds)
    }
    
    init(user: BPUserLocalData){
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.isOnline = user.isOnline
        self.phoneNumber = user.phoneNumber
        self.email = user.email
        self.homeAddress = user.homeAddress
        self.specialization =  user.specialization
        self.photoURL = user.photoURL
        
        self.creationDate = user.creationDate
        self.leaveDate =  Timestamp(date: user.leaveDate)
        
        self.ownedEventIds = user.ownedEventIds
        self.memberEventIds = user.memberEventIds
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




