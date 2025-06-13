import Foundation
struct SoundDTO: Codable, Identifiable,CoreDataRepresentable {
    
    typealias Entity = Sound
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
 
    var id: String
    var windDefence: WindDefence = .none
    var placeType: PlaceType = .none
}
