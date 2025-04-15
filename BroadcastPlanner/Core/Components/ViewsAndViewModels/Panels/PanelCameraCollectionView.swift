import SwiftUI

struct PanelCameraCollectionView: View {
    @EnvironmentObject var mdm: MainDataManager
    
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
                .background(.white.opacity(0.4))
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
                ForEach(OpticType.allCases){ cam in
                    Text(cam.rawValue)
                        .onTapGesture {
                            let newCamera = mdm.localDataManager.createOrUpdateCamera(CameraDTO(id: UUID().uuidString, optic: cam), inContext: .main)
                            addAction(newCamera)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThickMaterial)
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
