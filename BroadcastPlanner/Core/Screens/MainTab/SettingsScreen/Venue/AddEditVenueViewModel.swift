import SwiftUI
import UIKit
import PhotosUI
import Combine

final class AddEditVenueViewModel: ObservableObject{
    
    @Published var title: String = ""
    @Published var address: String = ""

    //create venue background images
    @Published var locationPhotoItems: [PhotosPickerItem] = []
    @Published var locationUiimages: [UIImage] = []
    
    //remove images from venue.images
    @Published var backgroundImageToRemove: LocalImage?
    let publisher = PassthroughSubject<(LocationEditPublishType,LocalImage),Never>()
    
    //create venueTemplate
    @Published var eventBackgroundItem: PhotosPickerItem?
    @Published var eventBackgroundUIImage: UIImage?

    //to link to venue
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
    
    init(venue: Venue){
        self.title = venue.viewTitle
        self.address = venue.viewAddress
        self.selectedEventTemplate = venue.broadcastSchema
        makePublisher()
//        if let locationBackground = venue.broadcastSchema{
//            eventTemplateSelected(locationBackground)
//        }
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
