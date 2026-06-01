import SwiftUI

@MainActor
class ObvanPickerSheetViewModel: ObservableObject {
    @Published var images: [String: UIImage] = [:] // obvanId → UIImage
    
    let obvans: [Obvan]
    let alreadyAdded: [Obvan]
    private let dataManager: DataManager
    
    var available: [Obvan] {
        obvans.filter { obvan in
            !alreadyAdded.contains(where: { $0.id == obvan.id })
        }
    }
    
    init(obvans: [Obvan], alreadyAdded: [Obvan], dataManager: DataManager) {
        self.obvans = obvans
        self.alreadyAdded = alreadyAdded
        self.dataManager = dataManager
    }
    
    func loadImages() async {
        for obvan in available {
            guard !obvan.viewImageId.isEmpty else { continue }
            let image = await dataManager.getImageWithId(
                obvan.viewImageId,
                type: .obvan,
                size: .smallImages
            )
            if let image {
                images[obvan.viewId] = image
            }
        }
    }
}
