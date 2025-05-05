import SwiftUI
import UIKit
import PhotosUI
import Combine

final class AddEditLocationViewModel: ObservableObject{
    
    @Published var localLocation: Location
    
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
    func removeElementAtIndex(_ indexSet: Int){
        let index = IndexSet(integer: indexSet)
        newImages.remove(atOffsets: index)
    }
    
    
    init(location: Location){
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
