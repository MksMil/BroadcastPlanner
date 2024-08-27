import SwiftUI

struct BPUserDataListCellView: View {
    
    var user : BPUser
    var image: UIImage?
    
    var body: some View {
        HStack{
            makeImage()
                .resizable()
                .scaledToFill()
            
//                .padding(4)
                .frame(width: 25,height: 25)
                .background(.ultraThickMaterial)
                .clipShape(Circle())
           
            VStack(alignment: .leading, spacing: 0){
                Text(user.fullCompactName)
                    .font(.system(size: 10))
                    .bold()
                
//                    .padding(.leading,5)
                Text("position")
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
    
    func makeImage() -> Image{
        if let image  {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "person")
        }
    }
}

#Preview {
    BPUserDataListCellView(user: MockData.sampleUser)
}

