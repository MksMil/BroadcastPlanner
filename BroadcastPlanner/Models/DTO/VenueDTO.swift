import Foundation

struct VenueDTO: Identifiable,Codable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Venue
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    var id: String
    var lastUpdated: Date
    var title: String
    var address: String
    var imagesIds: [String]
    var locationBackgroundId: String?
    
    init(id: String = UUID().uuidString,
         lastUpdated: Date = .now,
        title: String = "empty",
        address: String = "empty address",
        imagesIds: [String] = [],
        locationBackgroundId: String? = "stadium"
    ) {
        self.id = id
        self.lastUpdated = lastUpdated
        self.title = title
        self.address = address
        self.imagesIds = imagesIds
        self.locationBackgroundId = locationBackgroundId
    }
}

