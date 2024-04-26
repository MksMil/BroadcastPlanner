import Foundation

//mock data for Previews only
class MockData {
    static var sampleEvent: Event = Event(id: UUID().uuidString,
                                          date: Date(),
                                          broadcaster: MockData.sampleBroadcaster,
                                          location: sampleStadium,
                                          cameras: MockData.sampleCameras)
    
    static var sampleUser: BPUser = BPUser(name: "Anatoliy Yangol jr.")
    static let sampleStadium: Stadium = Stadium(
        title: "ARENA - LVIV",
        city: "Lviv",
        address: "Lviv. Striyska str. 199. 79031"
    )
    static var sampleUsers: [BPUser] = [
        BPUser(id: "ViktorID",
               email: "Viktor@email.ua",
               firstName: "Viktor",
               creationDate: Date()),
        BPUser(name: "Valeriy Gozha"),
        BPUser(name: "Sergiy Maliovanniy"),
        BPUser(name: "Ihor Stepanovitch"),
        BPUser(name: "Aleksandr Grianko")
    ]
    
    static let sampleBroadcaster: Broadcaster  = Broadcaster(name: "SG", cars: [BroadcasterCar(name: "SG SUPER CAR")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{
        Camera(position: $0)
    }
    static var sampleEvents: [Event] = [
        Event(id: UUID().uuidString,
              date: Date(),
              broadcaster: MockData.sampleBroadcaster,
              location: sampleStadium,
              cameras: MockData.sampleCameras),
        Event(id: UUID().uuidString,
              date: Date(),
              broadcaster: MockData.sampleBroadcaster,
              location: sampleStadium,
              cameras: MockData.sampleCameras),
        Event(id: UUID().uuidString,
              date: Date(),
              broadcaster: MockData.sampleBroadcaster,
              location: sampleStadium,
              cameras: MockData.sampleCameras),
        Event(id: UUID().uuidString,
              date: Date(),
              broadcaster: MockData.sampleBroadcaster,
              location: sampleStadium,
              cameras: MockData.sampleCameras)
    ]
}
