import Foundation

struct LightDTO: Codable, Identifiable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Light
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var lightType: LightType = .none
}
