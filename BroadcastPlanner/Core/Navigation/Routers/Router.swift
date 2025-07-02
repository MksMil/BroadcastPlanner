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
    
    var acceptAction: ()->() = {}
    var removeAction: ()->() = {}
    var stepBackAction: ()->() = {}
    
    
    //actionView control
    var isAcceptButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    var isRemoveButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    
    var isAcceptButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    var isRemoveButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    
    var isMessengerActivePublisher = PassthroughSubject<Bool,Never>()
    var unreadMessagesPublisher = PassthroughSubject<Int,Never>()
    var unreadMessages: Int = 999 {
        willSet{
            unreadMessagesPublisher.send(newValue)
        }
    }
    
    //routing
    var transition: AnyNavigationTransition = .fade(.out)
    var interactivity: AnyNavigationTransition.Interactivity = .disabled
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        path.removeLast()
    }
    
    func makeAcceptButtonEnabled(_ enabled: Bool){
        isAcceptButtonEnabledPublisher.send(enabled)
    }
    func makeRemoveButtonEnabled(_ enabled: Bool){
        isRemoveButtonEnabledPublisher.send(enabled)
    }
    func makeAcceptButtonVisible(_ visible: Bool){
        isAcceptButtonVisiblePublisher.send(visible)
    }
    func makeRemoveButtonVisible(_ visible: Bool){
        isRemoveButtonVisiblePublisher.send(visible)
    }
    func makeMessengerActive(_ active: Bool){
        isMessengerActivePublisher.send(active)
    }
    
    func setUnreadMessages(num: Int){
        guard num >= 0 else{ return }
        unreadMessages = num
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
}


