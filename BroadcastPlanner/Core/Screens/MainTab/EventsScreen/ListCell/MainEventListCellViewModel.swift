import SwiftUI
import Combine

final class MainEventListCellViewModel: ObservableObject{
    
    let event: Event
    
    @Published var date: Date
    @Published var eventDate: String = ""
    @Published var title: String
    @Published var address: String
    @Published var homeImage: Image
    @Published var guestImage: Image
    
    var firstDate: String{
        BPDateFormater.formatDate(date: date)
    }
    var secondDate: String{
        BPDateFormater.formatTime(date: date)
    }
    
    init(event: Event) {
        self.event = event
        
        self.date = event.viewRemainingDate
        self.eventDate = event.viewDate
        self.title = event.viewTitle
        self.address = event.viewAddress
        self.homeImage = event.homeImage
        self.guestImage = event.guestImage

    }

    func update(){
        title = event.viewTitle
        address = event.viewAddress
        eventDate = event.viewDate
        date = event.viewRemainingDate
        homeImage = event.homeImage
        guestImage = event.guestImage
    }
    
    
}
