import SwiftUI

struct PanelLightCollectionView: View {
    @EnvironmentObject var mdm: MainDataManager
    
    let lights: [Light]
    let addAction: (Light)->()
    let removeAction: (Light)->()
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var lightToRemove: Light?
    
    init(lights: [Light],
         addAction: @escaping (Light)->(),
         removeAction: @escaping (Light)->()) {
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
                            Circle().fill(.white.opacity(0.4))
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
                .background(.white.opacity(0.4))
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
                ForEach(LightType.allCases){ light in
                    Text(light.rawValue)
                        .onTapGesture {
                            let newLight = mdm.localDataManager.createOrUpdateLight(LightDTO(id: UUID().uuidString, lightType: light), inContext: .main)
                            addAction(newLight)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThickMaterial)
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
