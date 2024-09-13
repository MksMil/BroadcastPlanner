import Foundation
import FirebaseFirestore

class Event: Identifiable, Codable {
    var id: String
    
    var date: Date = Date()
    
    var broadcaster: Broadcaster
    var broadcastCar: BroadcasterCar
    var eventLocation: EventLocation
    
    var eventPlan: BPEventPlan
    var owners: [String] = []
    
    //team logos
    var homeImageString: String = ""
    var guestImageString: String = ""
   
    
    
    // MARK: - Initialization
    init( id: String = UUID().uuidString,date: Date = Date(), eventPlan: BPEventPlan = BPEventPlan()) {
        self.id = id
        self.date = date
        self.broadcaster = Broadcaster(host: "")
        self.broadcastCar = BroadcasterCar(name: "", imageName: "")
        self.eventPlan = eventPlan
        self.eventLocation = EventLocation()
    }
    
    init( id: String = UUID().uuidString, date: Date = Date(), broadcaster: Broadcaster,broadcasterCar: BroadcasterCar, location: EventLocation,eventPlan: BPEventPlan = BPEventPlan()) {
        self.id = id
        self.date = date
        self.broadcaster = broadcaster
        self.broadcastCar = broadcasterCar
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

