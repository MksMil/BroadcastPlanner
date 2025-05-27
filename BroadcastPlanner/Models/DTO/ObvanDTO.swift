import Foundation

struct ObvanDTO: Codable, Identifiable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Obvan
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var lastUpdated: Date = .now
    var name: String
    var imageId: String
    var broadcaster: String
    var templateUnits: [ObvanTemplateUnitDTO]
    
}
