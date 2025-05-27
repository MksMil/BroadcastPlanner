import Foundation

struct HardwareDTO: Codable, Identifiable, BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Hardware
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    var id: String
    var envType: ReplayType = .none
    var chanels: [String] = []
}
