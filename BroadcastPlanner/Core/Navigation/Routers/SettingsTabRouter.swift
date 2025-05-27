import SwiftUI

enum SettingsTabPath: Hashable{
    /*
     update email
     update password
     club sheet
     add edit club
     venue sheet
     add edit venue
     
     */
    case updateEmail
    case updatePassword
    case clubSheet
    case locationSheet(Club?)
    case addEditClub(Club)
    case addEditLocation(Venue)
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
