import Foundation


struct MemberDTO: Identifiable, Codable,CoreDataRepresentable {
    
    typealias Entity = Member
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    var id: String
    // 0-root
    // 1-producer
    // 2-participant
    var accessLevel: Int = 1
    var lastUpdated: Date = .now
    
    var firstName : String = "empty"
    var lastName: String = "empty"
    var isOnline: Bool = false
    
    var phoneNumber: String = "1234567890"
    var email: String = "email"
    var homeAddress: String = "address"
    var specialization = [String]()
    
    var creationDate: Date = .now
    var leaveDate: Date = .now
    
    init(id: String = UUID().uuidString){
        self.id = id
    }
}




