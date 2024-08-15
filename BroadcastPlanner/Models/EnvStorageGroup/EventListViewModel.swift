import Foundation

//@MainActor
final class EventListViewModel: ObservableObject {
    var userID: String
    @Published var filter: FilterEventCases
    @Published var selectedEvent: Event?
    var events: [Event]
    
    
    // MARK: - filter
    
    
    // MARK: - Init
    init(userID: String,filter: FilterEventCases = .notFiltered, events: [Event] = []) {
        self.userID = userID
        self.filter = filter
        self.events = events
        print("DEBUG: EventListViewModel initialized")
    }
    //for debug
    static func sample() -> EventListViewModel{
        return self.init(
            userID: "sample",
            filter: .notFiltered,
            events: MockData.sampleEvents
        )
    }
}


