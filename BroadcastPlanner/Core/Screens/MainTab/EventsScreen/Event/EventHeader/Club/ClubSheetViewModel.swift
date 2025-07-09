import CoreData
import SwiftUI
import UIKit

@MainActor
final class ClubSheetViewModel: ObservableObject {
   @Published var selectedClub: Club?
}
