import Foundation

class Location: Identifiable,Codable{
    var id: String
    var title: String
    var address: String
    var imagesIds: [String]
    var locationBackground: String
    
    init(id: String = UUID().uuidString,
        title: String = "empty",
        address: String = "empty address",
        imagesIds: [String] = [],
        locationBackground: String = "stadium"
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.imagesIds = imagesIds
        self.locationBackground = locationBackground
    }
}
// MARK: - Hashable, Equatable
extension Location: Hashable, Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}
