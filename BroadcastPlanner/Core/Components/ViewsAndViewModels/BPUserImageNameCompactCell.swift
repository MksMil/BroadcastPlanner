import SwiftUI

struct PanelUserCollectionView: View {
    
    let users: [LocalUser]
    let addAction: ()->()
    let action: ()->()
    
    init(users: [LocalUser],addAction: @escaping ()->()  ,action: @escaping ()->()) {
        self.users = users
        self.addAction = addAction
        self.action = action
    }
    
    var body: some View {
        ScrollView{
            ForEach(users){user in
                BPUserImageNameCompactCell(user: user){
                    action()
                }
            }
            Button{
                addAction()
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(.horizontal,5)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add user")
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(2)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
       }
    }
}

struct BPUserImageNameCompactCell: View {
    
    let user: LocalUser
    let action: ()->Void
    
    var body: some View {
        HStack{
            
            user.userImage
                .resizable()
                .scaledToFit()
                .padding(10)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(.horizontal,5)
            Divider()
                .padding(.vertical,3)
            
            Text(user.userCompactName)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .onTapGesture {
            action()
        }

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
    let addAction: ()->()
    let action: ()->()
    
    init(cameras: [LocalCamera],addAction: @escaping ()->()  ,action: @escaping ()->()) {
        self.cameras = cameras
        self.addAction = addAction
        self.action = action
    }
    
    var body: some View {
        ScrollView{
            ForEach(cameras){cam in
                BPCameraCompactCell(camera: cam){
                    action()
                }
            }
            Button{
                addAction()
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(.horizontal,5)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add camera")
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(2)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
       }
    }
}

struct BPCameraCompactCell: View {
    
    let camera: LocalCamera
    let action: ()->Void
    
    var body: some View {
        HStack{
            
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .padding(10)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(.horizontal,5)
            Divider()
                .padding(.vertical,3)
            
            Text(camera.viewOptic.rawValue)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .onTapGesture {
            action()
        }

    }
}

struct PanelSoundCollectionView: View {
    let sounds: [LocalSound]
    let addAction: ()->()
    let action: ()->()
    
    init(sounds: [LocalSound],addAction: @escaping ()->()  ,action: @escaping ()->()) {
        self.sounds = sounds
        self.addAction = addAction
        self.action = action
    }
    
    var body: some View {
        ScrollView{
            ForEach(sounds){sound in
                BPSoundCompactCell(sound: sound){
                    action()
                }
            }
            Button{
                addAction()
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(.horizontal,5)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add mic")
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(2)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
       }
    }
}

struct BPSoundCompactCell: View {
    
    let sound: LocalSound
    let action: ()->Void
    
    var body: some View {
        HStack{
            
            Image(systemName: "mic")
                .resizable()
                .scaledToFit()
                .padding(10)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(.horizontal,5)
            Divider()
                .padding(.vertical,3)
            
            VStack{
                Text(sound.viewPlaceType.rawValue)
                    .font(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
                Text(sound.viewWindDefence.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .onTapGesture {
            action()
        }

    }
}


struct PanelLightCollectionView: View {
    let lights: [LocalLight]
    let addAction: ()->()
    let action: ()->()
    
    init(lights: [LocalLight],addAction: @escaping ()->()  ,action: @escaping ()->()) {
        self.lights = lights
        self.addAction = addAction
        self.action = action
    }
    
    var body: some View {
        ScrollView{
            ForEach(lights){light in
                BPLightCompactCell(light: light){
                    action()
                }
            }
            Button{
                addAction()
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(.horizontal,5)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add light")
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(2)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
       }
    }
}

struct BPLightCompactCell: View {
    
    let light: LocalLight
    let action: ()->Void
    
    var body: some View {
        HStack{
            
            Image(systemName: "light")
                .resizable()
                .scaledToFit()
                .padding(10)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(.horizontal,5)
            Divider()
                .padding(.vertical,3)
            
            Text(light.viewLightType.rawValue)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .onTapGesture {
            action()
        }

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
                .padding(10)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
                .padding(.horizontal,5)
            Divider()
                .padding(.vertical,3)
            
            Text(user.userCompactName)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .onTapGesture {
            action()
        }

    }
}



//#Preview {
//    PanelUserCollectionView(users: [])
//}

#Preview {
    BPEditStadiumView(
        event: DataManager.shared.fetchOrCreateEventWithId(
            "123", inContext: .main), editable: true, acceptAction: {},
        cancelAction: {}
    )
    .environment(\.managedObjectContext, DataManager.shared.moc)
}

//#Preview {
//    BPUserCompactCell()
//}
