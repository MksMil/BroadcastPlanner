import SwiftUI
import UIKit
import PhotosUI
import Combine

final class AddEditLocationViewModel: ObservableObject{
    
    var localLocation: LocalLocation
    
    @Published var title: String = ""
    @Published var address: String = ""

    @Published var locationPhotos: [PhotosPickerItem] = []
    
    @Published var eventBackground: PhotosPickerItem?
    @Published var locationBackground: Image = Image(systemName:"compass.drawing")
    
    var cancellables: Set<AnyCancellable> = []
   
    func makePublisher(){
        $locationPhotos.sink { [weak self] newValue in
            guard let self else { return }
            if !newValue.isEmpty{
                Task{
                    for photo in newValue{
                        guard let imageData = try? await photo.loadTransferable(type: Data.self),
                              let uiimage = UIImage(data: imageData) else { continue }
                        let localImage = DataManager.shared.createOrUpdateLocalImageWithImageData(imageData: ImageData(id: UUID().uuidString, type: GlobalProperties.ImageType.location.rawValue), withImage: uiimage, inContext: .main)
                        await DataManager.shared.moc.perform {                        
                            self.localLocation.addToImages(localImage)
                            localImage.parentLocationImage = self.localLocation
                        }
                    }
                    self.locationPhotos = []
                }
            }
        }
        .store(in: &cancellables)
    }

    
    init(location: LocalLocation){
        self.localLocation = location
        self.title = location.viewTitle
        self.address = location.viewAddress
        makePublisher()
    }
    
    
}
