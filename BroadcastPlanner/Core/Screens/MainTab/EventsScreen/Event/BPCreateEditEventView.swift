import Combine
import SpriteKit
import SwiftUI

final class BPCreateEditEventViewModel: ObservableObject{
    let event: LocalEvent
    
    var homeClub: LocalClub?
    var guestClub: LocalClub?
    var eventDate: Date
    var location: LocalLocation?
    var user: LocalUser
    
    
    init(event: LocalEvent, user: LocalUser) {
        self.event = event
        if let club = event.homeClub{
            homeClub = club
        }
        if let club = event.guestClub{
            guestClub = club
        }
        if let location = event.location{
            self.location = location
        }
        self.user = user
        self.eventDate = event.date ?? Date()
    }

    @MainActor
    func updateEvent(){
        DataManager.shared.moc.perform { [weak self] in
            guard let self else { return }
            self.event.homeClub = self.homeClub
            self.event.guestClub = self.guestClub
            self.event.date = self.eventDate
            self.event.location = self.location
            self.event.addToOwners(user)
            Task{
                await DataManager.shared.saveContext(type: .main, publish: .events, id: [self.event.viewId])
            }
        }
        Task{
            await NetworkManager.shared.saveEvent(BPEvent.mapLocalEventToEvent(localEvent: event))
        }
    }
    
    @MainActor
    func removeEvent(){
        Task {
            // TODO: handle in vm
            await  NetworkManager.shared.removeEventWithId(event.viewId)
            DataManager.shared.removeLocalEvent(
                event,
                inContext: .main)
            await DataManager.shared.saveContext(
                type: .main,
                publish: .events,
                id: [])
        }
    }
    
}


struct BPCreateEditEventView: View {
    let logoSize: Double = 90
    @EnvironmentObject var eventRouter: EventTabRouter
    @StateObject var editManager: BPEditStadiumViewModel = BPEditStadiumViewModel()
    @StateObject var vm: BPCreateEditEventViewModel

    let event: LocalEvent

    
    
    init(event: LocalEvent,userId: String) {
        self._vm = StateObject(wrappedValue: BPCreateEditEventViewModel(event: event, userId: userId))
        self.event = event
    }
    
    var editable: Bool {
        //        event.owners.contains { $0 == globalStorage.id }
//        false
        true
    }

    @FetchRequest<LocalUser>(sortDescriptors: []) private var users

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        ZStack {
            MainBackground()
//            Color.randomColor()

            VStack(alignment: .center, spacing: 5) {
                //header: time, date, teams, location
                ZStack{
                    LocationSelectionView(location: vm.location) {
                        
                    } acceptAction: { newLocation in
                        vm.location = newLocation
                    }


                    VStack(alignment: .center, spacing: 5){
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
                                print("now eventdate is \(vm.eventDate.formatted())")
                            }
                            //guest team logo/selection action
                            LogoImageView(club: event.guestClub,
                                          logoSize: logoSize,
                                          cancelAction: {},
                                          accessAction: { club in
                                vm.guestClub = club
                            })
                            .background {
//                                Color.randomColor()
                            }
                        }
                        .padding(.top)
                        Spacer()
                    }
                    .padding()
            }

                //preview + fsc editStad / editCar  views
                GeometryReader { geo in
                    HStack(spacing: 15) {
                        event.viewLocationPreview
                            .resizable()
                            .scaledToFit()
                            .frame(width: 3 * geo.size.width / 4)
                            .onTapGesture {
//                                type = .stadium
                                eventRouter.routeToStadPointsEdit(event: event, editable: editable)
                            }
                        event.viewObvanPreview
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(Angle(degrees: -90))
                            .onTapGesture {
                                eventRouter.routeToCarPointsEdit()
                            }
                    }
                    .frame(height: geo.size.width / 2)
                    .padding(.horizontal)
                }

                //staff list
                //                    EventUsersGridView(users: users,
                //                                       images: globalStorage.usersImages)
                // TODO: (struct: Hashable, id: comb(name+num)) for the grid !?!
                ScrollView {
                    //                        SmartLayout(hSpacing: 5, vSpacing: 5){
                    //                            ForEach(users){ user in
                    ////                                if let image = listUsers[user]{
                    ////                                    BPUserDataListCellView(text: user,
                    ////                                                           image: image)
                    ////                                } else {
                    //                                BPUserDataListCellView(user: user, text: "text")
                    ////                                }
                    //                            }
                    //                        }
                }
                .padding(.horizontal, 10)
                Spacer()
            }
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editable)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            if editable {
                //save event and dismiss screen
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        vm.updateEvent()
                        eventRouter.routeStepBack()
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    // TODO: 'Delete' Confirmation (Alert?)
                    Button {
                        vm.removeEvent()
                        eventRouter.routeStepBack()
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
        .task {
            editManager.configureWith(event: event)
        }
        
        .environmentObject(editManager)
    }
}

#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")
   NavigationStack {
        BPCreateEditEventView(
            event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main), userId: "123")
    }
    .environmentObject(SessionManager())
    .environmentObject(GlobalSettings())
    .environmentObject(EventTabRouter())
    .environment(\.managedObjectContext, mdm.localDataManager.moc)
}
