import Combine
import SpriteKit
import SwiftUI

struct BroadcastEditView: View {
    let logoSize: Double = 90
        
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    let broadcast: Broadcast

    @State private var isRemoveConfirm: Bool = false

    var body: some View {

        ZStack {
            MainBackground()

            VStack(alignment: .center, spacing: 5) {

                //header: time, date, teams, venue
                VStack{
                    ZStack{
                        LocationSelectionView(location: broadcast.venue,
                                              offset: logoSize) {
                            
                        } acceptAction: { newVenue in
                            broadcast.venue = newVenue
                        }
                       VStack(spacing: 5){
                            //team logos section
                            HStack(alignment: .top) {
                                //home team logo/selection action
                                LogoImageView(club: broadcast.homeClub,
                                              logoSize: logoSize,
                                              cancelAction: {},
                                              accessAction: { club in
                                    broadcast.homeClub = club
                                })
                                //broadcast date section
                                TimeAndDateSelectionView(date: broadcast.viewDate,
                                                         logoSize: logoSize) {newDate in
                                    broadcast.date = newDate
                                }
                                //guest team logo/selection action
                                LogoImageView(club: broadcast.guestClub,
                                              logoSize: logoSize,
                                              cancelAction: {},
                                              accessAction: { club in
                                    broadcast.guestClub = club
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
//                            try? dataManager.mainContext.save()
                            router.routeTo(path: .stadPointsEdit(broadcast))
                        }
//                    broadcast.viewObvanPreview
//                        .resizable()
//                        .scaledToFit()
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
