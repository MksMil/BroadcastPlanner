import SwiftUI

struct AddCameraView: View {
    @Environment(\.dismiss) var dissmiss
    @EnvironmentObject var storage: Storage
    @State var number: String = "1"
    
    @StateObject var camera: Camera = Camera(position: .mainMatch)
//    @StateObject var user: User = User()
    
    var body: some View {
        
        ZStack{
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            VStack{
                Section {
                    SingleCameraStadiumView(camera: camera)
                        .frame(height: 200)
                        .padding(.horizontal,50)
                        .padding(.top,50)
                    
                    if !storage.possibleCameras.isEmpty{
                        Picker("\(camera.position.rawValue)", selection: $camera.position){
                            let positions = storage.possibleCameras.map { $0.position }
                            
                            ForEach(positions) { Text($0.rawValue) }
                        }
                        .onAppear(perform: {
                            if let position = storage.possibleCameras.first?.position {
                                camera.position = position
                            } else {
                                dissmiss()
                            }
                        })
                        .padding(20)
                    } else {
                        Text("No available Cameras")
                            .padding(20)
                    }
//                    let positions = storage.possibleCameras.map { $0.position }
                    
                    Text(number)
                        .frame(width: 100,height: 100)
                        .font(.system(size: 65, weight: .bold))
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).strokeBorder()
                        }
                        .padding(.horizontal)
                        .shadow(radius: 10)
                    
                    if !storage.users.filter({ !$0.reserved }).isEmpty{
                        Picker("\(storage.selectedUserName)", selection: $storage.selectedUserName){
                            ForEach(storage.users.filter { !$0.reserved }, id: \.name) { user in
                                Text(user.name)
                            }
                        }
                        .padding(20)
                       
                    } else {
                        Text("No available users")
                            .padding(20)
                    }
                    } header: {
                        
                    }
                
                
                Spacer()
                
                Button(action: {
                    //add cam here
                    // TODO: Check data and save camera to the storage
                    camera.number = number
                    camera.cameraMan =  storage.users.first(where: { $0.name == storage.selectedUserName }) ?? User()
                    storage.addCamera(cam: camera)
                    dissmiss()
                    
                }, label: {
                    Text("Add Cam")
                        .frame(width: 100,height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue)
                        }
                        .foregroundColor(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(lineWidth: 1)
                                .foregroundStyle(Color.black)
                            
                        }
                        .shadow(radius: 5)
                })
                .padding(.bottom, 50)
            }
        }
        .onAppear{
            storage.assignSelectedUser()
        }
    }

}

#Preview {
    AddCameraView().environmentObject(Storage(cameras: [], users: MockData.sampleUsers/*[]*/))
}
