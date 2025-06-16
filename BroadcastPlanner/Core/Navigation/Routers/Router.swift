import SwiftUI
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
    var statusBarSeq: [Bool] = [false]
    var statusBarVisibility: Bool {
        if let last = statusBarSeq.last, last {
            return true
        } else {
            return false
        }
    }
    
    var actionBarSeq:[Bool] = [false]
    var actionBarVisibility: Bool {
        if let last = actionBarSeq.last, last {
            return true
        } else {
            return false
        }
    }
    
    @Published var path: NavigationPath = NavigationPath()
    
    var transition: AnyNavigationTransition = .fade(.out)
    var interactivity: AnyNavigationTransition.Interactivity = .disabled
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        if statusBarSeq.count > 0{
            statusBarSeq.removeLast()
        }
        if actionBarSeq.count > 0{
            actionBarSeq.removeLast()
        }
        path.removeLast()
    }
    
    func stateForStatusBar(_ isStatus: Bool, andActionBar isAction: Bool){
        statusBarSeq.append(isStatus)
        actionBarSeq.append(isAction)
    }
    
    // MARK: broadcastList
    func routeTo(path: RouterPath,
                 withTransition transition: AnyNavigationTransition = .fade(.out),
                 andInteractivity interactivity: AnyNavigationTransition.Interactivity = .disabled){
        switch path {
            case .animatedStart,.authScreen:
                stateForStatusBar(false, andActionBar: false)
            case .createEdit:
                stateForStatusBar(false, andActionBar: true)
            case .broadcastList:
                stateForStatusBar(true, andActionBar: false)            
//            case .stadPointsEdit:
//                <#code#>
//            case .carPointsEdit(let bool):
//                <#code#>
//            case .ownerInfo:
//                <#code#>
//            case .memberView:
//                <#code#>
//            case .updateEmail:
//                <#code#>
//            case .updatePassword:
//                <#code#>
//            case .clubSheet:
//                <#code#>
//            case .locationSheet(let club):
//                <#code#>
//            case .addEditClub(let club):
//                <#code#>
//            case .addEditLocation(let venue):
//                <#code#>
//            case .addEditObvan:
//                <#code#>
            default: statusBarSeq.append(true)
        }
        self.path.append(path)
        self.transition = transition
        self.interactivity = interactivity
    }
    func routeToAuth(){
        transition = .fade(.out)
        path.removeLast(path.count - 1)
        statusBarSeq = [false]
        actionBarSeq = [false]
        path.append(RouterPath.authScreen)
    }
    
    
}


