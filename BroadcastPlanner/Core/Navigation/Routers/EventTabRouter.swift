import SwiftUI

enum EventTabPath: Hashable{
    case createEdit
    case stadPointsEdit(Bool)
    case carPointsEdit(Bool)
}

final class EventTabRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        path.removeLast()
    }
    
    func routeToCreateEdit(){
        path.append(EventTabPath.createEdit)
    }
    
    func routeToStadPointsEdit(editable: Bool){
        path.append(EventTabPath.stadPointsEdit(editable))
    }
    
    func routeToCarPointsEdit(editable: Bool){
        path.append(EventTabPath.carPointsEdit(editable))
    }
    init() {
        
    }
}
