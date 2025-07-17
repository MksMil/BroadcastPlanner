import Foundation

struct ObvanTemplateCrewDTO: Identifiable, Codable,CoreDataRepresentable {
    
    typealias Entity = ObvanTemplateCrew
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var lastUpdated: Date = .now
    var id: String
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    var position: String
    var isRequired: Bool
    
    
}
