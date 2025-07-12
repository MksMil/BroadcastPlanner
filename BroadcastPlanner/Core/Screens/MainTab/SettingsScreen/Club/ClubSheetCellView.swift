import SwiftUI

struct ClubSheetCellView: View {
    
//    let club: Club
    let image: Image
    let title: String
    
    let isSelected : Bool
    
    var body: some View {
        VStack{
            image
                .resizable()
                .scaledToFit()
                .padding(5)
                .frame(width: 70, height: 70)
            Spacer(minLength: 5)
            Text(title.prefix(3).uppercased())
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
        .scaleEffect(isSelected ? 1.05: 1)
        .opacity(isSelected ? 1 : 0.65)
    }
}


//#Preview {
//    SettingsView()
//        .environmentObject(GlobalSessionStorage())
//        .environmentObject(ApplicationState())
//        .environment(\.managedObjectContext, DataManager.shared.moc)
//}


//#Preview {
//    ClubSheetCellView(title: "DON", image: Image(systemName: "plus"))
//        
//}

