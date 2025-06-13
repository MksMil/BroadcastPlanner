import Foundation

struct BroadcastDTO: Identifiable, Codable,CoreDataRepresentable {
    
    typealias Entity = Broadcast
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    
    //broadcast date
    var date: Date
    var lastUpdated: Date
    
    //info
    var venueID: String?
    var obvanId: [String] = []
    
    //crew venuePoints
    var venuePoints: [VenuePointDTO]
    var crews: [CrewDTO]
    
    //owners Id's
    var ownersIds: [String] = []
    //clubs Id's
    var homeClubId: String?
    var guestClubId: String?
    
    var venuePreviewId: String?
    var obvanPreviewId: String?
   
    // MARK: - Initialization
    init( id: String = UUID().uuidString, date: Date = Date(),lastUpdated: Date = .now ,obvanId: [String] = [], venuePoints: [VenuePointDTO] = [], crews: [CrewDTO] = [], venueID: String?, homeClubId: String?, guestClubId: String?,venuePreviewId: String?,obvanPreviewId: String? ) {
        self.id = id
        self.date = date
        self.lastUpdated = lastUpdated
        self.obvanId = obvanId
        self.venuePoints = venuePoints
        self.crews = crews
        self.venueID = venueID
        self.homeClubId = homeClubId
        self.guestClubId = guestClubId
        self.venuePreviewId = venuePreviewId
        self.obvanPreviewId = obvanPreviewId
    }

}



