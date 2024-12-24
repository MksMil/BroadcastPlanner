import SwiftUI
import UIKit
import PhotosUI
import Combine

final class AddEditLocationViewModel: ObservableObject{
    
    @Published var localLocation: LocalLocation
    
    @Published var title: String = ""
    @Published var address: String = ""

    @Published var locationPhotos: [PhotosPickerItem] = []
    @Published var newImages: [UIImage] = []
    
    @Published var localImages: [LocalImage] = []
    var localImageToRemove: LocalImage?
    var indexSetToRemove: Int?
    
    @Published var eventBackground: PhotosPickerItem?
//    var locationUIImage: UIImage?
    @Published var locationBackground: LocalImage?
    var locationBackgroundPreview: Image {
        locationBackground?.mediumImage ?? Image(systemName: "plus")
    }
    var cancellables: Set<AnyCancellable> = []
    
    
    func makePublisher(){
        
        $locationPhotos.sink { [weak self] newValue in
            guard let self else { return }
            if !newValue.isEmpty{
                Task{
                    for photo in newValue{
                        guard let imageData = try? await photo.loadTransferable(type: Data.self),
                              let uiimage = UIImage(data: imageData) else { continue }
                        await MainActor.run {
                            self.newImages.append(uiimage)
                        }
                    }
                    await MainActor.run {
                        self.locationPhotos = []
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    @MainActor
    func updateLocation() async{
        await withTaskGroup(of: Void.self) { group in
            for localImage in self.newImages{
                group.addTask { [weak self] in
                    guard let self else { return }
                    //backgroundImages add to set
                    print("create new LocalImage")
                    let newImage = DataManager.shared.createOrUpdateLocalImageWithImageData(imageData: ImageData(id: UUID().uuidString, type: GlobalProperties.ImageType.location.rawValue), withImage: localImage, inContext: .main)
                    await DataManager.shared.moc.perform {
                        print("linking LocalImage and location")
                        self.localLocation.addToImages(newImage)
                        newImage.parentLocationImage = self.localLocation
                    }
                }
            }
                group.addTask { [weak self] in
                    guard let self else { return }
                    //add backgroundToEvent
                    if let locationBackground =  self.locationBackground {
                        print("creating back in cd")
                        await DataManager.shared.moc.perform {
                            print("saving and linking location")
                            self.localLocation.background = locationBackground
                            locationBackground.parentLocationBackground = self.localLocation
                        }
                    }
                    
                    await DataManager.shared.moc.perform {
                        print("saving title and address")
                        self.localLocation.title = self.title
                        self.localLocation.address = self.address
                    }
                }
                await group.waitForAll()
//            print("updating final save context")
              await DataManager.shared.saveContext(type: .main,
                                                   publish: .locations,
                                               id: [])
            
            await NetworkManager.shared.saveLocation(localLocation.mapToLocation())
            
        }
        
    }
    func removeElementAtIndex(_ indexSet: Int){
        
        let index = IndexSet(integer: indexSet)
        newImages.remove(atOffsets: index)
    }
    
    
    init(location: LocalLocation){
        self.localLocation = location
        print("\(location.viewTitle)")
        self.title = location.viewTitle
        self.address = location.viewAddress
        self.localImages = location.viewLocalImages
        if let locationBackground = location.background{
            self.locationBackground = locationBackground
        }
        makePublisher()
    }
    
    
}
