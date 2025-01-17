import SwiftUI

//used in profile view
struct UserInfoTextField: View {
    @Binding var text: String
    var isEdit: Bool
    var imageName: String
    var prompt: String
    var axis: Axis
    
    var body: some View {
        HStack{
            if !imageName.isEmpty{
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 30,height: 30)
                    .scaledToFill()
            }
            
            // TODO: Text content type?
            TextField("", text: $text, prompt: Text(prompt), axis: axis)
                .autocorrectionDisabled()
                .font(.title)
                .padding(.vertical,4)
                .padding(.horizontal,5)
                .background {
                    RoundedRectangle(cornerRadius: 5.0).fill(.ultraThinMaterial).opacity(isEdit ? 0.5 : 0)
                }
        }
        .frame(height: 40)
    }
}

//#Preview {
//    BPAccountInfoView(id: "123")
//        .environment(\.managedObjectContext, DataManager.shared.moc)
//}
