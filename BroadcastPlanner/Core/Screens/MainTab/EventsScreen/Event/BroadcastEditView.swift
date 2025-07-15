import Combine
import SpriteKit
import SwiftUI


final class BPCreateEditEventViewModel: ObservableObject{
    var homeClub: Club?
    var guestClub: Club?
    var eventDate: Date
    var location: Venue?
    
    init(event: Broadcast){
        if let club = event.homeClub{
            homeClub = club
        }
        if let club = event.guestClub{
            guestClub = club
        }
        if let location = event.venue{
            self.location = location
        }
        self.eventDate = event.date ?? Date()
    }
}

struct BroadcastEditView: View {
    let logoSize: Double = 90
    
    @StateObject private var vm: BPCreateEditEventViewModel
    
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    let broadcast: Broadcast

    @State private var isRemoveConfirm: Bool = false
     
    init(broadcast: Broadcast) {
        self._vm = StateObject(wrappedValue: BPCreateEditEventViewModel(event: broadcast))
        self.broadcast = broadcast
    }

    var body: some View {

        ZStack {
            MainBackground()

            VStack(alignment: .center, spacing: 5) {

                //header: time, date, teams, venue
                VStack{
                    ZStack{
                        LocationSelectionView(location: vm.location,
                                              offset: logoSize) {
                            
                        } acceptAction: { newLocation in
                            vm.location = newLocation
                        }
                       VStack(spacing: 5){
                            //team logos section
                            HStack(alignment: .top) {
                                //home team logo/selection action
                                LogoImageView(club: broadcast.homeClub,
                                              logoSize: logoSize,
                                              cancelAction: {},
                                              accessAction: { club in
                                    vm.homeClub = club
                                })
                                //broadcast date section
                                TimeAndDateSelectionView(date: vm.eventDate,
                                                         logoSize: logoSize) {newDate in
                                    vm.eventDate = newDate
                                }
                                //guest team logo/selection action
                                LogoImageView(club: broadcast.guestClub,
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
                    broadcast.viewVenueSchemaPreview
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            router.routeTo(path: .stadPointsEdit(broadcast))
                        }
                }
                .padding(.horizontal)
                Spacer()
            }
            .transitionWithOpacity()
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isRemoveConfirm) {
            Button("Delete Broadcast", role: .destructive){
                Task{
                   await dataManager.removeBroadcast(broadcast)
                    router.stepBack()
                }
            }
        }
        .onAppear{
            
            appState.primaryAction = {
                do{
                    broadcast.updateValues(date: vm.eventDate,
                                           lastUpdated: Date.now,
                                           homeClub: vm.homeClub,
                                           guestClub: vm.guestClub,
                                           venue: vm.location,
                                           in: dataManager.mainContext)
                    try dataManager.saveContext(publish: .broadcasts,
                                               id: [broadcast.viewId])
                } catch{
                    print("error save context: \(error.localizedDescription)")
                    //show error in 'status'
                    //log error
                }
                Task{
                    await dataManager.updateBroadcast(broadcast)
                }
                router.stepBack()
            }
            appState.secondaryAction = {
                isRemoveConfirm = true
            }
            appState.stepBackAction = {
                dataManager.rollBackMoc()
                router.stepBack()
            }
        }
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
