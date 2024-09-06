import Foundation

//mock data for Previews only
class MockData {
    static var sampleEvent: Event = Event(
        
        date: Date(),
        broadcaster: sampleBroadcaster,
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
    static let sampleBroadcaster: Broadcaster  = Broadcaster(name: "SG", cars: [BroadcasterCar(name: "SG SUPER CAR")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{ Camera(position: $0) }
 
    static let sampleEvents: [Event] = [
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan())]
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
}
