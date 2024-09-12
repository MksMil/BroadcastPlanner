import Foundation

enum HostBroadcaster: String, Codable, Identifiable, CaseIterable {
    case SG
    case EngeneerService
    
    var id: Self {
        self
    }
}

struct Broadcaster: Codable, Identifiable {
    var id: String {
        host.rawValue
    }
    
    var host: HostBroadcaster = .EngeneerService
    var name: String
    var cars: [BroadcasterCar] = []
}

class BroadcasterCar: Codable {
    let name: String
    var imageName: String?
    var units: [CarUnit] = []
    init(name: String) {
        self.name = name
    }
}

struct CarUnit: Codable, Identifiable{
    var id: String
    var position: String
    var coordinates: BPEventPlanPointCoordinate
    
}
