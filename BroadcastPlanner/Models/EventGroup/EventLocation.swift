import Foundation
import FirebaseFirestore

class EventLocation: Identifiable,Codable{
    
    @DocumentID var id: String?
    
    var title: String
    var city: String
    var address: String
    var imageStrings: [String]
    
    init(
        title: String = "empty",
        city: String = "empty city",
        address: String = "empty address",
        imageStrings: [String] = []
    ) {
        self.title = title
        self.city = city
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
