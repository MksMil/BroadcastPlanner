import SwiftUI

enum SettingsTabPath: Hashable{
    /*
     update email
     update password
     club sheet
     add edit club
     location sheet
     add edit location
     
     */
    case updateEmail
    case updatePassword
    case clubSheet
    case locationSheet(Club?)
    case addEditClub(Club)
    case addEditLocation(Location)
}

final class SettingsTabRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    func routeStepBack(){
        guard path.count > 0 else { return }
        path.removeLast()
    }
    
   
    init() {
        
    }
}
