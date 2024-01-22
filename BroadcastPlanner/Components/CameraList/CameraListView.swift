import SwiftUI

struct CameraListView: View {
    
    @EnvironmentObject var storage: Storage
    
    var body: some View {
        
        List {
            ForEach(storage.cameras) { cam in
                CameraListCellView(camera: cam)
                    .listRowInsets(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .listRowBackground(Color.clear)
                    .onTapGesture { storage.select(cam: cam) }
            }
            .onDelete(perform: { indexSet in
                storage.deleteCamera(indexSet: indexSet)
            })
            
        }
        .listStyle(.inset)
        .listRowSpacing(6)
    }
}

#Preview {
    CameraListView().environmentObject(Storage(cameras: MockData.sampleCameras))
}
