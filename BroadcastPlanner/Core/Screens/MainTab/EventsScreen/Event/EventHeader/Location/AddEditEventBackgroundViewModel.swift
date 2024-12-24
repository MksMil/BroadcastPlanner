import SwiftUI
import UIKit
import PhotosUI

final class AddEditEventBackgroundViewViewModel: ObservableObject{
    
    @Published var selectedImage: LocalImage?
    var eventBackgroundItem: PhotosPickerItem?{
        willSet{
            guard let item = newValue else { return }
            Task{
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiimage = UIImage(data: data){
                    createNewLocalImageWith(uiimage: uiimage)
                }
            }
        }
        didSet{
            eventBackgroundItem = nil
        }
    }
    
    init(){
        
    }
    func createNewLocalImageWith(uiimage: UIImage){
        Task{
            let _ = DataManager
                .shared
                .createOrUpdateLocalImageWithId(UUID().uuidString,
                                                withImage: uiimage,
                                                andType: GlobalProperties.ImageType.eventTemplate,
                                                inContext: .bg)
            await  DataManager.shared.saveContext(type: .bg,
                                           publish: .none,
                                           id: [])
        }
    }

    func removeImage(){
        if let localImageToRemove = selectedImage{
            selectedImage = nil
            DataManager.shared.removeLocalImage(localImageToRemove, inContext: .main)
            Task{
                await DataManager.shared.saveContext(type: .main, publish: .none, id: [])
            }
        }
    }
}
