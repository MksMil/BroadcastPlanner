import CoreData
import SwiftUI
import UIKit

@MainActor
final class ClubSheetViewModel: ObservableObject {
   
    @Published var selectedClub: LocalClub?

    var buttonTitle: String {
        guard let selectedClub else { return "Choose Club" }
        return "\(selectedClub.viewTitle)"
    }
    var isAcceptDissabled: Bool {
        selectedClub == nil
    }
    
    var clubToRoute: LocalClub {
        if let selectedClub {
            return selectedClub
        } else {
            let newClub = DataManager.shared.fetchOrCreateClubWithId(UUID().uuidString, inContext: .main)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){            
                self.selectedClub = newClub
            }
            return newClub
        }
        
    }

    init() {}

}
