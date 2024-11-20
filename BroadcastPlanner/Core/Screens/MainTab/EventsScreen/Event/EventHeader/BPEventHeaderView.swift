import SwiftUI
import UIKit

struct BPEventHeaderView: View {
    @EnvironmentObject var router: EventTabRouter
    @EnvironmentObject var settings: GlobalSettings
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let logoSize: Double = 100
    let event: LocalEvent
        
    @State private var timerCounter: Int = 0
    @State private var imageIndex: Int = 0
    @State private var backImage: Image?
    
//    @State var newDate: Date = Date()
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

    @State private var isPresentedLocationSheet: Bool = false
    @State private var isPresentedAddEditLocation: Bool = false
    
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
                                iSelectedHomeTeamLogo = true
                                isPresentedLogosSheet = true
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
                                iSelectedHomeTeamLogo = false
                                isPresentedLogosSheet = true
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
                            isPresentedLocationSheet = true
                        }
                    
                    //address
                    Text(address)
                        .font(.footnote)
                        .lineLimit(2)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        .onTapGesture {
                            isPresentedLocationSheet = true
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
            .sheet(isPresented: $isPresentedLogosSheet, content: {
                ClubSheetView {
                    isPresentedLogosSheet.toggle()
                } acceptAction: { selectedClub in
                    //club accepted
                    if iSelectedHomeTeamLogo{
                        event.homeClub = selectedClub
                        homeImage = selectedClub.imageLogo?.mediumImage ?? Image(systemName: "plus")
                        if event.location == nil {
                            event.location = selectedClub.homeLocation
                        }
                    } else {
                        event.guestClub = selectedClub
                        guestImage = selectedClub.imageLogo?.mediumImage ?? Image(systemName: "plus")
                    }
                    isPresentedLogosSheet.toggle()
                    DataManager.shared.saveContext(type: .main, publish: .events, id: [])
                } createNewClubAction: {
                    isPresentedLogosSheet.toggle()
                    let newClub = DataManager.shared.fetchOrCreateClubWithId(UUID().uuidString, inContext: .main)
                    router.routeToAddEditClub(club: newClub)
                } editClubAction: { selectedClub in
                    isPresentedLogosSheet.toggle()
                    router.routeToAddEditClub(club: selectedClub)
                }
                .presentationBackground(.ultraThinMaterial)
                .presentationContentInteraction(.scrolls)
                .presentationDetents([.fraction(1)])
            })
            // TODO: add new location button and flow
            .sheet(isPresented: $isPresentedLocationSheet, content: {
                LocationSheetView(cancelAction: {
                    isPresentedLocationSheet.toggle()
                }, saveAction: {localLocation in
                    event.location = localLocation
                    isPresentedLocationSheet.toggle()
                })
                .padding()
                .presentationDetents([.fraction(0.6)])
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
        //timer control for background club images
            .onReceive(timer) { _ in
                timerCounter += 1
                if timerCounter > 8 {
                    timerCounter = 0
                    updateBackground()
                }
            }
            
    }

    //circular background
    func updateBackground(){
//        withAnimation(.linear(duration: 2)){
//            if event.eventLocation.imageStrings.isEmpty{
//                backImage = "neitral"
//            } else {
//                imageIndex += 1
//                if imageIndex < event.eventLocation.imageStrings.count{
//                    backImage = event.eventLocation.imageStrings[imageIndex]
//                } else {
//                    imageIndex = 0
//                    backImage = event.eventLocation.imageStrings[imageIndex]
//                }
//            }
//        }
    }

}

#Preview {
        MainEventsList()
        .environmentObject(GlobalSessionStorage())
        .environmentObject(GlobalSettings())
        .environment(\.managedObjectContext, DataManager.shared.moc)
}

//#Preview {
//    BPEventHeaderView(event: LocalEvent(context: DataManager.preview.moc)
//    )
//    .environmentObject(GlobalSettings())
//    .environmentObject(GlobalSessionStorage())
//    .environmentObject(EventTabRouter())
//}

//#Preview {
//    NavigationStack{
//        BPCreateEditEventView(event: LocalEvent(context: DataManager.shared.moc))
//    }
//            .environmentObject(GlobalSettings())
//            .environmentObject(GlobalSessionStorage())
//            .environmentObject(EventTabRouter())
//            .environment(\.managedObjectContext, DataManager.shared.moc)
//}
