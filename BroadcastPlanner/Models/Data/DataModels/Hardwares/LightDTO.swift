import Foundation

struct LightDTO: Codable, Identifiable,CoreDataRepresentable {
    
    typealias Entity = Light
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    var lastUpdated: Date = .now
    var id: String
    var lightType: LightType = .none
}
