import SwiftUI
import PhotosUI
import Combine

final class AddEditVenueViewModel: ObservableObject{
 //create venue background images
    @Published var locationPhotoItems: [PhotosPickerItem] = []
    @Published var uiimages: [UIImage] = []
    //create venueTemplate
    @Published var eventBackgroundItem: PhotosPickerItem?
    @Published var eventBackgroundUIImage: UIImage?
    //to link to venue
    @Published var selectedEventTemplate: String?
    //remove images from venue.images
    @Published var backgroundImageToRemove: String?
    
    let publisher = PassthroughSubject<(LocationEditPublishType,String),Never>()
    private var cancellables = Set<AnyCancellable>()
    var tempImages: [UIImage] = []
    init(venue: Venue){
        self.selectedEventTemplate = venue.broadcastSchema?.viewId
        makePublisher()
    }
    
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
                        self.uiimages = self.tempImages
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
    
    //tabList animation helper
    func eventTemplateSelected(_ localImage: String){
        selectedEventTemplate = selectedEventTemplate == localImage ? nil:localImage
        publisher.send((LocationEditPublishType.eventTemplate,localImage))
    }
    //tabList animation helper 
    func backgroundSelected(_ localImage: String){
        backgroundImageToRemove = backgroundImageToRemove == localImage ? nil: localImage
        publisher.send((LocationEditPublishType.background,localImage))
    }
}
