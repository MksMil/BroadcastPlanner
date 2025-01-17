import SwiftUI

struct BPUserDataListCellView: View {
    
    var user : LocalUser
    var text: String
    
    var body: some View {
        HStack{
            user.userImage
                .resizable()
                .scaledToFill()
            
//                .padding(4)
                .frame(width: 25,height: 25)
                .background(.ultraThickMaterial)
                .clipShape(Circle())
           
            VStack(alignment: .leading, spacing: 0){
                Text("\(user.userFirstName) \(user.userLastName)")//user.fullCompactName)
                    .font(.system(size: 10))
                    .bold()
                
//                    .padding(.leading,5)
                Text("\(user.userSpecialization)")
                    .font(.system(size: 8))
//                    .italic()
                    .foregroundStyle(.gray)
                
            }
            
            Spacer()
            Text("1")
                .font(.callout)
                .frame(width: 25,height: 25)
//                .padding(4)
                .background(.ultraThickMaterial)
                .clipShape(Circle())
        }
//        .frame(maxWidth: .infinity)
        .padding(.horizontal,8)
        .padding(.vertical,4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    
}

//#Preview {
//    BPUserDataListCellView(user: LocalUser(context: DataManager.preview.moc), text: "text")
//}

