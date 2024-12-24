import Foundation

class Location: Identifiable,Codable,BPDataProtocol{
    var id: String
    var title: String
    var address: String
    var imagesIds: [String]
    var locationBackgroundId: String?
    
    init(id: String = UUID().uuidString,
        title: String = "empty",
        address: String = "empty address",
        imagesIds: [String] = [],
        locationBackgroundId: String? = "stadium"
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.imagesIds = imagesIds
        self.locationBackgroundId = locationBackgroundId
    }
}
// MARK: - Hashable, Equatable
extension Location: Hashable, Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Prepare data to network save. Mapping to 'Location' network model, to save in remoteDB
extension Location {
    static func mapToLocation(localLocation: LocalLocation) -> Location{
        
        let location = Location(
            id: localLocation.viewId,
            title: localLocation.viewTitle,
            address: localLocation.viewAddress,
            imagesIds: localLocation.viewLocalImages.map{$0.viewId},
            locationBackgroundId: localLocation.background?.id
        )
        
        return location
    }
    
}
