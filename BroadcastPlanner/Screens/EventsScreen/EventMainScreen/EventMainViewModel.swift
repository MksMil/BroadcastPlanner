import Foundation

final class EventMainViewModel: ObservableObject {
    @Published var selectedCam: Int?
    @Published var cameras: [Camera]
 
    var possibleCameras: [Camera] =
        CameraPosition.allCases.map{Camera(position: $0)}
    
    init(cameras: [Camera]){
        self.cameras = cameras
    }
    
    func addCamera(){
        if !possibleCameras.isEmpty{
            let cam = possibleCameras.remove(at: Int.random(in: 0..<possibleCameras.count))
            cameras.append(cam)
        }
    }
}
