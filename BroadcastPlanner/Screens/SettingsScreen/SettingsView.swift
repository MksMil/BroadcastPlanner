import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct SettingsView: View {
    
    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.authorizationController) private var authorizationController
    
    @State var newEmail: String = ""
    @State var newPassword: String = ""
    
    @State private var myNounce = ""
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundTabItem()
                VStack{
                    Text("Settings here")
                        .foregroundStyle(Color.accentColor)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                VStack{
                    Section {
                        VStack(spacing: 15){
                            NavigationLink {
                                UpdateEPView(updEP: .email)
                            } label: {
                                Text("Change E-mail")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                            
                            NavigationLink {
                                UpdateEPView(updEP: .password)
                            } label: {
                                Text("Change Password")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                            Button {
                                Task{
                                    await AuthenticationManager.shared.linkWithGoogle()
                                }
                            } label: {
                                Text("Link with Google")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                            Button {
                                Task{
                                    do {
                                        // Create the authorization request.
                                        let request = makeRequest()
                                        
                                        // Perform the request and await its result.
                                        let result = try await authorizationController
                                            .performRequest(request)
                                        switch result {
                                        case .appleID(let credential):
                                            let firCred = try makeAppleCred(credential: credential)
                                            AuthenticationManager.shared.linkWithApple(credential: firCred)
                                            print(credential)
                                        default :
                                            print("another result type received")
                                        }
                                    } catch {
                                        print("Error Apple linking")
                                    }
                                }
                            } label: {
                                Text("Link with Apple")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                            
                        }
                    } header: {
                        Text("Email and Password")
                            .font(.title2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                    }
                }.foregroundStyle(Color.accent)
                
                // MARK: - "Sign out" button
                VStack{
                    Spacer()
                    Button(action: {
                        Task{
                            do{
                                try AuthenticationManager.shared.logOut()
                            } catch {
                                print("failed to signing out: \(error.localizedDescription)")
                            }
                        }
                        globalStorage.currentFirebaseUser = nil
                        globalStorage.showSuccessMessage()
                    }, label: {
                        Text("Sign Out")
                            .font(.title)
                            .foregroundColor(.accent)
                    })
                    .padding(.bottom)
                }
            }
        }
    }
    
    private func makeRequest() -> ASAuthorizationAppleIDRequest{
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        myNounce = AuthenticationManager.shared.getSha256(AuthenticationManager.shared.getRandomNonceString())
        request.nonce = myNounce
        return request
    }
    
    private func makeAppleCred(credential: ASAuthorizationAppleIDCredential) throws -> AuthCredential{
        guard let appleIDToken = credential.identityToken else {  throw BPError.unableToComplete }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw BPError.unableToComplete }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: myNounce,
            fullName: credential.fullName
        )
        return credential
    }
}

#Preview {
    SettingsView()
        .environmentObject(GlobalStorage())
}
