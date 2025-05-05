import SwiftUI

struct BPEnvCompactCell: View {
    
    let user: LocalUser
    let action: ()->Void
    
    var body: some View {
        HStack{
            user.viewImage
                .resizable()
                .scaledToFit()
                .padding(3)
                .background {
                    Circle().fill(.white.opacity(0.4))
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            Text(user.viewCompactName)
                .font(.system(size: 14))
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .padding(.horizontal,5)
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(5)
                .frame(height: 40)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}
