import Foundation

struct VenuePointDTO: Identifiable, Codable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = VenuePoint
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
 
    var id: String
    var number: Int

    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    
    var description: String
    var task: String
    
    var imageId: String
    
    var memberIds : [String]
    var cameras: [CameraDTO]
    var sounds: [SoundDTO]
    var lights: [LightDTO]
}










