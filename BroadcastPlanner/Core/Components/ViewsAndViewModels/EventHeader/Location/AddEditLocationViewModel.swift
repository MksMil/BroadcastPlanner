import SwiftUI
import UIKit
import PhotosUI

final class AddEditLocationViewModel: ObservableObject{
    
    var localLocation: LocalLocation
    
    @Published var title: String = ""
    @Published var address: String = ""

    @Published var locationPhotos: [PhotosPickerItem] = []
    @Published var localImages: [Image] = []
    
    @Published var eventBackground: PhotosPickerItem?
    @Published var locationBackground: Image = Image(systemName:"compass.drawing")
    
    
    
    init(location: LocalLocation){
        self.localLocation = location
        self.title = location.viewTitle
        self.address = location.viewAddress
    }
    
    
}
