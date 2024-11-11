import SwiftUI

struct ClubSheetCellView: View {

    let title: String
    let image: Image
    
    var body: some View {
        VStack{
//            club.viewImageLogo
            image
                .resizable()
                .scaledToFit()
                .padding(.top,5)
            Spacer(minLength: 5)
            Text(title.prefix(3).uppercased())
                .font(.subheadline)
                .padding(.bottom,5)
            
        }
    }
}

#Preview {
    ClubSheetView(
        cancelAction: {},
        acceptAction: {_ in },
        createNewClubAction: {},
        editClubAction: {_ in })
    .environment(\.managedObjectContext, DataManager.shared.moc)
}


//#Preview {
//    ClubSheetCellView(club: LocalClub(context: DataManager.preview.moc))
//}

