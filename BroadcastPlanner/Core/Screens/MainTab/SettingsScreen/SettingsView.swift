import SwiftUI
import UIKit
import FirebaseAuth
import AuthenticationServices

struct SettingsView: View {

    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var sessionManager: SessionManager
    
    @EnvironmentObject var mdm: DataManager

    @Environment(\.authorizationController) private var authorizationController

    var body: some View {

        ScrollView{
                    Button {
                        // settingsRouter.path.append(SettingsTabPath.updateEmail)
                    } label: {
                        Text("Change E-mail")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background {Color.white.opacity(30)}
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                    }
                    
                    Button {
                        //                                    settingsRouter.path.append(SettingsTabPath.updatePassword)
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
                    //                                settingsRouter.path.append(SettingsTabPath.clubSheet)
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
                    //                                settingsRouter.path.append(SettingsTabPath.locationSheet(nil))
                }label: {
                    Text("Add Venue")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {Color.white.opacity(30)}
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }

            // MARK: - "Sign out" button

                Button(action: {
                    Task{
                        do{
                            appState.userOnlineStatus = .offline
                            try sessionManager.logOut()
                            appState.state = .notAuthorized
                            
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
                
                // MARK: - Delete member
                Button(role: .destructive) {
                    // TODO: Alert with delete confirmation must have
                    Task{
                        do{
                            try sessionManager.logOut()
                            try await sessionManager.deleteUser()
                            appState.state = .notAuthorized
                            appState.userOnlineStatus = .offline
                            mdm.clearData()
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
        .border(Color.green, width: 3)
        .navigationBarBackButtonHidden()
            // MARK: - Navigation Destination Paths
//            .navigationDestination(for: SettingsTabPath.self) { path in
//                switch path {
//                    case .updateEmail:
//                        UpdateEPView(
//                            currentValue: sessionManager.email,
//                            updEP: .email, cancelAction: {                                //settingsRouter.routeStepBack()
//                            }){ value in
//                                Task{
//                                    await sessionManager.updateEmailOrPassword(newValue: value, type: .email)
//                                }
////                                settingsRouter.routeStepBack()
//                            }
//                    case .updatePassword:
//                        UpdateEPView(
//                            currentValue: sessionManager.password,
//                            updEP: .password, cancelAction: {
//                                //settingsRouter.routeStepBack()
//                            }){ value in
//                                Task{
//                                    await sessionManager.updateEmailOrPassword(newValue: value, type: .password)
//                                }
////                                settingsRouter.routeStepBack()
//                            }
//                    case .clubSheet:
//                        ClubSheetView(editMode: true) {
////                            settingsRouter.routeStepBack()
//                        } acceptAction: { club in
////                            settingsRouter.routeStepBack()
//                        } addEditAction: {club in
////                            settingsRouter.path.append(SettingsTabPath.addEditClub(club))
//                        }
//                    case .locationSheet(let club):
//                        LocationSheetView(club: club) {
////                            settingsRouter.routeStepBack()
//                        } saveAction: { _ in
////                            settingsRouter.routeStepBack()
//                        } addEditAction: { location in
////                            settingsRouter.path.append(SettingsTabPath.addEditLocation(location))
//                        }
//                    case .addEditClub(let club):
//                        AddEditClubView(club: club) { title, uiimage, contacts, urlString, location in
////                            Task{
////                                await mdm.updateClub(club, withTitle: title, uiimage: uiimage, contacts: contacts, urlString: urlString, location: location, inContext: .main)
////                                settingsRouter.routeStepBack()
////                            }
//                        } cancelAction: {
//                            mdm.rollBackMoc()
////                            settingsRouter.routeStepBack()
//                        } removeAction: {
////                            Task{
////                                await mdm.removeCub(club)
////                                settingsRouter.routeStepBack()
////                            }
//                        } defineLocation: {
////                            settingsRouter.path.append(SettingsTabPath.locationSheet(club))
//                        }
//                    case .addEditLocation(let location):
//                        AddEditLocationView(location: location) { title, address, images, localImage in
////                            Task{
////                                await mdm.updateLocalLocation(location, withTitle: title, address: address, images: images, background: localImage)
////                                settingsRouter.routeStepBack()
////                            }
//                        } cancelAction: {
//                            mdm.rollBackMoc()
////                            settingsRouter.routeStepBack()
//                        } removeAction: {
////                            Task{
////                                //remove
////                                await mdm.saveContextAsync(type: .main, publish: .venues, id: [])
////                                settingsRouter.routeStepBack()
////                            }
//                        }
//                }
//            }
//        }
//            .environmentObject(settingsRouter)
    }
}


#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
        .environmentObject(Router())
}

