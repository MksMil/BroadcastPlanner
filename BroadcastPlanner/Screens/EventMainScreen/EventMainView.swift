import SwiftUI

struct EventMainView: View {
    
    @EnvironmentObject var storage: Storage
//    @ObservedObject var motionManager: MotionManager
    @Binding var isShowCreativeGroupEdit: Bool
    @State private var isAddCam: Bool = false
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            VStack {
                EventInfoView(event: MockData.sampleEvent)
                StadiumView()
                    .padding(.horizontal,10)
                }
            VStack{
                //info bar here
                HStack{
                    Spacer()
                    
                    Label(storage.lastSelected?.position.rawValue ?? "No cam selected", systemImage: "video.circle.fill")
                    
                    Spacer()
                    
                    Button{
                        addCamera()
                    } label: {
                        Image(systemName: "plus.app")
                            .resizable()
                            .frame(width: 40,height: 40)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $isAddCam, content: {
                        AddCameraView(/*motionManager: motionManager*/)
                    })
                }
                .padding(.top,330)
                
                if !storage.cameras.isEmpty{
                    CameraListView()
                        .scrollContentBackground(.hidden)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Spacer()
                }
            }
        }
        .tint(Color.white)
        .foregroundStyle(Color.white)
        .safeAreaInset(edge: .bottom) {
            VStack{
                Button(action: {
                    isShowCreativeGroupEdit = false
                }, label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: 100, height: 50)
                        .overlay {
                            Text("Button")
                                .foregroundStyle(Color.white)
                        }
                })
                Text("Cameras: \(storage.cameras.count)").foregroundStyle(Color.white)
                
            }
        }
        // TODO:  background animation
//        .padding()
//        .offset(x: motionManager.roll * 100,
//                y: motionManager.pitch * 100)
//        .onAppear{
//            motionManager.startMonitoringMotionUpdates()
//        }
//        .onDisappear(perform: {
//            motionManager.stopMonitoringMotionUpdates()
//        })
    }
    func addCamera(){
//        storage.addCamera()
       isAddCam = true
    }
}

#Preview {
    EventMainView(/*motionManager: MotionManager()*/ isShowCreativeGroupEdit: .constant(false)).environmentObject(Storage(cameras: [],users: MockData.sampleUsers))
}
