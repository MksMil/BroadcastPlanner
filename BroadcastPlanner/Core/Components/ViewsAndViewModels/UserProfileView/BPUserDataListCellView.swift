import SwiftUI

struct BPUserDataListCellView: View {
    
    var user : Member
    var text: String
    
    var body: some View {
        HStack{
            user.viewImage
                .resizable()
                .scaledToFill()
            
//                .padding(4)
                .frame(width: 25,height: 25)
                .background(.ultraThickMaterial)
                .clipShape(Circle())
           
            VStack(alignment: .leading, spacing: 0){
                Text("\(user.viewFirstName) \(user.viewLastName)")//user.fullCompactName)
                    .font(.system(size: 10))
                    .bold()
                
//                    .padding(.leading,5)
                Text("\(user.viewSpecialization)")
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
        .background(.white.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    
}

//#Preview {
//    BPUserDataListCellView(user: Member(context: DataManager.preview.moc), text: "text")
//}

