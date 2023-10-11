import Foundation

class MockData {
    static var sampleEvent: Event = Event(id: UUID(),
                                          date: Date(),
                                          creativeGroup: CreativeGroup(),
                                          broadcaster: MockData.sampleBroadcaster,
                                          location: Stadium(),
                                          cameras: MockData.sampleCameras)
    
    static var sampleUser: User = User()
    
    static var sampleUsers: [User] = [
        User(name: "Viktor Kabkoff"),
        User(name: "Valeriy Gozha"),
        User(name: "Sergiy Maliovanniy"),
        User(name: "Ihor Stepanovitch"),
        User(name: "Aleksandr Grianko")
    ]
    
    static let sampleBroadcaster: Broadcaster  = Broadcaster(name: "SG", cars: [BroadcasterCar(name: "SG SUPER CAR")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{
        Camera(position: $0)
    }
    
}
