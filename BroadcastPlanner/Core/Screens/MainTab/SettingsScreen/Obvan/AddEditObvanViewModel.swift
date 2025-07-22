import SpriteKit
import _PhotosUI_SwiftUI
import UIKit
import Combine


class AddEditObvanViewModel: ObservableObject{
    var selectedPhoto: PhotosPickerItem? {
        willSet{
            Task{
                guard let item = newValue,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data)
                else { return }
                self.uiimage = image
            }
        }
    }
    
    var uiimage: UIImage?{
        willSet{
            if let newValue{
                //update SKScene background
            }
        }

    }
}
