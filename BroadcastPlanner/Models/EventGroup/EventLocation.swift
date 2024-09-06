import Foundation
import FirebaseFirestore

class EventLocation: Identifiable,Codable{
    var id: String
    
    var title: String
    var address: String
    var imageStrings: [String]
    
    init(id: String = UUID().uuidString,
        title: String = "empty",
        address: String = "empty address",
        imageStrings: [String] = []
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.imageStrings = imageStrings
    }
}



// MARK: - Hashable, Equatable
extension EventLocation: Hashable, Equatable {
    static func == (lhs: EventLocation, rhs: EventLocation) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}
