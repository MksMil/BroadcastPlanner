import Foundation

enum HostBroadcaster: String, Codable, Identifiable, CaseIterable {
    case SoftGroup
    case EngeneerService
    
    var id: Self {
        self
    }
}

struct Broadcaster: Codable, Identifiable {
    var id: String {
        host
    }
    var host: String
    var cars: [BroadcasterCar] = []
}

class BroadcasterCar: Codable, Identifiable {
    var id: String
    let name: String
    let imageName: String 
    var units: [CarUnit] = []
    init(name: String, imageName: String) {
        self.id = UUID().uuidString
        self.name = name
        self.imageName = imageName
    }
}

struct CarUnit: Codable, Identifiable{
    var id: String
    var position: String
    var coordinates: BPEventPlanPointCoordinate
    
}
