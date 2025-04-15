import Foundation

//structure to generate directors group in broadcast obvan

struct UnitDTO: Codable, Identifiable,BPDataProtocol{
    var id: String
    var position: UserSpecialization
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var isEnabled: Bool = true
    var userId: String
    var hardwares: [HardwareDTO]
}

