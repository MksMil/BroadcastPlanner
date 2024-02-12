import Foundation

class Event {
    let id: UUID
    var date: Date
    var broadcaster: Broadcaster
    var eventLocation: Stadium
    var cameras: [Camera]
    var owners: [String] = []
    
    init(id: UUID, date: Date, broadcaster: Broadcaster, location: Stadium, cameras: [Camera]) {
        self.id = id
        self.date = date
        
        self.broadcaster = broadcaster
        self.eventLocation = location
        self.cameras = cameras
    }
}


