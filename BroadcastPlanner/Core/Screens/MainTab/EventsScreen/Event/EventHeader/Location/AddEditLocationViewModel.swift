import SwiftUI
import UIKit
import PhotosUI
import Combine

final class AddEditLocationViewModel: ObservableObject{
    
    @Published var title: String = ""
    @Published var address: String = ""

    @Published var locationPhotoItems: [PhotosPickerItem] = []
    @Published var locationUiimages: [UIImage] = []
    
    //remove images from location.images
    @Published var backgroundImageToRemove: LocalImage?
    let publisher = PassthroughSubject<(LocationEditPublishType,LocalImage),Never>()
    
    //create eventTemplate
    @Published var eventBackgroundItem: PhotosPickerItem?
    @Published var eventBackgroundUIImage: UIImage?

    //to link to location
    @Published var selectedEventTemplate: LocalImage?
    var tempImages: [UIImage] = []
    var cancellables: Set<AnyCancellable> = []
    
    //bg
   
    func makePublisher(){
        $locationPhotoItems.sink { [weak self] newValue in
            guard let self else { return }
            
            if !newValue.isEmpty{
                Task{
                    for photo in newValue{
                        guard let imageData = try? await photo.loadTransferable(type: Data.self),
                              let uiimage = UIImage(data: imageData) else { continue }
                        self.tempImages.append(uiimage)
                    }
                    
                    await MainActor.run {
                        self.locationUiimages = self.tempImages
                        self.tempImages = []
                    }
                    await MainActor.run {
                        self.locationPhotoItems = []
                        
                    }
                }
            }
        }
        .store(in: &cancellables)
        
        $eventBackgroundItem.sink {[weak self] newValue in
            guard let self else { return }
            guard let item = newValue else {
                return
            }
            Task{
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiimage = UIImage(data: data){
                    await MainActor.run {
                        self.eventBackgroundUIImage = uiimage
                    }
                }
               await MainActor.run {
                   self.eventBackgroundItem = nil
                }
            }
        }
        .store(in: &cancellables)
    }
    
    init(location: Location){
        self.title = location.viewTitle
        self.address = location.viewAddress
        if let locationBackground = location.background{
            self.selectedEventTemplate = locationBackground
        }
        makePublisher()
    }
    
    func eventTemplateSelected(_ localImage: LocalImage){
        selectedEventTemplate = selectedEventTemplate == localImage ? nil:localImage
        publisher.send((LocationEditPublishType.eventTemplate,localImage))
    }
    func backgroundSelected(_ localImage: LocalImage){
        backgroundImageToRemove = backgroundImageToRemove == localImage ? nil: localImage
        publisher.send((LocationEditPublishType.background,localImage))
    }
}
