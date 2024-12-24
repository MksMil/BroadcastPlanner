import SwiftUI
import UIKit
import FirebaseAuth
import AuthenticationServices

final class SettingsViewModel: ObservableObject{
    @MainActor
    func updateClub(with club: LocalClub,title: String, uiimage: UIImage?, contacts: String, urlString: String, location: LocalLocation?){
        Task{
            await DataManager.shared.updateClubWithClub(club: club,
                                                  title: title,
                                                  uiimage: uiimage,
                                                  contacts: contacts,
                                                  urlString: urlString,
                                                  location: location,
                                                  inContext: .main)
           await DataManager.shared.saveContext(type: .main,
                                           publish: .clubs,
                                           id: [club.viewId])
        }
    }
}



struct SettingsView: View {
    @StateObject var settingsRouter: SettingsTabRouter = SettingsTabRouter()
    @EnvironmentObject var sessionStorage: GlobalSessionStorage
    @EnvironmentObject var appState: ApplicationState
    @Environment(\.authorizationController) private var authorizationController
    @StateObject private var vm = SettingsViewModel()
    var body: some View {
        NavigationStack(path: $settingsRouter.path){
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
//                                    updEP = .email
                                    settingsRouter.path.append(SettingsTabPath.updateEmail)
                                } label: {
                                    Text("Change E-mail")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background {Color.white.opacity(30)}
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .padding(.horizontal)
                                }
                                
                                Button {
//                                    updEP = .password
                                    settingsRouter.path.append(SettingsTabPath.updatePassword)
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
                    VStack{
                        Section {
                            
                            Button {
                                settingsRouter.path.append(SettingsTabPath.clubSheet)
                            } label: {
                                Text("Add Club")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                            
                            Button {
                                settingsRouter.path.append(SettingsTabPath.locationSheet(nil))
                            }label: {
                                    Text("Add Location")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background {Color.white.opacity(30)}
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .padding(.horizontal)
                                }
                        } header: {
                            Text("Club and Location Edit")
                                .font(.title2)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .padding(.vertical)
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
            // MARK: - Navigation Destination Paths
            .navigationDestination(for: SettingsTabPath.self) { path in
                switch path {
                    case .updateEmail:
                        UpdateEPView(
                            currentValue: sessionStorage.email,
                            updEP: .email, cancelAction: {                                settingsRouter.routeStepBack()
                            }){ value in
                                Task{
                                    await sessionStorage.updateEmailPassword(newValue: value, updEp: .email)
                                }
                                settingsRouter.routeStepBack()
                            }
                    case .updatePassword:
                        UpdateEPView(
                            currentValue: sessionStorage.password,
                            updEP: .password, cancelAction: {                                settingsRouter.routeStepBack()
                            }){ value in
                                Task{
                                    await sessionStorage.updateEmailPassword(newValue: value, updEp: .password)
                                }
                                settingsRouter.routeStepBack()
                            }
                    case .clubSheet:
                        ClubSheetView(editMode: true) {
                            settingsRouter.routeStepBack()
                        } acceptAction: { club in
                            settingsRouter.routeStepBack()
                        } addEditAction: {club in
                            settingsRouter.path.append(SettingsTabPath.addEditClub(club))
                        }
                    case .locationSheet(let club):
                        LocationSheetView(club: club) {
                            settingsRouter.routeStepBack()
                        } saveAction: { _ in
                            settingsRouter.routeStepBack()
                        } addEditAction: { location in
                            settingsRouter.path.append(SettingsTabPath.addEditLocation(location))
                        }
                    case .addEditClub(let club):
                        AddEditClubView(club: club) { title, uiimage, contacts, urlString, location in
                            vm.updateClub(with: club, title: title, uiimage: uiimage, contacts: contacts, urlString: urlString, location: location)
                            Task{
                                await NetworkManager.shared.saveClub(Club.mapToClub(localClub: club))
                            }
                                settingsRouter.routeStepBack()
                        } cancelAction: {
                            DataManager.shared.moc.rollback()
                            settingsRouter.routeStepBack()
                        } removeAction: {
                            Task{
                                await NetworkManager.shared.removeClubWithId(club.viewId)
                            }
                            DataManager.shared.removeLocalClub(localClub: club, inContext: .main)
                            Task{
                                await DataManager.shared.saveContext(type: .main, publish: .clubs, id: [])
                                settingsRouter.routeStepBack()
                            }
                        } defineLocation: {
                            settingsRouter.path.append(SettingsTabPath.locationSheet(club))
                        }
                    case .addEditLocation(let location):
                        AddEditLocation(location: location) {
                            DataManager.shared.moc.rollback()

                            settingsRouter.routeStepBack()

                        } acceptAction: {
                            
                            settingsRouter.routeStepBack()

                        } removeAction: {
                            
                            Task{
                                await DataManager.shared.saveContext(type: .main, publish: .locations, id: [])
                                settingsRouter.routeStepBack()
                            }
                        }
                }
            }
        }
            .environmentObject(settingsRouter)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GlobalSessionStorage())
        .environmentObject(ApplicationState())
        .environment(\.managedObjectContext, DataManager.shared.moc)
}


