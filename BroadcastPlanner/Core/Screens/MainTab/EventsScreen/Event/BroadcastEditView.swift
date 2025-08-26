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
#if DEBUG
        let _ = Self._printChanges()
#endif
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

                            //club/venue select/add/edit/remove sheet
                            
                                
                                //home team logo/selection action
                                LogoImageView(club: broadcast.homeClub,
                                              excludedClub: broadcast.guestClub,
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
                                              excludedClub: broadcast.homeClub,
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
                    Text("Owned by:")
                        .font(.system(size: 14))
                        .bold()
                    Menu {
                        ForEach(members){ member in
                            Button{
                                if !broadcast.viewOwners.contains(member){
                                    broadcast.addToOwners(member)
                                }
                            } label: {
                                HStack{
                                    Text("\(member.viewCompactName)")
                                    Spacer()
                                    if broadcast.viewOwners.contains(member){
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .padding(4)
                            .background(content: {
                                Circle().stroke(Color.white, lineWidth: 2)
                            })
                            .padding(4)
                            .frame(width: 30, height: 30)
                    }
                    ScrollView(.horizontal){
                        HStack(alignment: .center){
                            ForEach(broadcast.viewOwners){ owner in
                                LogoInWhiteRectView(id: owner.viewId)
                                    .frame(width: 30, height: 30)
                                    .contextMenu {
                                        Text("\(owner.viewCompactName)")
                                        Button{
                                            
                                        } label:{
                                            Text("Info")
                                        }
                                        Button{
                                            
                                        } label:{
                                            Text("Message")
                                        }
                                        Button{
                                            ownerToRemove = owner
                                            isRemoveFromOwners = true
                                        } label:{
                                            Text("Remove")
                                        }
                                    }
                            }
                        }
                        .padding(.leading,5)
                        .frame(height: 40)
                    }
                    
                }
                .frame(height: 40)
                .padding(.leading)
                
                
                //preview + fsc editStad / editCar  views
                HStack(spacing: 15) {
                    VStack(alignment: .leading){
                        GeometryReader{ geo in
                            let h = geo.size.height
                            ImageWrapper(id: broadcast.viewVenueSchemaPreviewId, type: .venuePreview, imageSize: .originImages)
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
                                                      y: 150 * (1 - memberToShow.viewY) - 2))
                            }
                        }
                        .frame(height: 150)
                        Divider()
                            .opacity(broadcast.viewVenuePoints.count > 0 ? 1 : 0)
                        //crews smart list
                        SmartCollection(hSpacing: 5, vSpacing: 5){
                            ForEach(broadcast.viewVenuePoints.sorted(by: { first, second in
                                first.number < second.number
                            })){ point in
                                LogoInWhiteRectView(id: point.viewMembers.first?.id ?? "")
                                    .frame(width: 30, height: 30)
                                    .contextMenu {
                                        Text("\(point.viewMembers.first?.viewCompactName ?? "empty position")")
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
                        ScrollView{
                            ForEach(broadcast.viewObvans.sorted(by: { first, second in
                                first.viewName < second.viewName
                            })) { obvan in
                                VStack{
                                    ImageWrapper(id: obvan.id, type: .obvan,imageSize: ImageSizes.smallImages)
                                        .scaledToFit()
                                        .onTapGesture {
                                            router.routeTo(path: .stadPointsEdit(broadcast))
                                        }
                                    SmartCollection(hSpacing: 5, vSpacing: 5){
                                        ForEach(broadcast.crewsForObvan(obvan: obvan)){ crew in
                                            LogoInWhiteRectView(id: crew.member?.id ?? "")
                                                .frame(width: 30, height: 30)
                                                .contextMenu {
                                                    Text("\(crew.viewPosition): \(crew.member?.viewCompactName ?? "")")
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
                                    Divider()
                                        .opacity(broadcast.viewObvans.count > 0 ? 1 : 0)
                                }
                            }
                        }
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
                    try dataManager.saveAndPublish(publish: .broadcasts,
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
