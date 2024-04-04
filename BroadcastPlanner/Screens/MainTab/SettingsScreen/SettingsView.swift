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
                ScrollView{
                    VStack{
                        if let user = globalStorage.currentFirebaseUser{
                            Section{
                                VStack(alignment: .leading){
                                    Text("id: \(user.id)")
                                    Text("email: \(user.email ?? "empty")")
                                    Text("Creation date: \(user.creationDate?.formatted() ?? "no date")")
                                }
                                .foregroundStyle(Color.accent)                                    
                                .padding()
                                .background{ RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray).opacity(0.2)
                                }
                            } header: {
                                Text("Private Info")
                                    .font(.title)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                            }
                        }
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
                                            print("Error linking with Apple")
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
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background {Color.white.opacity(30)}
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.horizontal)
                        })
                        .padding(.bottom)
                        
                        // MARK: - Delete user
                        Button(role: .destructive) {
                            // TODO: Alert with delete confirmation must have
                            Task{
                                do{
                                    try await AuthenticationManager.shared.deleteUser()
                                } catch {
                                    globalStorage.showBPError(error: BPError.unableToComplete)
                                }
                            }
                        } label: {
                            Text("Delete account")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background {Color.white.opacity(30)}
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }.foregroundStyle(Color.accent)
                }
            }
        }
    }
    
    private func makeRequest() -> ASAuthorizationAppleIDRequest{
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        myNounce = AuthenticationManager.shared.getRandomNonceString()
        let requestNounce = AuthenticationManager.shared.getSha256(myNounce)
        request.nonce = requestNounce
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
