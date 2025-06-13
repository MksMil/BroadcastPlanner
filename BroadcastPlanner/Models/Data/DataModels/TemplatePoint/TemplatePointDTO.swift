import Foundation

struct TemplatePointDTO: Identifiable, Codable,CoreDataRepresentable {
    
    typealias Entity = TemplatePoint
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    
    var cameras: [CameraDTO]
    var sounds: [SoundDTO]
    var lights: [LightDTO]
    
    var number: Int
    var pointDescription: String
    var task : String
  
}
