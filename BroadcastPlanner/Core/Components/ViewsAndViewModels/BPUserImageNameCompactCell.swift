import SwiftUI

struct PanelUserCollectionView: View {
    
    let users: [LocalUser]
    let addAction: (LocalUser)->()
    let removeAction: (LocalUser)->()
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var userToRemove: LocalUser?
    
    init(users: [LocalUser],addAction: @escaping (LocalUser)->(), removeAction: @escaping (LocalUser)->()) {
        self.users = users
        self.addAction = addAction
        self.removeAction = removeAction
    }
    
    var body: some View {
        ScrollView{
            Button{
                isSelect = true
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(3)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add user")
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
                .padding(2)
            }
            
            ForEach(users){user in
                BPUserImageNameCompactCell(user: user){
                    userToRemove = user
                    isConfirm = true
                }
            }
            
       }
        .sheet(isPresented: $isSelect) {
            SmartLayout(hSpacing: 5, vSpacing: 5){
                ForEach(users){ user in
                    //user cell
                    Text("\(user.userFirstName) \(user.userLastName)")
                        .onTapGesture {
                            addAction(user)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.fraction(0.5)])
        }
        .confirmationDialog("", isPresented: $isConfirm) {
            Button("Remove user", role: .destructive) {
                if let userToRemove{
                    removeAction(userToRemove)
                }
            }
        }
    }
}

struct BPUserImageNameCompactCell: View {
    
    let user: LocalUser
    let action: ()->Void
    
    var body: some View {
        HStack(spacing: 0){
            
            user.userImage
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .padding(5)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            Text(user.userCompactName)
                .font(.system(size: 14))
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .frame(maxHeight: .infinity)
                .padding(5)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}

struct BPPositionCompactCell: View {
    let pointPositionName: String
    
    var body: some View {
        HStack{
            Image(systemName: "mappin.and.ellipse")
            Spacer()
            Text(pointPositionName)
                .font(.caption2)
            Spacer()
        }
    }
}

struct PanelCameraCollectionView: View {
    
    let cameras: [LocalCamera]
    let addAction: (LocalCamera)->()
    let removeAction: (LocalCamera)->()
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var cameraToRemove: LocalCamera?
    
    init(cameras: [LocalCamera],addAction: @escaping (LocalCamera)->()  ,removeAction: @escaping (LocalCamera)->()) {
        self.cameras = cameras
        self.addAction = addAction
        self.removeAction = removeAction
    }
    
    var body: some View {
        
        ScrollView{
            Button{
                isSelect = true
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(3)
                    Divider()
                        .padding(.vertical,3)
                    Text("Add camera")
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
                .padding(2)
            }
            
            ForEach(cameras){cam in
                BPCameraCompactCell(camera: cam){
                    cameraToRemove = cam
                    isConfirm = true
                }
            }
        }
        .sheet(isPresented: $isSelect) {
            List {
                ForEach(Camera.OpticType.allCases){ cam in
                    Text(cam.rawValue)
                        .onTapGesture {
                            let newCamera = DataManager.shared.createOrUpdateCamera(Camera(id: UUID().uuidString, optic: cam), inContext: .main)
                            addAction(newCamera)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.fraction(0.8)])
        }
        .confirmationDialog("", isPresented: $isConfirm) {
            Button("Remove camera environment", role: .destructive) {
                if let cameraToRemove{
                    removeAction(cameraToRemove)
                }
            }
        }
    }
}

struct BPCameraCompactCell: View {
    
    let camera: LocalCamera
    let action: ()->Void
    
    var body: some View {
        HStack(spacing: 0){
            
            Image("cam2")
                .resizable()
                .scaledToFit()
                .padding(3)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            Text(camera.viewOptic.rawValue)
                .font(.system(size: 14))
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
                
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(5)
                .frame(height: 40)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}

struct PanelSoundCollectionView: View {
    let sounds: [LocalSound]
    let addAction: (LocalSound)->()
    let removeAction: (LocalSound)->()
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var soundToRemove: LocalSound?
    
    init(sounds: [LocalSound], addAction: @escaping (LocalSound)->()  ,removeAction: @escaping (LocalSound)->()) {
        self.sounds = sounds
        self.addAction = addAction
        self.removeAction = removeAction
    }
    
    var body: some View {
        ScrollView{
            
            Button{
                isSelect = true
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(3)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add mic")
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
                .padding(2)
            }
            
            ForEach(sounds){sound in
                BPSoundCompactCell(sound: sound){
                    soundToRemove = sound
                    isConfirm = true
                }
            }
      }
        .sheet(isPresented: $isSelect) {
            List{
                ForEach(Sound.PlaceType.allCases){ placeType in
                    Text(placeType.rawValue)
                        .onTapGesture {
                            let newSound = DataManager.shared.createOrUpdateSound(Sound(id: UUID().uuidString, windDefence: .none, placeType: placeType), inContext: .main)
                            addAction(newSound)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.fraction(0.5)])
        }
        .confirmationDialog("", isPresented: $isConfirm) {
            Button("Remove sound hardware", role: .destructive) {
                if let soundToRemove {
                    removeAction(soundToRemove)
                }
            }
        }
    
    }
}

struct BPSoundCompactCell: View {
    
    let sound: LocalSound
    let action: ()->Void
    
    var body: some View {
        HStack(spacing: 0){
            Image("mic1")
                .resizable()
                .scaledToFit()
                .padding(3)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            VStack{
                Text(sound.viewPlaceType.rawValue)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
                Text(sound.viewWindDefence.rawValue)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
            }
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(5)
                .frame(height: 40)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}


struct PanelLightCollectionView: View {
    let lights: [LocalLight]
    let addAction: (LocalLight)->()
    let removeAction: (LocalLight)->()
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var lightToRemove: LocalLight?
    
    init(lights: [LocalLight],addAction: @escaping (LocalLight)->(), removeAction: @escaping (LocalLight)->()) {
        self.lights = lights
        self.addAction = addAction
        self.removeAction = removeAction
    }
    
    var body: some View {
        ScrollView{
            
            Button{
                isSelect = true
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(3)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add light")
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
                .padding(2)
            }
            
            ForEach(lights){light in
                BPLightCompactCell(light: light){
                    lightToRemove = light
                    isConfirm = true
                }
            }
       }
        .sheet(isPresented: $isSelect) {
            List{
                ForEach(Light.LightType.allCases){ light in
                    Text(light.rawValue)
                        .onTapGesture {
                            let newLight = DataManager.shared.createOrUpdateLocalLightWithLight(Light(id: UUID().uuidString, lightType: light), inContext: .main)
                            addAction(newLight)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.fraction(0.3)])
        }
        .confirmationDialog("", isPresented: $isConfirm) {
            Button("Remove light hardware", role: .destructive) {
                if let lightToRemove {
                    removeAction(lightToRemove)
                }
            }
        }
    }
}

struct BPLightCompactCell: View {
    
    let light: LocalLight
    let action: ()->Void
    
    var body: some View {
        HStack(spacing: 0){
            
            Image("light2")
                .resizable()
                .scaledToFit()
                .padding(3)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            Text(light.viewLightType.rawValue)
                .font(.system(size: 14))
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(5)
                .frame(height: 40)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}

struct BPEnvCompactCell: View {
    
    let user: LocalUser
    let action: ()->Void
    
    var body: some View {
        HStack{
            user.userImage
                .resizable()
                .scaledToFit()
                .padding(3)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            Text(user.userCompactName)
                .font(.system(size: 14))
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(5)
                .frame(height: 40)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}



//#Preview {
//    PanelUserCollectionView(users: [])
//}

#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")
    
    BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
    .environmentObject(BPEditStadiumViewModel())
    .environmentObject(mdm)
}

//#Preview {
//    BPUserCompactCell()
//}
