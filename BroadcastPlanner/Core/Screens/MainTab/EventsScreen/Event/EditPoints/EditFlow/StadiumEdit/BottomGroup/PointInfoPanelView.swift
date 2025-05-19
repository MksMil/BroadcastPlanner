import SwiftUI


enum StadiumPointFilterCase: String, Customfilter{
    case users = "person"
    case cam = "video.fill"
    case mic = "mic.circle"
    case light = "warninglight"
    
    var id: Self { self }
}

// MARK: - PointInfoPanelViewModel
final class PointInfoPanelViewModel: ObservableObject {
    // MARK: - vm Properties
    @Published var users: [LocalUser] = []
    @Published var num: Int = 0
    @Published var description: String = "Choose position"
    @Published var cameras: [Camera] = []
    @Published var sounds: [Sound] = []
    @Published var lights: [Light] = []
    
    
   
//    var selectedPoint: LocalLocationPoint?
    @Published var selectedFilter: StadiumPointFilterCase = .users
    
    // MARK: - vm init
    init(point: LocationPoint?){
//        self.selectedPoint = point
        update(point: point)
    }
    
    func update(point: LocationPoint?){
        if let point {
            self.users = point.viewUsers
            self.num = point.viewNumber
            self.description = point.viewDescription
            self.cameras = point.viewLocalCameras
            self.sounds = point.viewLocalSounds
            self.lights = point.viewLocalLights
        }
    }
    
    func addUser(user: LocalUser){
        if !users.contains([user]) {
            users.append(user)
        } else {
//            print("this user: \(user.userLastName) exist in point")
        }
    }
    
    func removeUser(user: LocalUser){
        users.removeAll(where: {$0 == user})
    }
    
    func acceptNubmer(num: Int){
        self.num = num
    }
    
    func addCam(cam: Camera){
        cameras.append(cam)
    }
    
    func removeCamera(cam: Camera){
        cameras.removeAll(where: {$0 == cam})
    }
    
    func addSound(sound: Sound){
       
        sounds.append(sound)
    }
    
    func removeSound(sound: Sound){
        sounds.removeAll(where: {$0 == sound})
    }
    
    func addLight(light: Light){
        lights.append(light)
    }
    
    func removeLight(light: Light){
        lights.removeAll(where: {$0 == light})
    }
    
    func addDescription(desc: String){
        self.description = desc
    }
}

struct PointInfoPanelView: View {
    //can be changed from settings ? !
    // MARK: - Properties
    var maxCam: Int = 21
    
    @StateObject var vm: PointInfoPanelViewModel
    
    @EnvironmentObject var pointManager: BPEditStadiumViewModel
    @EnvironmentObject var mdm: MainDataManager
    //sort users
    @FetchRequest<LocalUser>(sortDescriptors: []) var availableUsers
    @State private var selectedFilter: StadiumPointFilterCase = .users
    @State var selectedNumber: Int = 1
    
    @State var numPopover: Bool = false
    @Namespace var ns
    // MARK: - Init
    init(point: LocationPoint?) {
        self._vm = StateObject(wrappedValue: PointInfoPanelViewModel(point: point))
        //        self.point = point
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 5) {
            //number position stack
            HStack(alignment: .center) {
                //                    //point number
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 45)
                    .overlay(content: {
                        Circle().stroke(.ultraThickMaterial)
                    })
                    .overlay {
                        Text(vm.num == 0 ? "-": String(vm.num))
                            .font(.title)
                            .bold()
                            .foregroundStyle(.black)
                    }
                    .onTapGesture {
                        numPopover.toggle()
                    }
                    .popover(isPresented: $numPopover){
                        SmartLayout(hSpacing: 10, vSpacing: 10) {
                            ForEach(1..<maxCam, id: \.self) { num in
                                Button{
                                    withAnimation{
                                        vm.acceptNubmer(num: num)
                                        Task{
                                            await mdm.updatePoint(pointManager.selectedEventPoint, withNumber: num)
                                            pointManager.acceptNubmer(num: num)
                                            numPopover.toggle()
                                        }
                                    }
                                } label: {
                                    Circle()
                                        .fill(.white.opacity(0.4))
                                        .frame(width: 40)
                                        .overlay(content: {
                                            Circle().stroke(.ultraThickMaterial)
                                        })
                                        .overlay {
                                            Text(String(num))
                                                .font(.callout)
                                                .bold()
                                                .foregroundStyle(.black)
                                        }
                                }
                            }
                        }
                        .frame(width:200)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                        .presentationBackground(Color("MainBackgroundColor").opacity(0.5))
                        
                    }
                //point position
                Menu {
                    ForEach(
                        CameraPosition.allCases.sorted(by: {
                            $0.rawValue > $1.rawValue
                        })
                    ) { position in
                        
                        Button {
                            vm.addDescription(desc: position.rawValue)
                            Task{
                                await mdm.updatePoint(pointManager.selectedEventPoint, withDescription: position.rawValue)
                                pointManager.addDescription(desc: position.rawValue)
                            }
                        } label: {
                            Text(position.rawValue)
                        }
                    }
                } label: {
                    Text(vm.description)
                        .font(.callout)
                        .minimumScaleFactor(0.1)
                        .lineLimit(2)
                }
                .font(.caption)
                .menuStyle(.button)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            
            //user section
            BPEventFilterCaseTabView(selectedTab: $selectedFilter){}
                .frame(height: 45)
//            VStack {
//                switch vm.selectedFilter {
//                    case .users:
//                        PanelUserCollectionView(users: vm.users,
//                                                availableUsers: mappedUsers()){ user in
//                            vm.addUser(user: user)
//                            Task{
//                                await mdm.addUser(user,toPoint: pointManager.selectedEventPoint)
//                                pointManager.addUser(user: user)
//                            }
//                        } removeAction: { user in
//                            vm.removeUser(user: user)
//                            Task{
//                                await mdm.removeUser(user,
//                                                     fromPoint: pointManager.selectedEventPoint)
//                                pointManager.removeUserFromPoint(user: user)
//                            }
//                        }
//                    case .cam:
//                        PanelCameraCollectionView(cameras: vm.cameras) { cam in
//                            vm.addCam(cam: cam)
//                            Task{
//                                await mdm.updatePoint(pointManager.selectedEventPoint, withCamera: cam)
//                                pointManager.addCam(cam: cam)
//                            }
//                            
//                        } removeAction: { cam in
//                            vm.removeCamera(cam: cam)
//                            Task{
//                                await mdm.removeCamera(cam, fromPoint: pointManager.selectedEventPoint)
//                                pointManager.removeCameraFromPoint(camera: cam)
//                            }
//                        }
//                    case .mic:
//                        PanelSoundCollectionView(sounds: vm.sounds) { sound in
//                            vm.addSound(sound: sound)
//                            Task{
//                                await mdm.updatePoint(pointManager.selectedEventPoint, withSound: sound)
//                                pointManager.addSound(sound: sound)
//                            }
//                        } removeAction: { sound in
//                            vm.removeSound(sound: sound)
//                            Task{
//                                await mdm.removeSound(sound, fromPoint: pointManager.selectedEventPoint)
//                                pointManager.removeSoundFromPoint(sound: sound)
//                            }
//                        }
//                        
//                    case .light:
//                        PanelLightCollectionView(lights: vm.lights) { light in
//                            vm.addLight(light: light)
//                            Task{
//                                await mdm.updatePoint(pointManager.selectedEventPoint, withLight: light)
//                                pointManager.addLight(light: light)
//                            }
//                        } removeAction: { light in
//                            vm.removeLight(light: light)
//                            Task{
//                                await mdm.removeLight(light, fromPoint: pointManager.selectedEventPoint)
//                                pointManager.removeLightFromPoint(light: light)
//                            }
//                        }
//                }
//            }
//            .padding(.vertical,10)

            ScrollViewReader{ proxy in
                ScrollView(.horizontal){
                    HStack{
                        ForEach(0..<24) { num in
                            VStack{
                                Text(String(format: "%02d", num))
                                    .font(.title2)
                                    .bold()
                            }
                            .id(num)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.4))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.black.opacity(0.4), lineWidth: 1)
                                            .matchedGeometryEffect(id: num, in: ns)
                                    }
                            }
                            .onTapGesture {
                                selectedNumber = num
                            }
                        }
                    }
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 1)
                            .matchedGeometryEffect(id: selectedNumber, in: ns, isSource: false)
                    }
                }
                
                .scrollIndicators(.hidden)
            }
            Spacer()
            
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.blue.opacity(0.4)))
        .frame(maxHeight: .infinity)
        //        .border(.blue, width: 3)
       
    }

    func mappedUsers() -> [LocalUser] {
        return availableUsers.compactMap { user in
            return user.isAvailableToEvent(event: pointManager.event) ? user : nil
//            for point in user.userLocationPoints{
//                if point.event?.viewId == pointManager.event.viewId {
//                    return nil
//                } else {
//                    if let date = point.event?.date,
//                       let newDate = pointManager.event.date{
//                        return date.compareDate(withDate: newDate) ? nil: user
//                    } else {
//                        return user
//                    }
//                }
//            }
//            return user
        }
    }
}


// MARK: - Preview
#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: Event.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.mainContext) { ctx in
        let newEvent = Event(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
   return BPEditStadiumView(event: localEvent)
        .environmentObject(mdm)
}



