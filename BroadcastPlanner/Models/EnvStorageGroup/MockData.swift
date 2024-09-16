import Foundation

//mock data for Previews only
enum MockData {
    static var sampleEvent: Event = Event(
        
        date: Date(),
        broadcaster: sampleESBroadcaster,
        broadcasterCar: esCarBabyBird,
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

    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{ Camera(position: $0) }
    
    static let sampleEvents: [Event] = [
        Event(date: Date(), 
              broadcaster: MockData.sampleESBroadcaster,
              broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"),
              location: MockData.sampleStadium,
              eventPlan: BPEventPlan()),
        Event(date: Date(),
              broadcaster: MockData.sampleESBroadcaster,
              broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"),
              location: MockData.sampleStadium,
              eventPlan: BPEventPlan()),
        Event(date: Date(),
              broadcaster: MockData.sampleESBroadcaster,
              broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"),
              location: MockData.sampleStadium,
              eventPlan: BPEventPlan()),
        Event(date: Date(), 
              broadcaster: MockData.sampleESBroadcaster,
              broadcasterCar: BroadcasterCar(name: "BabyBird", imageName: "empty_babybird"),
              location: MockData.sampleStadium,
              eventPlan: BPEventPlan())]
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
    
    static let sampleESBroadcaster: Broadcaster  = Broadcaster(host: "EngenerService",
                                                               cars: [MockData.esCarStarBird, MockData.esCarBabyBird])
    static let sampleSGBroadcaster: Broadcaster  = Broadcaster( host: "SoftGroup",
                                                                cars: [MockData.esCarStarBird, MockData.esCarBabyBird])
    
    static let esCarStarBird:BroadcasterCar =
    BroadcasterCar(name: "Starbird",
                   imageName: "empty_starbird",
                   units: [
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.producer.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.392, y: 0.63, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.replayDirector.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.434, y: 0.63, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.mainDirector.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.482, y: 0.63, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.director.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.523, y: 0.63, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.graphicsOperator.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.57, y: 0.63, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.replayOperator.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.385, y: 0.18, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.replayOperator.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.425, y: 0.18, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.replayOperator.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.465, y: 0.18, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.replayOperator.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.505, y: 0.18, rotation: 0)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.soundDirector.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.69, y: 0.52, rotation: 90)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.soundDirector.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.69, y: 0.71, rotation: 90)),
                    CarUnit(id: UUID().uuidString, position: UserSpecialization.soundDirector.rawValue,
                            coordinates: BPEventPlanPointCoordinate(x: 0.745, y: 0.68, rotation: 0))
                   ])
    
    
    static let esCarBabyBird: BroadcasterCar =
    BroadcasterCar(name: "Babybird", imageName: "empty_babybird", units:
                    [
                        CarUnit(id: UUID().uuidString, position: UserSpecialization.soundDirector.rawValue,
                                coordinates: BPEventPlanPointCoordinate(x: 0.284, y: 0.44, rotation: 0)),
                        CarUnit(id: UUID().uuidString, position: UserSpecialization.mainDirector.rawValue,
                                coordinates: BPEventPlanPointCoordinate(x: 0.459, y: 0.42, rotation: 0)),
                        CarUnit(id: UUID().uuidString, position: UserSpecialization.graphicsOperator.rawValue,
                                coordinates: BPEventPlanPointCoordinate(x: 0.556, y: 0.42, rotation: 0)),
                        CarUnit(id: UUID().uuidString, position: UserSpecialization.replayOperator.rawValue,
                                coordinates: BPEventPlanPointCoordinate(x: 0.632, y: 0.42, rotation: 0)),
                        CarUnit(id: UUID().uuidString, position: UserSpecialization.replayOperator.rawValue,
                                coordinates: BPEventPlanPointCoordinate(x: 0.71, y: 0.42, rotation: 0))
                    ])
        
}
