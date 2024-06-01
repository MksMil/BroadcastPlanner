import Foundation
import FirebaseFirestore

class Event: Identifiable, Codable {
    var id: String?
    var date: Date = Date()
    var broadcaster: Broadcaster?
    var eventLocation: Stadium?
    
    var eventPlan: BPEventPlan
    var owners: [BPUser] = []
    
    init(id: String, date: Date, broadcaster: Broadcaster, location: Stadium, eventPlan: BPEventPlan) {
        self.id = id
        self.date = date
        
        self.broadcaster = broadcaster
        self.eventLocation = location
        self.eventPlan = eventPlan
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

