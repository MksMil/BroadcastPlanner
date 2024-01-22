import SwiftUI

struct EventMainView: View {
    
    @EnvironmentObject var storage: Storage
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
                        AddCameraView()
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
    }
    func addCamera(){
//        storage.addCamera()
       isAddCam = true
    }
}

#Preview {
    EventMainView(isShowCreativeGroupEdit: .constant(false)).environmentObject(Storage(cameras: [],users: MockData.sampleUsers))
}
