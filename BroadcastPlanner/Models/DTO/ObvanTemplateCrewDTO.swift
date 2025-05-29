import Foundation

struct ObvanTemplateCrewDTO: Identifiable, Codable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = ObvanTemplateCrew
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    var position: String
    var isRequired: Bool
    
    
}
