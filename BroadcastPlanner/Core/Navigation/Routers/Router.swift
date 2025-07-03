import SwiftUI
import Combine
import SwiftUINavigationTransitions

enum RouterPath: Hashable{
    //app open
    case animatedStart
    //!authenticated
    case authScreen
    //authenticated
    case broadcastList
    //create new
    case createEdit(Broadcast)
    //...flow
    case stadPointsEdit
    case carPointsEdit(Bool)
    
    
    
    
    //session member progile
    case ownerInfo
    
    //case existing member explore view
    case memberView
    
    case settings
    //settings
    case updateEmail
    case updatePassword
    case clubSheet
    case locationSheet(Club?)
    case addEditClub(Club)
    case addEditLocation(Venue)
    case addEditObvan
}

@MainActor
final class Router: ObservableObject {
    
    @Published var path: NavigationPath = NavigationPath()

    //routing
    var transition: AnyNavigationTransition = .fade(.out)
    var interactivity: AnyNavigationTransition.Interactivity = .disabled
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        path.removeLast()
    }

    // MARK: broadcastList
    func routeTo(path: RouterPath,
                 withTransition transition: AnyNavigationTransition = .fade(.out),
                 andInteractivity interactivity: AnyNavigationTransition.Interactivity = .disabled){

                self.path.append(path)
                self.transition = transition
                self.interactivity = interactivity
    }
    func routeToAuth(){
        transition = .fade(.out)
        path.removeLast(path.count)
        routeTo(path: .authScreen)
    }
    
    func routeFrom(from: RouterPath, to: RouterPath){
        switch from {
            case .ownerInfo, .settings:
                self.path.removeLast()
                self.path.append(to)
            default: self.path.append(to)
        }
    }
}


