import Foundation

class Event {
    let id: String
    var date: Date
    var broadcaster: Broadcaster
    var eventLocation: Stadium
    
    var cameras: [Camera]
    var owners: Set<BPUser> = []
    
    init(id: String, date: Date, broadcaster: Broadcaster, location: Stadium, cameras: [Camera]) {
        self.id = id
        self.date = date
        
        self.broadcaster = broadcaster
        self.eventLocation = location
        self.cameras = cameras
    }
}

// MARK: - Owners managment
extension Event {
    func addOwner(user: BPUser) throws {
        guard !owners.contains(user) else {
            //user already owner of this event
            throw BPError.unableToComplete
        }
        owners.insert(user)
        
        guard !user.ownedEvents.contains(self) else { return }
        user.addEvent(event: self)
    }
    
    func removeOwner(_ user: BPUser) throws{
        guard owners.contains(user) else {
            //user alredy is not owner of this event
            throw BPError.unableToComplete
        }
        owners.remove(user)
        
        guard user.ownedEvents.contains(self) else { return }
        user.removeEvent(event: self)
    }
}

// MARK: - Hashable/Equatable
extension Event: Hashable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

