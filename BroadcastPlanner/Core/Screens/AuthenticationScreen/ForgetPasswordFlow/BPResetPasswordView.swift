import SwiftUI

struct BPResetPasswordView: View {
    
    @State private var email: String = ""
    
    var body: some View {
        ZStack{
            MainBackground()
                .ignoresSafeArea()
            VStack{
                
                BPTextFieldWithIcon(text: $email,
                                    placeholder: "e-mail",
                                    imageName: "envelope")
                .padding(.bottom,40)
                
                Button {
                    AuthenticationManager.shared.sendResetPassword(with: email)
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
