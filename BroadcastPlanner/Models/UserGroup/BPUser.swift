import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class BPUser: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    var firstName : String = ""
    var lastName: String = ""
    var isOnline: Bool = false
    
    var phoneNumber: String?
    var email: String?
    var homeAddress: String?
    var specialization = [String]()
    var photoURL: String?
    
    var creationDate: Date?
    var leaveDate: Timestamp?
    var leaveDateConverted: Date? {
        leaveDate?.dateValue()
    }
    var ownedEventIds = [String]()
    var memberEventIds = [String]()
    
    // TODO: Refactor reserved to [Events]
    var reserved: Bool = false


    // MARK: - Initialization
    init(authInfo: SessionUser){

        //fetch data from firebase and fill all fields
    }
 
    //just for test functionality
    init(id: String = UUID().uuidString,firstName: String = "Empty", lastName: String = "NoName",specialization: [String] = []){
        self.firstName = firstName
        self.lastName = lastName
        self.specialization = specialization
    }
    
    init(id: String,email: String, firstName: String, phNum: String, homeAddress: String, specialization: [UserSpecialization]){
        self.email = email
        self.firstName = firstName
        self.phoneNumber = phNum
        self.homeAddress = homeAddress
        self.specialization = specialization.map{$0.rawValue}
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
        self.leaveDate =  Timestamp(date: user.leaveDate ?? Date())
        
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




