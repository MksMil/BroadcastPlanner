import Combine
import SpriteKit
import SwiftUI


final class BPCreateEditEventViewModel: ObservableObject{
    var homeClub: Club?
    var guestClub: Club?
    var eventDate: Date
    var location: Location?
    
    init(event: Event){
        if let club = event.homeClub{
            homeClub = club
        }
        if let club = event.guestClub{
            guestClub = club
        }
        if let location = event.location{
            self.location = location
        }
        self.eventDate = event.date ?? Date()
    }
}

struct BPCreateEditEventView: View {
    let logoSize: Double = 90
    
    @StateObject private var vm: BPCreateEditEventViewModel
    
    @EnvironmentObject var eventRouter: EventTabRouter
    @EnvironmentObject var mdm: MainDataManager
    
    let event: Event

    @State private var isRemoveConfirm: Bool = false
    
//    @FetchRequest<LocalUser>(sortDescriptors: []) private var users
 
    init(event: Event) {
        self._vm = StateObject(wrappedValue: BPCreateEditEventViewModel(event: event))
        self.event = event
    }

    var body: some View {

        ZStack {
            MainBackground()
//            Color.randomColor()

            VStack(alignment: .center, spacing: 5) {
                ConfirmationButtonGroupView(height: 50, isAcceptDisabled: false)
                {
                    Task {
                        eventRouter.routeStepBack()
                        mdm.rollBackMoc()
                    }
                } acceptAction: {
                    Task{
                        await mdm.updateEvent(event,
                                              homeClub: vm.homeClub,
                                              guestClub: vm.guestClub,
                                              eventDate: vm.eventDate,
                                              location: vm.location)
                        eventRouter.routeStepBack()
                    }

                } content: {
                    Button {
                        isRemoveConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .bold()
                            .padding(50 / 4)
                            .frame(width: 150,height: 50)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.ultraThickMaterial
                                        .opacity(0.3))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(
                                                .ultraThickMaterial
                                                .opacity(0.5),
                                                    lineWidth: 2)
                                    }
                            }
                    }
                }
                .padding(.horizontal)
                //header: time, date, teams, location
                VStack{
                    ZStack{
                        LocationSelectionView(location: vm.location, offset: logoSize) {
                            
                        } acceptAction: { newLocation in
                            vm.location = newLocation
                        }
                       VStack(spacing: 5){
                            //team logos section
                            HStack(alignment: .top) {
                                //home team logo/selection action
                                LogoImageView(club: event.homeClub,
                                              logoSize: logoSize,
                                              cancelAction: {},
                                              accessAction: { club in
                                    vm.homeClub = club
                                })
                                //event date section
                                TimeAndDateSelectionView(date: vm.eventDate,
                                                         logoSize: logoSize) {newDate in
                                    vm.eventDate = newDate
                                }
                                //guest team logo/selection action
                                LogoImageView(club: event.guestClub,
                                              logoSize: logoSize,
                                              cancelAction: {},
                                              accessAction: { club in
                                    vm.guestClub = club
                                })
                            }
                            .padding(.top)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .frame(height: 300)
                
                //preview + fsc editStad / editCar  views
                HStack(spacing: 15) {
                    event.viewLocationPreview
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            eventRouter.routeToStadPointsEdit()
                        }
                    event.viewObvanPreview
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.5)
                        .rotationEffect(Angle(degrees: -90))
                        .onTapGesture {
                            eventRouter.routeToCarPointsEdit(editable: true)
                        }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)

        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isRemoveConfirm) {
            Button("Delete Event", role: .destructive){
                Task{
                    await mdm.removeEvent(event: event)
                    eventRouter.routeStepBack()
                }
            }
        }
    }
}
//
//#Preview {
//        let lm = DataManager(forPreview: true)
//        let mdm = MainDataManager(localDataManager: lm, globalDataManager: NetworkManager(),userId: "123")
//        let localEvent = lm.fetchOrCreateObject(ofType: Event.self,
//                      predicate: NSPredicate(format: "id == %@", "id"),
//                                          in: lm.mainContext) { ctx in
//            let newEvent = Event(context: ctx)
//            newEvent.id = "id"
//            return newEvent
//        }
//    
//        return BPCreateEditEventView(event: localEvent)
//        .environmentObject(SessionManager())
//        .environmentObject(GlobalSettings())
//        .environmentObject(EventTabRouter())
//        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
//        .environmentObject(mdm)
//}

#Preview {
    Home(localDataManager: DataManager(forPreview: false),
         globalDataManager: NetworkManager(),
         userId: "123"
    )
    .environmentObject(GlobalSettings())
    .environmentObject(SessionManager())
    .environmentObject(ApplicationState())
}
