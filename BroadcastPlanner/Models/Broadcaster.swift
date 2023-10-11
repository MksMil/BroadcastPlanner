import Foundation

class Broadcaster {
    let name: String
    let cars: [BroadcasterCar]
    
    init(name: String, cars: [BroadcasterCar]) {
        self.name = name
        self.cars = cars
    }   
}

class BroadcasterCar {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
