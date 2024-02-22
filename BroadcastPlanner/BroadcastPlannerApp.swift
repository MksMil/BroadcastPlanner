import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

// MARK: - Main App
@main
struct BroadcastPlannerApp: App {
    var globalStorage = GlobalStorage()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            StarterScreen()
                .onAppear{
                    Task{
                        do{
                            globalStorage.currentFirebaseUser = try AuthenticationManager.shared.getUser()
                        } catch {
                            print("no current user")
                        }
                    }
                }
                .environmentObject(globalStorage)
        }
    }
}


// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
