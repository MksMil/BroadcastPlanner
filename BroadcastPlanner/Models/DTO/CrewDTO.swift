import Foundation

//structure to generate directors group in broadcast obvan

struct CrewDTO: Codable, Identifiable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Crew
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var position: String
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    var task: String
    var isEnabled: Bool = true
    var memberId: String
    var hardware: HardwareDTO?
}

