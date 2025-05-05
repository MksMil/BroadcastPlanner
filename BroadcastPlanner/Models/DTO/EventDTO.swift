import Foundation

struct EventDTO: Identifiable, Codable, BPDataProtocol {
    var id: String
    
    //event date
    var date: Date
    var lastUpdated: Date
    
    //info
    var locationID: String?
    var obVanId: String?
    
    //unit points
    var locationPoints: [PointDTO]
    var obVanUnits: [UnitDTO]
    
    //owners Id's
    var ownersIds: [String] = []
    var usersIds: [String] = []
    //clubs Id's
    var homeClubId: String?
    var guestClubId: String?
    
    var locationPreviewId: String?
    var obvanPreviewId: String?
   
    // MARK: - Initialization
    init( id: String = UUID().uuidString, date: Date = Date(),lastUpdated: Date ,obVanId: String?, locationPoints: [PointDTO] = [], obvanUnits: [UnitDTO] = [], locationID: String?, homeClubId: String?, guestClubId: String?,locationPreviewId: String?,obvanPreviewId: String? ) {
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



