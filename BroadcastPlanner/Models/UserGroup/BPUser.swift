import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class BPUser: Identifiable, Codable {
    
    @DocumentID var id: String?
    var uid: String
    
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
    var ownedEvents = [Event]()
    var memberEvents = [Event]()
    
    
    //fetched after load
//    var image: Image = Image(systemName: "person.crop.circle")
    
    // TODO: Refactor reserved to [Events]
    var reserved: Bool = false


    // MARK: - Initialization
    init(authInfo: SessionUser){
        self.uid = authInfo.id
        //fetch data from firebase and fill all fields
    }
 
    //just for test functionality
    init(id: String = UUID().uuidString,name: String = "Empty"){
        self.firstName = name
        self.uid = id
    }
    
    init(id: String,email: String, firstName: String, phNum: String, homeAddress: String, specialization: [UserSpecialization]){
        self.uid = id
        self.email = email
        self.firstName = firstName
        self.phoneNumber = phNum
        self.homeAddress = homeAddress
        self.specialization = specialization.map{$0.rawValue}
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
}




