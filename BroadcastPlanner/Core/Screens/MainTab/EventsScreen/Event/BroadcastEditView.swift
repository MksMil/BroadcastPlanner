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
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var mdm: DataManager
    
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
                ConfirmationButtonGroupView(height: 50, isAcceptDisabled: false)
                {
                    do{
                        mdm.rollBackMoc()
//                        try mdm.saveContext(publish: .broadcasts, id: [])
                        router.routeStepBack()
                    } catch{
                    print("cant roll back")
                    }
                } acceptAction: {
                    do{
                        broadcast.updateValues(date: vm.eventDate,
                                               lastUpdated: Date.now,
                                               homeClub: vm.homeClub,
                                               guestClub: vm.guestClub,
                                               venue: vm.location,
                                               in: mdm.mainContext)
                        try mdm.saveContext(publish: .broadcasts,
                                            id: [broadcast.viewId])
                    } catch{
                        print("error save context: \(error.localizedDescription)")
                        //show error in 'status'
                        //log error
                    }
                    Task{
                        await mdm.updateBroadcast(broadcast)
                    }
                    router.routeStepBack()
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
                //header: time, date, teams, venue
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
//                            eventRouter.routeToStadPointsEdit()
                        }
//                    broadcast.viewObvanPreview
//                        .resizable()
//                        .scaledToFit()
//                        .scaleEffect(0.5)
//                        .rotationEffect(Angle(degrees: -90))
//                        .onTapGesture {
//                        }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)

        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isRemoveConfirm) {
            Button("Delete Broadcast", role: .destructive){
                Task{
//                    await mdm.removeEvent(event: broadcast)
//                    eventRouter.routeStepBack()
                   await mdm.removeBroadcast(broadcast)
                    router.routeStepBack()
                    
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}
