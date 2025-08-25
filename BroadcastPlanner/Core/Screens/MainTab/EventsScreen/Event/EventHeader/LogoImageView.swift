import SwiftUI

struct LogoImageView: View {
    @State var isSheetPresented: Bool = false
    @State var selectedClub: Club?
    
    var logoSize: Double
    let cancelAction: ()->Void
    let accessAction: (Club)->Void
    let editable: Bool
    
    
    init(club: Club?,logoSize: Double = 100,editable: Bool = true,
         cancelAction: @escaping () -> Void,
         accessAction: @escaping (Club) -> Void) {
        self.logoSize = logoSize
        self.editable = editable
        self.cancelAction = cancelAction
        self.accessAction = accessAction
        self.selectedClub = club
    }
    
    var body: some View {
        ImageWrapper(id: selectedClub?.viewId ?? "",type: .club, imageSize: .mediumImages)
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
        .sheet(
            isPresented: $isSheetPresented,
            content: {
                ClubSelectionSheetView(selectedClub: selectedClub, acceptAction: { newClub in
                    selectedClub = newClub
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
}

#Preview {
    ZStack{
        Color.blue
            .ignoresSafeArea()
        LogoImageView(club: nil, cancelAction: {
            
        }, accessAction: { _ in
            
        }
)
    }
}
