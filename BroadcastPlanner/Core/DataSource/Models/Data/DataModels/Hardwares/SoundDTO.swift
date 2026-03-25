import Foundation
struct SoundDTO: Codable, Identifiable,CoreDataRepresentable {
    
    typealias Entity = Sound
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var lastUpdated: Date = .now
    var id: String
    var windDefence: String = "Empty"
    var placeType: String = "Empty"
}
