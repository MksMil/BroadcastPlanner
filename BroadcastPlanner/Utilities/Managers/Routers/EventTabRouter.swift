import SwiftUI

enum EventTabPath: Hashable{
    case create(Event)
    case edit(Event)
    case stadPointsEdit
    case carPointsEdit
}

final class EventTabRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        path.removeLast()
    }
    
    func routeToCreate(event: Event){
        path.append(EventTabPath.create(event))
    }
    
    func routeToEdit(event: Event){
        path.append(EventTabPath.edit(event))
    }
    
    func routeToStadPointsEdit(){
        
    }
    
    func routeToCarPointsEdit(){
        
    }
    init() {
        
    }
}
