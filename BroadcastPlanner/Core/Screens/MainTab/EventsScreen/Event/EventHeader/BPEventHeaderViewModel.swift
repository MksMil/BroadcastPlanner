import SwiftUI

final class BPEventHeaderViewModel: ObservableObject{
    
    @Published var event: LocalEvent
    @Published var state: SheetState = .none {
        didSet{
            withAnimation{
                switch state {
                case .none:
                    locationOrClubSheet = false
                case .selectGuestClubFlow, .selectHomeClubFlow:
                    locationOrClubSheet = true
                    locationSheetDetents = PresentationDetent.fraction(0.6)
                case .addEditClub:
                    locationSheetDetents = PresentationDetent.fraction(0.9)
                case .addEditLocation:
                    locationSheetDetents = PresentationDetent.fraction(1)
                case .selectLocationForEvent, .selectLocationForClub:
                    locationOrClubSheet = true
                    locationSheetDetents = PresentationDetent.fraction(0.9)
                }
            }
        }
    }
    @Published var locationOrClubSheet: Bool = false
    
    @Published var locationSheetDetents: PresentationDetent = PresentationDetent.fraction(0.6)
    
    @Published var eventDate: Date
    
    @Published var selectedTime: (Int,Int) = (1,1)
    
    @Published var isPresentedLogosSheet: Bool = false
    @Published var iSelectedHomeTeamLogo: Bool = false

    @Published var isPresentedDatePicker: Bool = false
    @Published var isPresentedTimePicker: Bool = false
    
    init(event: LocalEvent){
        self.event = event
        self.eventDate = event.viewRemainingDate
    }
    
    func updateDateWithDate(newDate: Date){
        event.date = newDate
        eventDate = newDate
        isPresentedDatePicker = false
    }
    
    func updateTimeWithDate(newDate: Date){
        event.date = newDate
        eventDate = newDate
        isPresentedTimePicker = false
    }
}
