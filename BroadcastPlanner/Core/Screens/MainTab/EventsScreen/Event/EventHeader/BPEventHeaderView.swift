import SwiftUI
import UIKit

final class BPEventHeaderViewModel: ObservableObject{
    @Published var locationEditState: Bool = false{
        didSet{
            withAnimation{
                locationSheetDetents = locationEditState ? PresentationDetent.fraction(0.9):PresentationDetent.fraction(0.6)
            }
        }
    }
    
    //publish?
    @Published var state: SheetState = .none {
        didSet{
            withAnimation{
                switch state {
                case .none:
                    locationOrClubSheet = false
                case .selectGuestClubFlow, .selectHomeClubFlow:
                    locationSheetDetents = PresentationDetent.fraction(0.6)
                case .selectLocationForEvent, .selectLocationForClub:
                    locationSheetDetents = PresentationDetent.fraction(0.9)
                }
            }
        }
    }
    @Published var locationOrClubSheet: Bool = false
    @Published var locationSheetDetents: PresentationDetent = PresentationDetent.fraction(0.6)
}


enum SheetState: Identifiable {
    case selectHomeClubFlow
    case selectGuestClubFlow
    case selectLocationForEvent
    case selectLocationForClub
    case none
    
    var id:Self { self }
}

struct BPEventHeaderView: View {
    @EnvironmentObject var router: EventTabRouter
    @EnvironmentObject var settings: GlobalSettings
    
    @StateObject var vm: BPEventHeaderViewModel = BPEventHeaderViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let logoSize: Double = 100
    let event: LocalEvent
        
    @State private var timerCounter: Int = 0
    @State private var imageIndex: Int = 0
    @State private var backImage: Image?
    
    @State var eventDate: Date = Date()
    
    @State private var selectedTime: (Int,Int) = (1,1)
    
    @State private var homeImage: Image
    @State private var guestImage: Image
    @State var stadium: String = ""
    @State private var address: String = ""
    
    @State private var isPresentedLogosSheet: Bool = false
    @State private var iSelectedHomeTeamLogo: Bool = false

    @State private var isPresentedDatePicker: Bool = false
    @State private var isPresentedTimePicker: Bool = false

//    @State private var isPresentedLocationSheet: Bool = false
//    @State private var isPresentedAddEditLocation: Bool = false
    
    @Namespace var ns
    @Namespace var min
    
    let dateRange: PartialRangeFrom<Date> = {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year,.month,.day], from: .now)
        return calendar.date(from:startComponents)!...
    }()
    
    init(event: LocalEvent, routeAction: @escaping ()->Void) {
        self.event = event
        self._eventDate = State(initialValue: event.viewRemainingDate)
//        self.routeAction = routeAction
        self._homeImage = State(wrappedValue: event.homeImage)
        self._guestImage = State(wrappedValue: event.guestImage)
    }
 
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack(spacing: 20){
             //team logos section
                
                HStack(alignment: .top){
                        
                    LogoImageView(image: homeImage,
                                  logoSize: logoSize)
                            .onTapGesture {
                                vm.state = .selectHomeClubFlow
                                vm.locationOrClubSheet.toggle()
                            }
                        
                    VStack(spacing: 40){
                            Text(eventDate.formatted(date: .abbreviated, time: .omitted))
                                .fixedSize()
                                .font(.subheadline)
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                                }
                                .onTapGesture {
                                    isPresentedDatePicker = true
                                }
                            
                            Text(eventDate.formatted(date: .omitted, time: .shortened))
                                .frame(width: logoSize)
                                .font(.title)
                                .padding(.vertical,5)
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                                }
                                .onTapGesture {
                                    isPresentedTimePicker = true
                                }
                        }
                        
                    LogoImageView(image: guestImage, logoSize: logoSize)
                            .onTapGesture {
                                vm.state = .selectGuestClubFlow
                                vm.locationOrClubSheet.toggle()
                            }
                    }
                    .padding(.top, 25)
            
            //location description action
                VStack(spacing: 20) {
                    // stadium name
                    Text(stadium)
                        .font(.title2)
                        .lineLimit(2)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        .onTapGesture {
                            vm.state = .selectLocationForEvent
                            vm.locationOrClubSheet.toggle()
                        }
                    
                    //address
                    Text(address)
                        .font(.footnote)
                        .lineLimit(2)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        .onTapGesture {
                            vm.state = .selectLocationForEvent
                            vm.locationOrClubSheet.toggle()
                        }
                }
                Spacer()
            }

            .background {
                // TODO: change image animation problem
                Image("neitral")
                    .resizable()
                    .scaledToFill()
//                    .animation(.easeInOut(duration: 1),
//                               value: backImage)
                    .mask {Rectangle().fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .black,
                                .black,
                                .black.opacity(0.65),
                                .black.opacity(0.85),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    }
            }
            // TODO: add new team and logo button and flow
//            .sheet(isPresented: $isPresentedLogosSheet, content: {
//                ClubSheetView {
//                    isPresentedLogosSheet.toggle()
//                } acceptAction: { selectedClub in
//                    //club accepted
//                    if iSelectedHomeTeamLogo{
//                        event.homeClub = selectedClub
//                        homeImage = selectedClub.imageLogo?.mediumImage ?? Image(systemName: "plus")
//                        if event.location == nil {
//                            event.location = selectedClub.homeLocation
//                        }
//                    } else {
//                        event.guestClub = selectedClub
//                        guestImage = selectedClub.imageLogo?.mediumImage ?? Image(systemName: "plus")
//                    }
//                    isPresentedLogosSheet.toggle()
//                } defineLocation: {_ in }
//                .presentationBackground(.ultraThinMaterial)
//                .presentationContentInteraction(.scrolls)
//                .presentationDetents([.fraction(1)])
//            })
//            // TODO: add new location button and flow
//            .sheet(isPresented: $isPresentedLocationSheet, content: {
//                LocationFlow(isEditMode: $vm.locationEditState) {
//                    isPresentedLocationSheet.toggle()
//                } acceptAction: { localLocation in
//                    event.location = localLocation
//                    isPresentedLocationSheet.toggle()
//                }
////                Button("change state", action: {
////                    vm.locationEditState.toggle()
////                })
//                .padding()
//                .presentationDetents([.fraction(0.6), .fraction(0.9)],selection: $vm.locationSheetDetents)
//            })
            .sheet(isPresented: $vm.locationOrClubSheet, content: {
                EventHeaderSheet(state: $vm.state, event: event)
                .presentationBackground(.ultraThinMaterial)
                .presentationContentInteraction(.scrolls)
                .presentationDetents([.fraction(0.6), .fraction(0.9)],selection: $vm.locationSheetDetents)
            })
            //date picker sheet
            .sheet(isPresented: $isPresentedDatePicker, content: {
                DateEditView(newDate: eventDate) {
                    isPresentedDatePicker = false
                } acceptAction: { newDate in
                    event.date = newDate
                    eventDate = newDate
                    isPresentedDatePicker = false
                }
                .padding(.horizontal)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.65)])
            })
            //time picker
            .sheet(isPresented: $isPresentedTimePicker, content: {
                TimeEditView(newDate: eventDate) {
                    isPresentedTimePicker = false
                } acceptAction: { newDate in
                    event.date = newDate
                    eventDate = newDate
                    isPresentedTimePicker = false
                }
                .padding(.horizontal)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.5)])
            })
//            .task{
//                Task{
//                    let images = await DataManager.shared.fetchImagesByType(GlobalProperties.ImageType.location.rawValue, inContext: .main)
//                    for image in images {
//                        DataManager.shared.removeLocalImage(image, inContext: .main)
//                        print("deleted")
//                        DataManager.shared.saveContext(type: .main, publish: .none, id: [])
//                    }
//                }
//                
//            }
}
}

//#Preview {
//        MainEventsList()
//        .environmentObject(GlobalSessionStorage())
//        .environmentObject(GlobalSettings())
//        .environment(\.managedObjectContext, DataManager.shared.moc)
//}

//#Preview {
//    BPEventHeaderView(event: LocalEvent(context: DataManager.preview.moc)
//    )
//    .environmentObject(GlobalSettings())
//    .environmentObject(GlobalSessionStorage())
//    .environmentObject(EventTabRouter())
//}

#Preview {
    NavigationStack{
        BPCreateEditEventView(event: LocalEvent(context: DataManager.shared.moc))
    }
            .environmentObject(GlobalSettings())
            .environmentObject(GlobalSessionStorage())
            .environmentObject(EventTabRouter())
            .environment(\.managedObjectContext, DataManager.shared.moc)
}
