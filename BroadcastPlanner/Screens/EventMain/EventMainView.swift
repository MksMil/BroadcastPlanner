import SwiftUI

struct EventMainView: View {
    
    @EnvironmentObject var storage: Storage
    
    @State private var isAddCam: Bool = false
    @StateObject var viewModel: EventMainViewModel
    
    var body: some View {
        ZStack{
             
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
    }
    func addCamera(){
//        storage.addCamera()
       isAddCam = true
    }
}

#Preview {
    EventMainView(viewModel: EventMainViewModel(cameras: [])).environmentObject(Storage(cameras: []))
}
