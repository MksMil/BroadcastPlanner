import SwiftUI

struct LogoImageView: View {
    @EnvironmentObject var dataManager: DataManager
    @State var isSheetPresented: Bool = false
    @Binding var selectedClub: Club?
    @State private var image: Image = Image(systemName: "person.circle")
    @Binding var excludedClub: Club?
    var logoSize: Double
    let cancelAction: ()->Void
    let accessAction: (Club)->Void
    let editable: Bool
    
    
//    init(club: Club?,excludedClub: Club? = nil,logoSize: Double = 100,editable: Bool = true,
//         cancelAction: @escaping () -> Void,
//         accessAction: @escaping (Club) -> Void) {
//        self.logoSize = logoSize
//        self.editable = editable
//        self.cancelAction = cancelAction
//        self.accessAction = accessAction
//        self._selectedClub = State(initialValue: club)
//        self.excludedClub = excludedClub
//    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: logoSize, height: logoSize)
            .padding(logoSize / 10)
            .clipShape(Circle())
            .background{
                Circle().fill(.ultraThinMaterial)
            }
            .overlay {
                Circle().stroke(Color.white, lineWidth: 3)
            }
            .onTapGesture {
                isSheetPresented.toggle()
            }
            .disabled(!editable)
        //club/venue select/add/edit/remove sheet
            .task{
                update()
            }
            .sheet(
                isPresented: $isSheetPresented,
                content: {
                    ClubSelectionSheetView(selectedClub: $selectedClub,
                                           excludedClub: $excludedClub,
                                           acceptAction: { newClub in
                        selectedClub = newClub
                        update()
                        if let newClub{
                            accessAction(newClub)
                        }
                        isSheetPresented = false
                    })
                    .presentationContentInteraction(.scrolls)
                    .presentationDragIndicator(.visible)
                }
            )
    }
    func update() {
        Task{
            if let id = selectedClub?.viewId,
               !id.isEmpty,
               let newImage = await dataManager.getImageWithId(id, type: GlobalProperties.ImageType.club, size: ImageSizes.mediumImages)
            {
                await MainActor.run {
                        image = Image(uiImage: newImage)
                }
            } else {
                await MainActor.run {
                        image = Image(systemName: "person.circle")
                }
            }
        }
    }
}

