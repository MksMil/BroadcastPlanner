import Combine
import SpriteKit
import SwiftUI


final class BPCreateEditEventViewModel: ObservableObject{
    var homeClub: LocalClub?
    var guestClub: LocalClub?
    var eventDate: Date
    var location: LocalLocation?
    
    init(event: LocalEvent){
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
    
    let event: LocalEvent

    @State private var isRemoveConfirm: Bool = false
    
//    @FetchRequest<LocalUser>(sortDescriptors: []) private var users
 
    init(event: LocalEvent) {
        self._vm = StateObject(wrappedValue: BPCreateEditEventViewModel(event: event))
        self.event = event
    }
    
    var editable: Bool {
//        event.viewOwners.contains(where: { $0.userId == mdm.currentId})
        true
    }

    var body: some View {

        ZStack {
            MainBackground()
//            Color.randomColor()

            VStack(alignment: .center, spacing: 5) {
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
                            eventRouter.routeToStadPointsEdit(editable: editable)
                        }
                    event.viewObvanPreview
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.5)
//                        .rotationEffect(Angle(degrees: -90))
                        .onTapGesture {
                            eventRouter.routeToCarPointsEdit(editable: editable)
                        }
                }
                .padding(.horizontal)
//                .border(.red, width: 2)
                
                Spacer()
            }
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editable)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.white.opacity(0.4), for: .navigationBar)
        .toolbar {
            if editable {
                //save event and dismiss screen
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        mdm.updateEvent(event,
                                        homeClub: vm.homeClub,
                                        guestClub: vm.guestClub,
                                        eventDate: vm.eventDate,
                                        location: vm.location)
                        eventRouter.routeStepBack()
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    // TODO: 'Delete' Confirmation (Alert?)
                    Button {
                        isRemoveConfirm = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            } else {
                //back to eventList if !editMode
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        Task {
                            eventRouter.routeStepBack()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isRemoveConfirm) {
            Button("Delete Event", role: .destructive){
                mdm.removeEvent(event: event)
                eventRouter.routeStepBack()
            }
        }
    }
}

#Preview {
        let lm = DataManager(forPreview: true)
        let mdm = MainDataManager(localDataManager: lm, globalDataManager: NetworkManager(),userId: "123")
        let localEvent = lm.fetchOrCreateObject(ofType: LocalEvent.self,
                      predicate: NSPredicate(format: "id == %@", "id"),
                                          in: lm.moc) {
            let newEvent = LocalEvent(context: lm.moc)
            newEvent.id = "id"
            return newEvent
        }
    
        return BPCreateEditEventView(event: localEvent)
        .environmentObject(SessionManager())
        .environmentObject(GlobalSettings())
        .environmentObject(EventTabRouter())
        .environment(\.managedObjectContext, mdm.localDataManager.moc)
        .environmentObject(mdm)
}
