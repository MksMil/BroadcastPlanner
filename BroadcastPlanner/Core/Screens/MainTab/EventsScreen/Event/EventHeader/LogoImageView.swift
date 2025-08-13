import SwiftUI

final class LogoImageViewModel: ObservableObject{
    @Published var image : Image
    @Published var isSheetPresented: Bool = false
    var selectedClub: Club?
    
    init(club: Club?) {
        if let club = club{
            self.selectedClub = club
            self.image = club.viewImageMediumLogo
        } else {
            self.image = Image(systemName: "plus")
        }
    }
    
    func updatewithClub(club: Club){
        image = club.viewImageMediumLogo
    }
}

struct LogoImageView: View {
    
    @StateObject private var vm: LogoImageViewModel
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
        self._vm = StateObject(wrappedValue: LogoImageViewModel(club: club))
    }
    
    var body: some View {
        vm.image
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
                vm.isSheetPresented.toggle()
            }
            .disabled(!editable)
        //club/venue select/add/edit/remove sheet
        .sheet(
            isPresented: $vm.isSheetPresented,
            content: {
                ClubSelectionSheetView(selectedClub: vm.selectedClub, acceptAction: { newClub in
                    vm.selectedClub = newClub
                    if let newClub{
                        vm.updatewithClub(club: newClub)
                        accessAction(newClub)
                    }
                    vm.isSheetPresented = false
                })
//                .padding()
//                .presentationBackground(.white.opacity(0.4))
                .presentationContentInteraction(.scrolls)
                .presentationDragIndicator(.visible)
//                .presentationDetents(
//                    [.fraction(0.6),.fraction(0.65) ,.fraction(0.9), .fraction(1)],
//                    selection: $vm.locationSheetDetents)
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
