import SwiftUI

final class LogoImageViewModel: ObservableObject{
    @Published var image : Image
    @Published var isSheetPresented: Bool = false
    init(club: LocalClub?) {
        if let club = club{
            self.image = club.viewImageMediumLogo
        } else {
            self.image = Image(systemName: "plus")
        }
    }
    
    func updatewithClub(club: LocalClub){
        image = club.viewImageMediumLogo
    }
}

struct LogoImageView: View {
    
    @StateObject private var vm: LogoImageViewModel
    var logoSize: Double
    let cancelAction: ()->Void
    let accessAction: (LocalClub)->Void
    
    init(club: LocalClub?,logoSize: Double = 100, cancelAction: @escaping () -> Void, accessAction: @escaping (LocalClub) -> Void) {
        self.logoSize = logoSize
        self.cancelAction = cancelAction
        self.accessAction = accessAction
        self._vm = StateObject(wrappedValue: LogoImageViewModel(club: club))
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        vm.image
            .resizable()
            .scaledToFit()
            .frame(width: logoSize, height: logoSize)
            .padding(logoSize / 10)
            .clipShape(Circle())
            .background{
                Circle().fill( .ultraThinMaterial.opacity(0.9))
            }
            .overlay {
                Circle().stroke(Color.white, lineWidth: 3)
            }
            .onTapGesture {
                vm.isSheetPresented.toggle()
            }
        //club/location select/add/edit/remove sheet
        .sheet(
            isPresented: $vm.isSheetPresented,
            content: {
                ClubSheetView(cancelAction: {
                    cancelAction()
                    vm.isSheetPresented.toggle()
                }, acceptAction: { club in
                    vm.updatewithClub(club: club)
                    accessAction(club)
                    vm.isSheetPresented.toggle()
                }, addEditAction: {_ in })
//                .padding()
                .presentationBackground(.ultraThinMaterial)
                .presentationContentInteraction(.scrolls)
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
