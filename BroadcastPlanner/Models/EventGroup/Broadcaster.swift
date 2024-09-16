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
    var units: [CarUnit]
    init(name: String, imageName: String, units: [CarUnit] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.imageName = imageName
        self.units = units
    }
}

struct CarUnit: Codable, Identifiable{
    var id: String
    var position: String
    var coordinates: BPEventPlanPointCoordinate
    var isDisabled: Bool = false
    
}




