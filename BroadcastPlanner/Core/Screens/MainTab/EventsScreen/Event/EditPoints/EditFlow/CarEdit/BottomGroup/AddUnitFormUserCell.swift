import SwiftUI


struct AddUnitFormUserCell: View {
    
    let user: Member
//    let image: Image
//    let text: String
//    let selected: Bool
    let infoAction: ()->()
    
    var body: some View {
        HStack{
            user.viewImage
//            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(content: {
                    Circle().stroke(Color.white, lineWidth: 2)
                })
                .frame(width: 40, height: 40)
            Text("\(user.viewCompactName)")
            
            Spacer()
            Image(systemName: "info.circle")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.trailing,5)
                .onTapGesture {
                    infoAction()
                }
        }
        .foregroundStyle(.black)

        .padding(5)
        .frame(maxWidth: .infinity,alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.8))
        }
    }
}
