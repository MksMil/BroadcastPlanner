import Foundation

class Broadcaster: Codable {
    enum HostBroadcaster: String, Codable, Identifiable, CaseIterable {
        case SG
        case EngeneerService
        
        var id: Self {
            self
        }
    }
    var id: String {
        host.rawValue
    }
    
    var host: HostBroadcaster = .EngeneerService
    var name: String
    var cars: [BroadcasterCar]
    
    init(name: String, cars: [BroadcasterCar]) {
        self.name = name
        self.cars = cars
    }   
    
    init(){
        self.name = ""
        self.cars = []
    }
}

class BroadcasterCar: Codable {
    let name: String
    var imageUrl: String?
    
    init(name: String) {
        self.name = name
    }
}
