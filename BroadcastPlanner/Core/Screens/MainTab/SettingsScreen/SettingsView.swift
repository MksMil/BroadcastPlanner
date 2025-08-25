import SwiftUI
import UIKit
import FirebaseAuth
import AuthenticationServices

struct SettingsView: View {

    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var sessionManager: SessionManager
    
    @EnvironmentObject var dataManager: DataManager

    @Environment(\.authorizationController) private var authorizationController

    var body: some View {
        ZStack{
            MainBackground()
            ScrollView{
                Button {
                    router.routeTo(path: .updateSessionUserData)
                } label: {
                    Text("Change E-mail or Password")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {Color.white.opacity(30)}
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }
                
                //link with google button
                Button {
                    Task{
                        await sessionManager.linkWithGoogle()
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
                            let request = sessionManager.makeRequest()
                            
                            // Perform the request and await its result.
                            let result = try await authorizationController
                                .performRequest(request)
                            sessionManager.linkWithApple(result: result)
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
                
                //superUser section
                
                //add club
                Button {
                    router.routeTo(path: .clubCollection)
                } label: {
                    Text("Add Club")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {Color.white.opacity(30)}
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }
                //add venue
                Button {
                    router.routeTo(path: RouterPath.venueCollection)
                }label: {
                    Text("Add Venue")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {Color.white.opacity(30)}
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }
                //add obvan
                Button {
                    router.routeTo(path: RouterPath.obvanCollection)
                }label: {
                    Text("Add Obvan")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {Color.white.opacity(30)}
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }
                //TODO: edit settings view
                Button {
//                    router.routeTo(path: RouterPath.venueCollection)
                    Task{
                       await dataManager.networkManager.saveGlobalSettingsToFirestore()
                    }
                }label: {
                    Text("Save settings")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {Color.white.opacity(30)}
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }
                
                // MARK: - Delete member
                Button(role: .destructive) {
                    // TODO: Alert with delete confirmation must have
                    Task{
                        do{
                            try sessionManager.logOut()
                            try await sessionManager.deleteUser()
                            appState.state = .notAuthorized
                            appState.userOnlineStatus = .offline
                            dataManager.clearData()
                            router.routeToAuth()
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
            }
            .scrollContentBackground(.hidden)
            .transitionWithOpacity()
        }
        .navigationBarBackButtonHidden()
        .onAppear{
            appState.primaryAction = {
            }
            appState.secondaryAction = {}
            appState.stepBackAction = {
                appState.setMenuState(state: .none)
                router.stepBack()
            }
        }
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif

