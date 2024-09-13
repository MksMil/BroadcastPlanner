import Foundation

//mock data for Previews only
class MockData {
    static var sampleEvent: Event = Event(
        
        date: Date(),
        broadcaster: sampleESBroadcaster,
        broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"),
        location: sampleLocations[0],
        eventPlan: BPEventPlan()
    )
    
    static var sampleUser: BPUser {
        let user = BPUser()
        user.specialization = [UserSpecialization.director.rawValue, UserSpecialization.cameramen.rawValue]
        return user
    }
    static let sampleStadium: EventLocation = EventLocation(
        title: "ARENA - LVIV",
        address: "Lviv. Striyska str. 199. 79031"
    )
    static var sampleUsers: [BPUser] = [ ]
    static let sampleESBroadcaster: Broadcaster  = Broadcaster(host: "EngeneerService", cars: [BroadcasterCar(name: "Starbird", imageName: "empty_starbird"),BroadcasterCar(name: "Babybird", imageName: "empty_babybird")])
    static let sampleSGBroadcaster: Broadcaster  = Broadcaster( host: "SoftGroup",cars: [BroadcasterCar(name: "SG1", imageName: "empty_starbird"),BroadcasterCar(name: "SG2", imageName: "empty_babybird")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{ Camera(position: $0) }
    
    static let sampleEvents: [Event] = [
        Event(date: Date(), broadcaster: MockData.sampleESBroadcaster, broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"), location: MockData.sampleStadium, eventPlan: BPEventPlan()),
        Event(date: Date(), broadcaster: MockData.sampleESBroadcaster, broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"), location: MockData.sampleStadium, eventPlan: BPEventPlan()),
        Event(date: Date(), broadcaster: MockData.sampleESBroadcaster, broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"), location: MockData.sampleStadium, eventPlan: BPEventPlan()),
        Event(date: Date(), broadcaster: MockData.sampleESBroadcaster, broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"),location: MockData.sampleStadium, eventPlan: BPEventPlan())]
    static let sampleLocations: [EventLocation] = [
        EventLocation(
            title: "Авангард",
            address: "Кривой Рог, ул. Криворожская 25 кв. 17, в кухне на верхней полке в банке из под чая, на которой написано сахар!",
            imageStrings: ["Krivbass_1_stad",
                           "Krivbass_2_stad",
                           "Krivbass_3_stad"]),
        EventLocation(
            title: "Александрия",
            address: "Александрия",
            imageStrings: ["Oleksandria_stad1",
                           "Oleksandria_stad"]),
        EventLocation(
            title: "Житомир",
            address: "Житомир",
            imageStrings: ["LNZ_stad"]),
        EventLocation(
            title: "Оболонь",
            address: "Киев",
            imageStrings: ["Obolon"])
    ]
    
    static let sampleEventPlan: BPEventPlan = BPEventPlan(id: UUID().uuidString,
                                                      title: "\(Int.random(in: 1...10)) plan",
                                                      background: "",
                                                      fieldPoints: [sampleFieldPoint,sampleFieldPoint,sampleFieldPoint,sampleFieldPoint],
                                                      carPoints: [sampleFieldPoint,sampleFieldPoint,sampleFieldPoint,sampleFieldPoint],
                                                      fieldBackground: "",
                                                      carBackground: "")
    static var samplePlanTemplates: [BPEventPlan] {

        [ BPEventPlan(id: "123", title: "1", background: "", fieldPoints: [sampleFieldPoint], carPoints: [], fieldBackground: "", carBackground: ""),
          BPEventPlan(id: "345", title: "2", background: "", fieldPoints: [sampleFieldPoint], carPoints: [], fieldBackground: "", carBackground: ""),
        ]
    }
    
    static var sampleFieldPoint: BPEventPlanPoint {
        BPEventPlanPoint(id: "",
                         coordinates: sampleCoordinates,
                         user: sampleUser,
                         cam: Cam(),
                         mic: Mic(),
                         light: Light(),
                         env: ReplayHardware(),
                         eventPlanPointNumber: Int.random(in: 1...11),
                         description: "stadium cam",
                         tasks: "some tasks")
    }
    static var sampleCoordinates: BPEventPlanPointCoordinate { BPEventPlanPointCoordinate(x: Double.random(in: 0..<1),
                                                                                          y: Double.random(in: 0..<1),
                                                                                          rotation: Double.random(in: 0...360))
    }
    
    static var sampleSettings: GlobalSettings {
        let settings = GlobalSettings()
        settings.planPointsTemlates = samplePlanTemplates
        settings.broadcasters = [sampleESBroadcaster, sampleSGBroadcaster]
        return settings
    }
}
