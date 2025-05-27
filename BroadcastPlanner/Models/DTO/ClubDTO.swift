import Foundation

struct ClubDTO: Codable, Identifiable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Club
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    
    var id: String
    var title: String
    var contacts: String = ""
    var urlString: String = ""
    var imageLogoID: String?
    var homeLocationID: String?
    var lastUpdated: Date = .now
}
