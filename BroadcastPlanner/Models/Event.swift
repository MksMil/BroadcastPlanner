import Foundation

class Event {
    let id: UUID
    var date: Date
    var broadcaster: Broadcaster
    var eventLocation: Stadium
    var cameras: [Camera]
    var owners: Set<BPUser> = []
    
    init(id: UUID, date: Date, broadcaster: Broadcaster, location: Stadium, cameras: [Camera]) {
        self.id = id
        self.date = date
        
        self.broadcaster = broadcaster
        self.eventLocation = location
        self.cameras = cameras
    }
    
    // MARK: - Owners managment
    func addOwner(user: BPUser) throws {
        guard !owners.contains(user) else {
            //user already owner of this event
            throw BPError.unableToComplete
        }
        owners.insert(user)
    }
    
    func removeOwner(_ user: BPUser) throws{
        guard owners.contains(user) else {
            //user alredy not owner of this event
            throw BPError.unableToComplete
        }
        owners.remove(user)
    }
}


