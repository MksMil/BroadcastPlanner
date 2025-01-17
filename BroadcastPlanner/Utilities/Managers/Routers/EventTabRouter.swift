import SwiftUI

enum EventTabPath: Hashable{
    case createEdit(LocalEvent)
    case stadPointsEdit(LocalEvent,Bool)
    case carPointsEdit
}

final class EventTabRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        path.removeLast()
    }
    
    func routeToCreateEdit(event: LocalEvent){
        path.append(EventTabPath.createEdit(event))
    }
    
    func routeToStadPointsEdit(event: LocalEvent, editable: Bool){
        path.append(EventTabPath.stadPointsEdit(event, editable))
    }
    
    func routeToCarPointsEdit(){
        
    }
    init() {
        
    }
}
