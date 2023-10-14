import SwiftUI

struct AddCameraView: View {
    @Environment(\.dismiss) var dissmiss
    @EnvironmentObject var storage: Storage
    @ObservedObject var motionManager: MotionManager
    
    @StateObject var viewModel: AddCameraViewModel = AddCameraViewModel()
    
    var body: some View {
        
        ZStack{
            //just simple background
            Color.lightBackgroundColor
                .ignoresSafeArea()
            
            VStack{
                SingleCameraStadiumView(vm: viewModel)
                    .frame(height: 200)
                    .padding(.horizontal,50)
                    .padding(.top,50)
                
                if storage.isCamerasAvailable{
                    Picker("cam", selection: $viewModel.position){
                        let positions = storage.possibleCameras.map { $0.position }
                        ForEach(positions) { Text($0.rawValue) }
                    }
                    .pickerStyle(.wheel)
                    .onAppear(perform: {
                        if let position = storage.possibleCameras.first?.position {
                            viewModel.position = position
                        } else {
                            dissmiss()
                        }
                    })
                    .padding(20)
                } else {
                    Text("No available Cameras")
                        .padding(20)
                }
                
                Text(viewModel.cameraNumber)
                    .frame(width: 100,height: 100)
                    .font(.system(size: 65, weight: .bold))
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder()
                    }
                    .padding(.horizontal)
                    .shadow(radius: 10)
                
                if storage.isUsersAvailable{
                    Picker(
                        "name",
                        selection: $viewModel.selectedUserName
                    ){
                        ForEach(storage.possibleUsers) { Text($0.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(20)
                    
                } else {
                    Text("No available users")
                        .padding(20)
                }
                
                Spacer()
                
                Button(action: {
                    storage.addCamera(
                        position : viewModel.position,
                        userName : viewModel.selectedUserName,
                        camNumber: viewModel.cameraNumber
                    )
                    dissmiss()
                    
                },
                       label: {
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
                                .foregroundStyle(Color.orange)
                            
                        }
                        .shadow(radius: 5)
                })
                .padding(.bottom, 50)
            }
        }
        .tint(Color.white)
        .foregroundStyle(Color.white)
        // TODO:  background animation
        //        .padding()
        //        .offset(x: motionManager.roll * 100,
        //                y: motionManager.pitch * 100)
        .onAppear{
            //            motionManager.startMonitoringMotionUpdates()
            viewModel.selectedUserName = storage.possibleUsers.first?.name ?? "Empty cam"
        }
        //        .onDisappear(perform: {
        //            motionManager.stopMonitoringMotionUpdates()
        //        })
        
    }
    
}

#Preview {
    AddCameraView(motionManager: MotionManager())
        .environmentObject(
            Storage(
                cameras: [],
                users: MockData.sampleUsers
            )
        )
}
