import SwiftUI

final class AddCameraViewModel: ObservableObject{
    @Published var cameraNumber: String = "0"
    @Published var selectedUserName: String = "Empty"
    @Published var position: CameraPosition = .mainMatch
    
}
