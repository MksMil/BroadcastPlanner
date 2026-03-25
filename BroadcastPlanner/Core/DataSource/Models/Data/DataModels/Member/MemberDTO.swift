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
    var accessLevel: Int = 2
    var lastUpdated: Date = .now
    
    var firstName : String = "Коллегв"
    var lastName: String = "Уважаемый"
    var isOnline: Bool = false
    
    var phoneNumber: String = ""
    var email: String = ""
    var homeAddress: String = ""
    var specialization = [String]()
    
    var creationDate: Date = .now
    var leaveDate: Date = .now
    
    init(id: String = UUID().uuidString){
        self.id = id
    }
}




