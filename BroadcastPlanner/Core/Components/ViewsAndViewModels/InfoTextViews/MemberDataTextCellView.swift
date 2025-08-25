import SwiftUI

//used in profile view
struct MemberDataTextCellView: View {
    let text: String
    let isEdit: Bool
    let imageName: String
    let prompt: String
    let scaleFactor: Double
    
    var body: some View {
        HStack{
            if !imageName.isEmpty{
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 25,height: 25)
                    .scaledToFill()
                    .padding(.leading,8)
            }
            
            Text(text.isEmpty ? prompt : text)
                .font(.title3)
                .foregroundStyle(text.isEmpty ? .gray:.primary)
                .minimumScaleFactor(scaleFactor)
                .padding(8)
            Spacer()
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .frame(alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 5.0).fill(.white.opacity(0.4)).opacity(isEdit ? 0.5 : 0)
        }
    }
}

#Preview {
    ZStack{
        Color.orange.ignoresSafeArea()
        MemberDataTextCellView(text: "Dmitro",
                          isEdit: true,
                          imageName: "",
                          prompt: "enter your name",
                          scaleFactor: 0.2)
    }
}
