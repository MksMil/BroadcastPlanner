import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct SettingsView: View {
    
    @EnvironmentObject var sessionStorage: GlobalSessionStorage
    @EnvironmentObject var appState: ApplicationState
    @Environment(\.authorizationController) private var authorizationController
    
    
    @State var newEmail: String = ""
    @State var newPassword: String = ""
    
    @State private var updEP: UpdatedEP?
    
    var body: some View {
//        NavigationStack{
            ZStack{
                MainBackground()
                ScrollView{
                    VStack{
                        if let user = sessionStorage.userSession{
                            Section{
                                VStack(alignment: .leading){
                                    Text("id: \(user.id)")
                                    Text("email: \(user.email ?? "empty")")
                                    Text("password: \(sessionStorage.password)")
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
                                Button {
                                    updEP = .email
                                } label: {
                                    Text("Change E-mail")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background {Color.white.opacity(30)}
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .padding(.horizontal)
                                }
                                
                                Button {
                                    updEP = .password
                                } label: {
                                    Text("Change Password")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background {Color.white.opacity(30)}
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .padding(.horizontal)
                                }
                                
                                //link with google button
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
                                
                                //link with Apple button
                                Button {
                                    Task{
                                        do {
                                            // Create the authorization request.
                                            let request = AppleHelper.makeRequest(storage: sessionStorage)
                                            
                                            // Perform the request and await its result.
                                            let result = try await authorizationController
                                                .performRequest(request)
                                            AuthenticationManager.shared.linkWithApple(result: result, currentNonce: sessionStorage.applCurrentNonce)
                                        } catch {
#if DEBUG
                                            print("DEBUG: Error linking with Apple")
#endif
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
                                    // TODO: set user is offline 
                                    print("try to log out")
                                    appState.userOnlineStatus = .offline
                                    try AuthenticationManager.shared.logOut()
                                    sessionStorage.userSession = nil
                                    appState.state = .notAuthorized
//
                                }catch {
                                    print("failed to signing out: \(error.localizedDescription)")
                                }
                            }
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
                                    sessionStorage.userSession = nil
                                    appState.state = .notAuthorized
                                    appState.userOnlineStatus = .offline
                                } catch {
#if DEBUG
                                    print("DEBUG:\(error.localizedDescription)")
#endif
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
//            .fullScreenCover(item: $updEP, content: { state in
//                switch state {
//                    case .email:
//                        UpdateEPView(
//                            currentValue: globalStorage.currentUser?.email ?? "",
//                            updEP: .email){ value in
//                                Task{
//                                    await sessionStorage.updateEmailPassword(newValue: value, updEp: .email)
//                                    updEP = nil
//                                }
//                            }
//                    case .password:
//                        UpdateEPView(
//                            currentValue: sessionStorage.password,
//                            updEP: .password){ value in
//                                Task{
//                                    await sessionStorage.updateEmailPassword(newValue: value, updEp: .password)
//                                    updEP = nil
//                                }
//                            }
//                }
//                
//            })
            .navigationBarBackButtonHidden()
//        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GlobalSessionStorage())
        .environmentObject(ApplicationState())
}


