import SwiftUI

final class Storage: ObservableObject {
 
    @Published var cameras: [Camera]
    @Published var lastSelected: Camera?
    @Published var possibleCameras: [Camera] =
        CameraPosition.allCases.map{Camera(position: $0)}
    
    @Published var users: [User]
    @Published var selectedUserName: String = "Empty cam"
    
    init(cameras: [Camera] = [], users: [User] = []){
        self.cameras = cameras
        self.users = users
        
    }
    
    func addCamera(cam: Camera){
        if !possibleCameras.isEmpty, let index = possibleCameras.firstIndex(of: cam){
            possibleCameras.remove(at: index)
            cameras.append(cam)
            cam.cameraMan = users.first(where: { $0.name == selectedUserName}) ?? User()
            cam.cameraMan.reserved = true
        }
    }
    func select(cam: Camera){

        if let lastSelected {
            if lastSelected == cam {
                cam.selected.toggle()
                self.lastSelected = nil
            } else {
                lastSelected.selected.toggle()
                cam.selected.toggle()
                self.lastSelected = cam
            }
        } else {
            cam.selected.toggle()
            self.lastSelected = cam
        }
    }
    
    func deselect(){
        if let lastSelected {
            lastSelected.selected.toggle()
            self.lastSelected = nil
        }
    }
    
    func assignSelectedUser(){
        
            selectedUserName = users.first(where: { !$0.reserved
            })?.name ?? User().name
        print(selectedUserName)
    }
}
