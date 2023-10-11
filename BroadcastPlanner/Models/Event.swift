import Foundation

class Event {
    let id: UUID
    var date: Date
    var creativeGroup: CreativeGroup
    var broadcaster: Broadcaster
    var location: Stadium
    var cameras: [Camera]
    
    init(id: UUID, date: Date, creativeGroup: CreativeGroup, broadcaster: Broadcaster, location: Stadium, cameras: [Camera]) {
        self.id = id
        self.date = date
        self.creativeGroup = creativeGroup
        self.broadcaster = broadcaster
        self.location = location
        self.cameras = cameras
    }
}


