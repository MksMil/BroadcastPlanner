import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn


// MARK: - Main App
@main
struct BroadcastPlannerApp: App {
    var globalStorage = GlobalStorage()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isUserLoaded: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                BackgroundTabItem()
                    .onAppear{
                        Task{
                            globalStorage.currentFirebaseUser = AuthenticationManager.shared.getUser()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ isUserLoaded = true}
                        }
                    }
                
                StarterScreen()
                    .opacity(isUserLoaded ? 1 : 0)
                    .animation(.easeIn(duration: 3), value: isUserLoaded)
                    .environmentObject(globalStorage)
            }
            .environment(\.managedObjectContext,BPCoreDataContainer().persistanceConteiner.viewContext)
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
