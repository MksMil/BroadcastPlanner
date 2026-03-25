import Foundation

struct HardwareDTO: Codable, Identifiable,CoreDataRepresentable {
    
    typealias Entity = Hardware
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    var id: String
    var envType: String = "Empty"
    var chanels: [String] = []
    var lastUpdated: Date = .now
}
