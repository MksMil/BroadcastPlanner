import Foundation

//mock data for Previews only
class MockData {
    static var sampleEvent: Event = Event(
        
        date: Date(),
        broadcaster: sampleBroadcaster,
        location: sampleLocations[0],
        eventPlan: BPEventPlan()
    )
    
    static var sampleUser: BPUserLocalData =  BPUserLocalData(user: BPUser())
    static let sampleStadium: EventLocation = EventLocation(
        title: "ARENA - LVIV",
        city: "Lviv",
        address: "Lviv. Striyska str. 199. 79031"
    )
    static var sampleUsers: [BPUserLocalData] = [
//        BPUser( firstName: "Viktor"),
//        BPUser( firstName: "Vadim"),
//        BPUser( firstName: "Alexander"),
//        BPUser( firstName: "Valera"),
//        BPUser( firstName: "Anatoliy")
       
    ].map{BPUserLocalData(user: $0)}
    static let sampleBroadcaster: Broadcaster  = Broadcaster(name: "SG", cars: [BroadcasterCar(name: "SG SUPER CAR")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{ Camera(position: $0) }
 
    static let sampleEvents: [Event] = [
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan())]
    static let sampleLocations: [EventLocation] = [
        EventLocation(
            title: "Кривой Рог",
            city: "Кривой Рог",
            address: "Кривой Рог",
            imageStrings: ["Krivbass_1_stad",
                           "Krivbass_2_stad",
                           "Krivbass_3_stad"]),
            EventLocation(
                title: "Александрия",
                city: "Александрия",
                address: "Александрия",
                imageStrings: ["Oleksandria_stad1",
                               "Oleksandria_stad"]),
                EventLocation(
                    title: "Житомир",
                    city: "Житомир",
                    address: "Житомир",
                    imageStrings: ["LNZ_stad"]),
                    EventLocation(
                        title: "Оболонь",
                        city: "Киев",
                        address: "Киев",
                        imageStrings: ["Obolon"])
    ]
}
