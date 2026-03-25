import Foundation

struct ImageDTO: Codable, Identifiable,CoreDataRepresentable {
    
    typealias Entity = LocalImage
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var type: String
    var lastUpdated: Date = .now
}
