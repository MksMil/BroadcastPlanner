import CoreData
import SwiftUI
import UIKit

@MainActor
final class ClubSheetViewModel: ObservableObject {
   
    @Published var selectedClub: Club?

    var buttonTitle: String {
        guard let selectedClub else { return "Choose Club" }
        return "\(selectedClub.viewTitle)"
    }
    var isAcceptDissabled: Bool {
        selectedClub == nil
    }
 
    init() {}

}
