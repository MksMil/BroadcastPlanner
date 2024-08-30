import SwiftUI
import NavigationTransitions

enum MainRoutes: Hashable, Codable {
    case auth, home
}

class MainRouter: ObservableObject {
    
    @Published var selectedPath = NavigationPath()
    var transitionType: AnyNavigationTransition = .default
    
    func goHome(){
        selectedPath.append(MainRoutes.home)
    }
    
    func goAuth(){
        selectedPath.append(MainRoutes.auth)
    }
    
    func popToRoot(){
        selectedPath.removeLast(selectedPath.count)
    }
}
