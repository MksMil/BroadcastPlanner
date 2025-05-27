import Foundation

struct BroadcastDTO: Identifiable, Codable, BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Broadcast
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    
    //broadcast date
    var date: Date
    var lastUpdated: Date
    
    //info
    var locationID: String?
    var obVanId: String?
    
    //crew venuePoints
    var locationPoints: [PointDTO]
    var obVanUnits: [CrewDTO]
    
    //owners Id's
    var ownersIds: [String] = []
    var usersIds: [String] = []
    //clubs Id's
    var homeClubId: String?
    var guestClubId: String?
    
    var locationPreviewId: String?
    var obvanPreviewId: String?
   
    // MARK: - Initialization
    init( id: String = UUID().uuidString, date: Date = Date(),lastUpdated: Date = .now ,obVanId: String?, locationPoints: [PointDTO] = [], obvanUnits: [CrewDTO] = [], locationID: String?, homeClubId: String?, guestClubId: String?,locationPreviewId: String?,obvanPreviewId: String? ) {
        self.id = id
        self.date = date
        self.lastUpdated = lastUpdated
        self.obVanId = obVanId
        self.locationPoints = locationPoints
        self.obVanUnits = obvanUnits
        self.locationID = locationID
        self.homeClubId = homeClubId
        self.guestClubId = guestClubId
        self.locationPreviewId = locationPreviewId
        self.obvanPreviewId = obvanPreviewId
    }

}



