import Foundation

struct TemplatePointDTO: Identifiable, Codable,CoreDataRepresentable {
    
    typealias Entity = TemplatePoint
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var lastUpdated: Date = .now
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    
    var camera: CameraDTO?
    var sound: SoundDTO?
    var light: LightDTO?
    
    var number: Int
    var pointDescription: String
    var task : String
  
}
