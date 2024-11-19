import SwiftUI

struct ClubSheetCellView: View {

    let club: LocalClub
    
    var body: some View {
        VStack{
            club.viewImageMediumLogo
                .resizable()
                .scaledToFit()
                .padding(5)
                .frame(width: 70, height: 70)
            Spacer(minLength: 5)
            Text(club.viewTitle.prefix(3).uppercased())
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


//#Preview {
//    ClubSheetCellView(title: "DON", image: Image(systemName: "plus"))
//        
//}

