import Foundation

struct VenuePointDTO: Identifiable, Codable,CoreDataRepresentable {
    
    typealias Entity = VenuePoint
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var lastUpdated: Date = .now
    var id: String
    var number: Int

    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    
    var description: String
    var task: String
    
    var imageId: String
    var obvanId: String
    
    var memberId : String
    var camera: CameraDTO?
    var sound: SoundDTO?
    var light: LightDTO?
}










