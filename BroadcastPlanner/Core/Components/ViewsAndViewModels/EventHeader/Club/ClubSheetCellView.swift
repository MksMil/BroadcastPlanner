import SwiftUI

struct ClubSheetCellView: View {

    let title: String
    let image: Image
    
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
        .background(content: {
            Color.gray.opacity(0.2)
        })
    }
}

//#Preview {
//    ClubSheetView(
//        cancelAction: {},
//        acceptAction: {_ in },
//        createNewClubAction: {},
//        editClubAction: {_ in })
//    .environment(\.managedObjectContext, DataManager.shared.moc)
//}


#Preview {
    ClubSheetCellView(title: "DON", image: Image(systemName: "plus"))
        
}

