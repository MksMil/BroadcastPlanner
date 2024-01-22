import Foundation

class MockData {
    static var sampleEvent: Event = Event(id: UUID(),
                                          date: Date(),
                                          broadcaster: MockData.sampleBroadcaster,
                                          location: sampleStadium,
                                          cameras: MockData.sampleCameras)
    
    static var sampleUser: BPUser = BPUser()
    static let sampleStadium: Stadium = Stadium(
        title: "ARENA - LVIV",
        city: "Lviv",
        address: "Lviv. Striyska str. 199. 79031"
    )
    static var sampleUsers: [BPUser] = [
        BPUser(name: "Viktor Kabkoff"),
        BPUser(name: "Valeriy Gozha"),
        BPUser(name: "Sergiy Maliovanniy"),
        BPUser(name: "Ihor Stepanovitch"),
        BPUser(name: "Aleksandr Grianko")
    ]
    
    static let sampleBroadcaster: Broadcaster  = Broadcaster(name: "SG", cars: [BroadcasterCar(name: "SG SUPER CAR")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{
        Camera(position: $0)
    }
    
}
