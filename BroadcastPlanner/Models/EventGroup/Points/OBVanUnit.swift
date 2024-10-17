import Foundation

//structure to generate directors group in broadcast car

struct OBVanUnit: Codable, Identifiable{
    var id: String
    var position: UserSpecialization
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var isEnabled: Bool
    var userId: String
    var hardwares: [Hardware]
}
