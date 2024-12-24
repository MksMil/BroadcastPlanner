import Foundation

class BPEvent: Identifiable, Codable,BPDataProtocol {
    var id: String
    
    //event date
    var date: Date
    
    //info
    var locationID: String?
    var broadcasterId: String?
    var obVanId: String?
    
    
    //unit points
    var locationPoints: [LocationPoint]
    var obVanUnits: [OBVanUnit]
    
    //owners Id's
    var ownersIds: [String] = []
    var usersIds: [String] = []
    //clubs Id's
    var homeClubId: String?
    var guestClubId: String?
    var locationPreviewId: String?
    var obvanPreviewId: String?
   
    // MARK: - Initialization
    init( id: String = UUID().uuidString, date: Date = Date(), broadcasterId: String?, obVanId: String?, locationPoints: [LocationPoint] = [], obvanUnits: [OBVanUnit] = [], locationID: String?, homeClubId: String?, guestClubId: String?,locationPreviewId: String?,obvanPreviewId: String? ) {
        self.id = id
        self.date = date
        self.broadcasterId = broadcasterId
        self.obVanId = obVanId
        self.locationPoints = locationPoints
        self.obVanUnits = obvanUnits
        self.locationID = locationID
        self.homeClubId = homeClubId
        self.guestClubId = guestClubId
        self.locationPreviewId = locationPreviewId
        self.obvanPreviewId = obvanPreviewId
    }
    
    init(){
        self.id = UUID().uuidString
        self.date = Date()
        self.broadcasterId = ""
        self.obVanId = ""
        self.locationID = ""
        self.locationPoints = []
        self.obVanUnits = []
        self.homeClubId = ""
        self.guestClubId = ""
    }
}

// MARK: - Hashable/Equatable
extension BPEvent: Hashable, Equatable {
    static func == (lhs: BPEvent, rhs: BPEvent) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - map LocalEvent to Event
// TODO: Rework to method
extension BPEvent {
    static func mapLocalEventToEvent(localEvent: LocalEvent) -> BPEvent {
        let event = BPEvent(id: localEvent.viewId,
                            date: localEvent.viewRemainingDate,
                            broadcasterId: localEvent.broadcaster?.id,
                            obVanId: localEvent.obVan?.id,
                            locationPoints: localEvent.viewLocationPoints.compactMap{LocationPoint.mapToLocationPoint(localPoint: $0)},
                            obvanUnits: localEvent.viewObvanUnits.compactMap{OBVanUnit.mapToObvan(localUnit: $0)},
                            locationID: localEvent.location?.id,
                            homeClubId: localEvent.homeClub?.id,
                            guestClubId: localEvent.guestClub?.id,
                            locationPreviewId: localEvent.locationPreview?.id,
                            obvanPreviewId: localEvent.obvanPreview?.id)
        event.ownersIds = localEvent.viewOwners.map({$0.userId})
        event.usersIds = localEvent.viewUsers.map({$0.userId})
        
        return event
    }
}


