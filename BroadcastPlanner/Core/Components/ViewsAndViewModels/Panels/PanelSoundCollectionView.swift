import SwiftUI

struct PanelSoundCollectionView: View {
    @EnvironmentObject var mdm: MainDataManager
    
    let sounds: [LocalSound]
    let addAction: (LocalSound)->()
    let removeAction: (LocalSound)->()
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var soundToRemove: LocalSound?
    
    init(sounds: [LocalSound], addAction: @escaping (LocalSound)->()  ,removeAction: @escaping (LocalSound)->()) {
        self.sounds = sounds
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
                    
                    Text("Add mic")
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
            
            ForEach(sounds){sound in
                BPSoundCompactCell(sound: sound){
                    soundToRemove = sound
                    isConfirm = true
                }
            }
      }
        .sheet(isPresented: $isSelect) {
            List{
                ForEach(PlaceType.allCases){ placeType in
                    Text(placeType.rawValue)
                        .onTapGesture {
                            let newSound = mdm.localDataManager.createOrUpdateSound(SoundDTO(id: UUID().uuidString, windDefence: .none, placeType: placeType), inContext: .main)
                            addAction(newSound)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThickMaterial)
            .presentationDetents([.fraction(0.5)])
        }
        .confirmationDialog("", isPresented: $isConfirm) {
            Button("Remove sound hardware", role: .destructive) {
                if let soundToRemove {
                    removeAction(soundToRemove)
                }
            }
        }
    
    }
}
