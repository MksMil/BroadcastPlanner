import Foundation

struct ClubDTO: Codable, Identifiable,CoreDataRepresentable {
    
    typealias Entity = Club
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    
    var id: String
    var title: String
    var contacts: String = ""
    var urlString: String = ""
    var imageLogoID: String?
    var homeVenueID: String?
    var lastUpdated: Date 
}
