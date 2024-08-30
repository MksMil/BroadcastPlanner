import Foundation

//object for manage authentication and session information

@MainActor
final class GlobalSessionStorage: ObservableObject{
    
    @Published var userSession: SessionUser?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    var applCurrentNonce: String = ""
    
    func getUserSession(){
        
    }
    
    func signUp()async{
        do{
            userSession = try await AuthenticationManager.shared.createUser(email: email, password: password)
        } catch {
            //alert?
#if DEBUG
            print("DEBUG: GlobalSessopnStorage/func signUp/ - user creation failed: \(error)")
#endif
        }
    }
    
    func signInWithEmailAndPassword() async {
            do {
                userSession = try await AuthenticationManager.shared.signIn(
                    withEmail: email,
                    password: password
                )
            } catch {
                //alert?
#if DEBUG
                print("DEBUG:GlobalSession/func signInWithEmailAndPassword failed: \(error)")
#endif
            }
    }
    
    func signInWithGoogle() async {
        do{
            userSession = try await AuthenticationManager.shared.signWithGgl()
        } catch {
            //alert?
#if DEBUG
            print("DEBUG: GlobalSessopnStorage/func signInWithGoogle/ - sign in with google failed: \(error)")
#endif
        }
    }
    
    
    // MARK: - Update password email
    func updateEmailPassword(newValue: String, updEp: UpdatedEP) async{
        guard let userSession,
              let oldValue = userSession.email
        else {
            print("wrong userSession")
            //alert?
            return
        }
        AuthenticationManager.shared.update(email: oldValue,
                                            password: password,
                                            updEp:updEp == .email ? .email: .password,
                                            newValue: newValue)
    }
    
}
