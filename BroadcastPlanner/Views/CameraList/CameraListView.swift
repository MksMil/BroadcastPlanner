import SwiftUI

struct CameraListView: View {
    
    @EnvironmentObject var storage: Storage
    
    
    var body: some View {
        
        List(storage.cameras) { cam in
            CameraListCellView(camera: cam)
                .listRowInsets(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                .listRowBackground(Color.clear)
                .onTapGesture { storage.select(cam: cam) }
            
        }
        .listStyle(.inset)
        .listRowSpacing(10)
        
    }
}

#Preview {
    CameraListView().environmentObject(Storage(cameras: MockData.sampleCameras))
}
