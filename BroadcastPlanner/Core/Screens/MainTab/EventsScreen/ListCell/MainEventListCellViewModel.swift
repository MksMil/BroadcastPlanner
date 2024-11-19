import Foundation
import Combine

final class MainEventListCellViewModel: ObservableObject{
    
    var event: LocalEvent
    
    @Published var timer = Timer.publish(every: 1,
                                         on: .main,
                                         in: .common)
        .autoconnect()
    @Published var eventDate: String = ""
    @Published var counter: String = "counter here"
//    @Published var homeClub: LocalClub?
//    @Published var guestClub: LocalClub?
    @Published var title: String
    @Published var address: String
    
    var cancellables: Set<AnyCancellable> = []
    
    var timeRemaining: TimeInterval {
        max(event.viewRemainingDate.timeIntervalSinceNow, 0)
        }
    
    init(event: LocalEvent) {
        self.event = event
        self.eventDate = BPDateFormater.format(date: event.viewRemainingDate)
        self.counter = ""
//        self.homeClub = event.homeClub
//        self.guestClub = event.guestClub
        self.title = event.viewTitle
        self.address = event.viewAddress
        //publisher
        makePublisher()
    }
   
    func makePublisher(){
        self.timer.sink { [weak self] timer in
            self?.updateCounter()
        }
        .store(in: &cancellables)
    }
    
    var countdownFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    func getDate(date: Date) -> String {
        return BPDateFormater.format(date: date)
    }
    
    func updateCounter() {
        if timeRemaining > 0 {
            counter = "\(countdownFormatter.string(from: timeRemaining) ?? "Time's up!")"
        } else {
            counter = "Time Up!"
        }
    }
    
    func update(){
//        homeClub =  event.homeClub
//        guestClub = event.guestClub
        title = event.viewTitle
        address = event.viewAddress
        eventDate = getDate(date: event.viewRemainingDate)
    }
    
    
}
