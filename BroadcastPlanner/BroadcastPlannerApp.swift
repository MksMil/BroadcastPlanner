import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn


// MARK: - Main App
@main
struct BroadcastPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase

    @StateObject private var globalStorage = GlobalStorage()
    
    @State private var isUserLoaded: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                MainBackground()
                
                //loading animation ?
                
                StarterScreen()
                    .opacity(isUserLoaded ? 1 : 0)
                    .animation(.easeIn(duration: 1), value: isUserLoaded)
                    .environmentObject(globalStorage)
                
            }
            .onAppear{
                Task{
                    await globalStorage.getCurrentUser()
                }
                Task{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        if globalStorage.currentSessionUser != nil && globalStorage.currentUser != nil{
                            isUserLoaded = true
                        }
                    }
                }
            }
            .onChange(of: scenePhase, perform: { phase in
                switch phase {
                    case .active:
                        //send online status
//                        print("scene in foreground: send online status")
                        Task {
                            await globalStorage.goOnline()
                        }

                    case .background:
                        //send offline status
//                        print("scene in background: send offline status")
                        Task{
                            await globalStorage.goOffline()
                        }

                    case .inactive:
//                        print("scene in inactive: send inactive status")
                        Task {
                            await globalStorage.goOffline()
                        }

                    @unknown default:
                        print("scene in unknown phase: send unknown status")
                }
            })
        }
        
    }
}


// MARK: - AppDelegate, Firebase configuration, GID configuration
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
