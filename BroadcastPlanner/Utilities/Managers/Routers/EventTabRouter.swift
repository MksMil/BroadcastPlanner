import SwiftUI

enum EventTabPath: Hashable{
    case createEdit(LocalEvent)
    case addEditClub(LocalClub)
    case addEditLocation(LocalLocation)
    case stadPointsEdit
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
    
    func routeToAddEditLocation(location: LocalLocation){
        path.append(EventTabPath.addEditLocation(location))
    }
    
    func routeToAddEditClub(club: LocalClub){
        path.append(EventTabPath.addEditClub(club))
    }
    
    func routeToStadPointsEdit(){
        
    }
    
    func routeToCarPointsEdit(){
        
    }
    init() {
        
    }
}
