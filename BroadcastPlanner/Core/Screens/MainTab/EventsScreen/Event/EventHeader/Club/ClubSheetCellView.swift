import SwiftUI
import Combine

final class ClubSheetCellViewModel: ObservableObject{
    
    let club: LocalClub
    
    @Published var title: String
    @Published var image: Image
    
    
    init(club: LocalClub) {
        self.club = club
        self.title = club.viewTitle
        self.image = club.viewImageMediumLogo
    }
    func update(){
        self.title = club.viewTitle
        self.image = club.viewImageMediumLogo
    }
    
}

struct ClubSheetCellView: View {
    @EnvironmentObject var mdm: MainDataManager
    @StateObject private var vm: ClubSheetCellViewModel
    let club: LocalClub
    
    init(club: LocalClub) {
        self.club = club
        self._vm = StateObject(wrappedValue: ClubSheetCellViewModel(club: club))
    }
    
    var body: some View {
        VStack{
            vm.image
                .resizable()
                .scaledToFit()
                .padding(5)
                .frame(width: 70, height: 70)
            Spacer(minLength: 5)
            Text(vm.title.prefix(3).uppercased())
                .font(.subheadline)
                .padding(.bottom,5)
            
        }
        .padding(3)
        .frame(width: 75, height: 100)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                }
                
        }
        .onReceive(mdm.localDataManager.updatePublisher) { value in
            if value.0 == .clubs, let  id = value.1.first{
                if id == club.viewId{
                    vm.update()
                }
            }
        }
    }
}


//#Preview {
//    SettingsView()
//        .environmentObject(GlobalSessionStorage())
//        .environmentObject(ApplicationState())
//        .environment(\.managedObjectContext, DataManager.shared.moc)
//}
#Preview {
    ClubSheetView(
        cancelAction: {},
        acceptAction: {_ in },
        addEditAction: {_ in })
//    .environment(\.managedObjectContext, DataManager.shared.moc)
}


//#Preview {
//    ClubSheetCellView(title: "DON", image: Image(systemName: "plus"))
//        
//}

