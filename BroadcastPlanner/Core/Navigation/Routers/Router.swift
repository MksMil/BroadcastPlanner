import SwiftUI
import Combine


enum RouterPath: Hashable{
    //app open
    case animatedStart
    //!authenticated
    case authScreen
    //authenticated
    //flow
    
    case broadcastList
    //create new
    case createEdit(Broadcast)
    
    //...flow
    case stadPointsEdit(Broadcast)
    case carPointsEdit(Bool)
    
    
    
    
    //session member progile
    case ownerInfo
    //case existing member explore view
    case memberView
    
    case settings
    //settings
    case updateEmail
    case updatePassword
    case clubCollection
    case venueCollection
    case obvanCollection
    
    case addEditClub(Club)
    case addEditVenue(Venue)
    case addEditObvan(Obvan)
    
    case messenger
}

@MainActor
final class Router: ObservableObject {
    
    @Published var path: NavigationPath = NavigationPath()

    //appState control
    var listFlow: [RouterPath] = [.broadcastList]
    var messengerFlow: [RouterPath] = [.messenger]
    
    var activeFlow: [RouterPath] = []
    
    let pathPubisher = CurrentValueSubject<RouterPath,Never>(.animatedStart)
    
    ///routing
    func executeLastPathFromActiveFlow(){
        if let last = activeFlow.last {
            if path.count > 0{
                path.removeLast()
            }
            path.append(last)
            publishState()
        }
    }
    
    func stepBack(){
        guard activeFlow.count > 1 else { return }
        activeFlow.removeLast()
        executeLastPathFromActiveFlow()
    }
    
    func routeTo(path: RouterPath){
        activeFlow.append(path)
        executeLastPathFromActiveFlow()
    }
    func routeToAuth(){ //settings/delete account
        path.removeLast(path.count)
        messengerFlow = [.messenger]
        listFlow = [.broadcastList]
        activeFlow.removeAll()
        activeFlow.append(.authScreen)
        executeLastPathFromActiveFlow()
        
    }

    func routeFrom(from: RouterPath, to: RouterPath){
        switch (from,to) {
            case (.ownerInfo, .settings),
                (.settings, .ownerInfo):
                activeFlow.removeLast()
                activeFlow.append(to)
                
            default:
                activeFlow.append(to)
        }
        executeLastPathFromActiveFlow()
    }
    
    func routeFromNotification(path: RouterPath){
        
    }
    
    func changeToMessanger(){
        listFlow = activeFlow
        activeFlow = messengerFlow
        
        executeLastPathFromActiveFlow()
    }
    func changeToList(){
        messengerFlow = activeFlow
        activeFlow = listFlow
        executeLastPathFromActiveFlow()
    }
    
    func publishState(){
        if let last = activeFlow.last{
            pathPubisher.value = last
        }
    }
}


