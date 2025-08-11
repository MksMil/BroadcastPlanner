import Combine
import SpriteKit
import SwiftUI

struct ImageWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

struct BroadcastEditView: View {
    let logoSize: Double = 90
        
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    let broadcast: Broadcast

    @State private var isBroadcastRemoveConfirm: Bool = false
    @FetchRequest<Member>(sortDescriptors: []) var members
    
    @State private var isRemoveFromOwners: Bool = false
    @State private var ownerToRemove: Member?
    @State private var memberToShow: VenuePoint?

    @State private var imageWidth: CGFloat = .infinity
    
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
//                            .padding(.top)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .frame(height: 250)
                
                HStack(spacing: 3){
                    Text("Managed by: ")
                        .font(.system(size: 14))
                        .bold()
                    Menu {
                        ForEach(members){ member in
                            Button("\(member.viewCompactName)") {
                                if !broadcast.viewOwners.contains(member){
                                    broadcast.addToOwners(member)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .padding(10)
                            .background(content: {
                                Circle().stroke(Color.white, lineWidth: 2)
                            })
                            .frame(width: 40, height: 40)
                    }

                    ForEach(broadcast.viewOwners){ owner in
                        LogoInWhiteCircleView(image: owner.viewImage)
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                ownerToRemove = owner
                                isRemoveFromOwners = true
                            }
                            
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                
                //preview + fsc editStad / editCar  views
                HStack(spacing: 15) {
                    VStack(alignment: .leading){
                        GeometryReader{ geo in
                            let h = geo.size.height
                            broadcast.viewVenueSchemaPreview
                                .resizable()
                                .scaledToFit()
                                .frame(height: h)
                                .background(
                                    GeometryReader { imageGeometry in
                                        Color.clear
                                            .preference(
                                                key: ImageWidthPreferenceKey.self,
                                                value: imageGeometry.size.width
                                            )
                                    }
                                )
                        }
                        
                        .onPreferenceChange(ImageWidthPreferenceKey.self) { newWidth in
                            if let newWidth, newWidth > 0, newWidth.isFinite{
                                imageWidth = newWidth
                            }
                        }
                        .onTapGesture {
                            router.routeTo(path: .stadPointsEdit(broadcast))
                        }
                        .overlay {
                            if let memberToShow{
                                Circle().stroke(Color.red, lineWidth: 1)
                                    .frame(width: 15, height: 15)
                                    .scaleEffect(memberToShow.viewScaleFactor)
                                    .position(CGPoint(x: imageWidth * memberToShow.viewX ,
                                                      y: 150 * (1 - memberToShow.viewY)))
                            }
                        }
                        .frame(height: 150)
                        Divider()
                            .opacity(broadcast.viewVenuePoints.count > 0 ? 1 : 0)
                        //crews smart list
                        SmartLayout(hSpacing: 5, vSpacing: 5){
                            ForEach(broadcast.viewVenuePoints.sorted(by: { first, second in
                                first.number < second.number
                            })){ point in
                                Rectangle().fill(Color.clear)
                                    .overlay {
                                        LogoInWhiteCircleView(image: point.viewMembers.first?.viewImage ?? Image(systemName: "person"))
                                            .padding(3)
                                    }
                                    .frame(width: 30, height: 30)
                                    .contextMenu {
                                        Button{
                                            
                                        } label:{
                                            Text("Info")
                                        }
                                        Button{
                                            
                                        } label:{
                                            Text("Message")
                                        }
                                    }
                                    .onTapGesture {
                                        memberToShow = memberToShow == point ? nil: point
                                    }
                                    .scaleEffect(point == memberToShow ? 1.05 : 0.95)
                                    .opacity(point == memberToShow ? 1 : 0.75)
                                    
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: imageWidth)
                    .layoutPriority(2)
                    Divider()
                    VStack(alignment: .leading){
                        VStack{
                            ForEach(broadcast.viewObvans) { obvan in
                                obvan.viewImage
                                    .resizable()
                                    .scaledToFit()
//                                    .border(Color.green)
                                    .onTapGesture {
                                        router.routeTo(path: .stadPointsEdit(broadcast))
                                    }
                            }
                        }
//                        .frame(height: 150)
                        Divider()
                            .opacity(broadcast.viewObvans.count > 0 ? 1 : 0)
                        ScrollView{
                            SmartLayout(hSpacing: 5, vSpacing: 5){
                                ForEach(broadcast.viewCrews.filter({ crew in
                                    crew.member != nil
                                })){ crew in
                                    let _ = print(broadcast.viewCrews.count)
                                    LogoInWhiteCircleView(image: crew.member?.viewImage ?? Image(systemName: "person"))
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                        .background(content: {
                                            RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.4))
                                        })
                                        .contextMenu {
                                            Button{
                                                
                                            } label:{
                                                Text("Info")
                                            }
                                            Button{
                                                
                                            } label:{
                                                Text("Message")
                                            }
                                        }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .frame(maxWidth: imageWidth)
                    .layoutPriority(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                Spacer()
            }
            .transitionWithOpacity()
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isBroadcastRemoveConfirm) {
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
                isBroadcastRemoveConfirm = true
            }
            appState.stepBackAction = {
               
            }
        }
        .confirmationDialog("Remove", isPresented: $isRemoveFromOwners) {
            Button("Remove  \(ownerToRemove?.viewCompactName ?? "") from owners?", role: .destructive) {
                if let ownerToRemove, broadcast.viewOwners.count > 1 {
                    broadcast.removeFromOwners(ownerToRemove)
                    self.ownerToRemove = nil
                }
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
