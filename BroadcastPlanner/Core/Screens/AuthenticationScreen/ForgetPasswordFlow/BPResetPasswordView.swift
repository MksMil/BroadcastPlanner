import SwiftUI

struct BPResetPasswordView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var email: String = ""
    
    var body: some View {
        ZStack{
            MainBackground()
                .ignoresSafeArea()
            VStack{
                //TODO: fix
//                BPTextFieldWithIcon(text: $email,
//                                    placeholder: "e-mail",
//                                    imageName: "envelope")
//                .padding(.bottom,40)
                
                Button {
                    sessionManager.sendResetPassword(with: email)
                } label: {
                    Text("Send")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top,200)
        }
    }
}

#Preview {
    BPResetPasswordView()
}
