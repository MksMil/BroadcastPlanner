import Foundation

//mock data for Previews only
class MockData {
    static var sampleEvent: Event = Event(
        id: "",
        date: Date(),
        eventPlan: BPEventPlan.MockEventPlan
    )
    
    static var sampleUser: BPUserLocalData =  BPUserLocalData(user: BPUser(id:"",firstName: "Anatoliy Yangol jr."))
    static let sampleStadium: Stadium = Stadium(
        title: "ARENA - LVIV",
        city: "Lviv",
        address: "Lviv. Striyska str. 199. 79031"
    )
    static var sampleUsers: [BPUserLocalData] = [
        BPUser( firstName: "Viktor"),
        BPUser( firstName: "Vadim"),
        BPUser( firstName: "Alexander"),
        BPUser( firstName: "Valera"),
        BPUser( firstName: "Anatoliy")
       
    ].map{BPUserLocalData(user: $0)}
    static let sampleBroadcaster: Broadcaster  = Broadcaster(name: "SG", cars: [BroadcasterCar(name: "SG SUPER CAR")])
    
    static let sampleCameras: [Camera] = CameraPosition.allCases.map{ Camera(position: $0) }
 
    static let sampleEvents: [Event] = [
                                        Event(id: "1", date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(id: "2", date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(id: "3", date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan()),
                                        Event(id: "4", date: Date(), broadcaster: MockData.sampleBroadcaster, location: MockData.sampleStadium, eventPlan: BPEventPlan())]
    
}
