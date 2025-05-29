import SwiftUI
import Combine

final class MainEventListCellViewModel: ObservableObject{
    
    let event: Broadcast
    
    @Published var date: Date
    @Published var broadcastStringDate: String = ""
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
    
    init(event: Broadcast) {
        self.event = event
        
        self.date = event.viewDate
        self.broadcastStringDate = BPDateFormater.format(date: event.viewDate)
        self.title = event.viewTitle
        self.address = event.viewAddress
        self.homeImage = event.homeImage
        self.guestImage = event.guestImage

    }

    func update(){
        title = event.viewTitle
        address = event.viewAddress
        broadcastStringDate = BPDateFormater.format(date: event.viewDate)
        date = event.viewDate
        homeImage = event.homeImage
        guestImage = event.guestImage
    }
    
    
}
