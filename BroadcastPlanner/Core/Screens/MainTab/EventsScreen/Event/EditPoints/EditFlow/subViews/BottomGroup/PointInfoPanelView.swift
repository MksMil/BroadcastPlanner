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
    @Published var cameras: [LocalCamera] = []
    @Published var sounds: [LocalSound] = []
    @Published var lights: [LocalLight] = []
    
    @Published var task: String = ""
    
    
    @Published var availableUsers: [LocalUser] = []
   
    var selectedPoint: LocalLocationPoint?
    @Published var selectedFilter: StadiumPointFilterCase = .users
    
    // MARK: - vm init
    init(point: LocalLocationPoint?){
        self.selectedPoint = point
        update(point: point)
    }
    
    func setAvailableUsers(){
        
//        if let availableUsers = try? DataManager.shared.moc.fetch(LocalUser.fetchRequest()){
//            self.availableUsers = availableUsers.map({ user in
//                user.isAvailableToEvent(event: <#T##LocalEvent#>)
//            })
//        }
    }
    
    func update(point: LocalLocationPoint?){
        if let point {
            self.users = point.viewUsers
            self.num = point.viewNumber
            self.description = point.viewDescription
            self.cameras = point.viewLocalCameras
            self.sounds = point.viewLocalSounds
            self.lights = point.viewLocalLights
            self.task = point.viewTask
        }
    }
    
    func addUser(user: LocalUser){
        if !users.contains([user]) {
            users.append(user)
            print("this user: \(user.userLastName) appended to point")
           
        } else {
            print("this user: \(user.userLastName) exist in point")
        }
    }
    
    func acceptNubmer(num: Int){
       
        self.num = num
    }
    
    func addCam(cam: LocalCamera){
       
        cameras.append(cam)
    }
    
    func addSound(sound: LocalSound){
       
        sounds.append(sound)
    }
    
    func addLight(light: LocalLight){
        
        lights.append(light)
    }
    
    func addDescription(desc: String){
        self.description = desc
    }
}

struct PointInfoPanelView: View {
//can be changed from settings ? !
    // MARK: - Properties
    let maxCam: Int = 21
    
    @StateObject var vm: PointInfoPanelViewModel
    @EnvironmentObject var pointManager: BPEditStadiumViewModel
    
    @State var numPopover: Bool = false
//    @State var number: Int = 1
    // MARK: - Init
    init(point: LocalLocationPoint?) {
        self._vm = StateObject(wrappedValue: PointInfoPanelViewModel(point: point))
//        self.point = point
    }

    // MARK: - Body
    var body: some View {
            VStack(spacing: 5) {
                //number position stack
                HStack(alignment: .center) {
                    //point number
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 45)
                        .overlay(content: {
                            Circle().stroke(.ultraThickMaterial)
                        })
                        .overlay {
                            Text(String(vm.num))
                                .font(.title)
                                .bold()
                                .foregroundStyle(.black)
                        }
                        .onTapGesture {
                            numPopover.toggle()
                        }
                        .popover(isPresented: $numPopover){
                            SmartLayout(hSpacing: 10, vSpacing: 10) {
                                ForEach(1..<maxCam) { num in
                                    Button{
                                        withAnimation{
                                            pointManager.acceptNubmer(num: num)
                                            vm.acceptNubmer(num: num)
                                            numPopover.toggle()
                                        }
                                    } label: {
                                        Circle()
                                            .fill(.ultraThinMaterial)
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
                                pointManager.addDescription(desc: position.rawValue)
                                vm.addDescription(desc: position.rawValue)
                                
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
                
                
                VStack {
                    //user section
                    BPEventFilterCaseTabView(selectedTab: $vm.selectedFilter)
                    switch vm.selectedFilter {
                        case .users:
                            PanelUserCollectionView(users: vm.users){
                                
                            } action: {
                                
                            }
                        case .cam:
                            PanelCameraCollectionView(cameras: vm.cameras) {
                                
                            } action: {
                                
                            }
                        case .mic:
                            PanelSoundCollectionView(sounds: vm.sounds) {
                                
                            } action: {
                                
                            }
                            
                        case .light:
                            PanelLightCollectionView(lights: vm.lights) {
                                
                            } action: {
                                
                            }
                    }
                }
            }
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial))
        .onReceive(pointManager.$selectedEventPoint) { point in
            if let point {
                vm.update(point: point)
            }
        }
    }
}

//#Preview {
//    PointInfoPanel()
//}
// MARK: - Preview
#Preview {
    BPEditStadiumView(
        event: DataManager.shared.fetchOrCreateEventWithId(
            "123", inContext: .main), editable: true, acceptAction: {},
        cancelAction: {}
    )
    .environment(\.managedObjectContext, DataManager.shared.moc)
}



