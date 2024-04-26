import SwiftUI
import FirebaseFirestore

class BPUser:  ObservableObject, Identifiable, Decodable {
    
    @Published var name : String = ""
    
    var id: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var homeAddress: String = ""
    var creationDate: Date = Date()
    var lastDate: Date = Date()
    
    var ownedEvents = Set<Event>()
    var memberEvents = Set<Event>()
    
    var specialization = Set<UserSpecialization>()
    
    var photoURL: String?
    @Published var image: Image = Image(systemName: "person.crop.circle")
    @Published var reserved: Bool = false


    init(authInfo: UserAuthInfo){
        self.id = authInfo.id
        //fetch data from firebase and fill all fields
    }
 
    //just for test functionality
    init(name: String = "Empty"){
        self.name = name
        self.id = name
    }
    
    init(id: String,email: String, firstName: String, creationDate: Date){
        self.id = id
        self.email = email
        self.name = firstName
        self.creationDate = creationDate
    }
    required init(from decoder: Decoder) throws {
        
    }
    
}

// MARK: - Hashable/Equatable
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

// MARK: - Temporary backup from deleted class UserManager. All user based logic must be in user class
extension BPUser {
    // MARK: - Create User
    func saveUser(user: BPUser?)async throws{
        guard let user else { throw BPError.authError }
        let savedData: [String: Any] = ["user_id":user.id,
                                        "user_name":user.name,
                                        "uaer_email":user.email,
                                        "date_created": Timestamp()]
        
        
        try await Firestore.firestore().collection("users").document(user.id).setData(savedData)
    }
    
    // MARK: - Get User
    func getUser(id: String) async throws-> BPUser {
        
        let snapshot = try await Firestore.firestore().collection("users").document(id).getDocument()
        guard let data = snapshot.data(), let userId = data["user_id"] as? String  else { throw BPError.invalidData }
        
        let userName = data["user_name"] as? String ?? "empty name"
        let userEmail = data["user_email"] as? String ?? "empty email"
        let creationDate = data["date_created"] as? Date ?? Date()
        
        let loadedUser = BPUser(id: userId,
                                email: userEmail,
                                firstName: userName,
                                creationDate: creationDate)
        return loadedUser
    }
}

// MARK: - Events managment
extension BPUser {
    func addEvent(event: Event){
        guard !self.ownedEvents.contains(event) else { return }
        self.ownedEvents.insert(event)
    }
    
    func removeEvent(event: Event){
        guard self.ownedEvents.contains(event) else { return }
        self.ownedEvents.remove(event)
    }
}
