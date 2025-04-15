import Foundation

struct LocationDTO: Identifiable,Codable,BPDataProtocol{
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

