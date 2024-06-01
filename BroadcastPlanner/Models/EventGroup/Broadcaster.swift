import Foundation

class Broadcaster: Codable {
    let name: String
    let cars: [BroadcasterCar]
    
    init(name: String, cars: [BroadcasterCar]) {
        self.name = name
        self.cars = cars
    }   
}

class BroadcasterCar: Codable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
