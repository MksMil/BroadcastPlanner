import SwiftUI

struct BPUserImageNameCompactCell: View {
    
    let user: Member
    let action: ()->Void
    @State private var isShowInfo: Bool = false
    
    var body: some View {
        HStack(spacing: 0){
            Section{
                user.viewImage
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 36)
                    .padding(3)
                Divider()
                    .padding(.vertical,3)
                
                Text(user.viewCompactName)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
            Spacer()
            }
            .onTapGesture {
                print("show info")
                isShowInfo.toggle()
            }
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .frame(maxHeight: .infinity)
                .padding(5)
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
        .sheet(isPresented: $isShowInfo) {
            BPUserProfileView(user: user)
        }
    }
}
