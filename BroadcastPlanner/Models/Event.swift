import Foundation

class Event {
    let id: UUID
    var date: Date
    var broadcaster: Broadcaster
    var location: Stadium
    var cameras: [Camera]
    
    init(id: UUID, date: Date, broadcaster: Broadcaster, location: Stadium, cameras: [Camera]) {
        self.id = id
        self.date = date
        
        self.broadcaster = broadcaster
        self.location = location
        self.cameras = cameras
    }
}


