import SwiftUI

final class Storage: ObservableObject {
    @Published var events: [Event]
    @Published var cameras: [Camera]
    @Published var lastSelected: Camera?
    @Published var possibleCameras: [Camera] =
        CameraPosition.allCases.map{Camera(position: $0)}
    
    @Published var users: [User]
    @Published var selectedUserName: String = "Empty cam"
    
    init(events: [Event] = [],cameras: [Camera] = [], users: [User] = []){
        self.events = events
        self.cameras = cameras
        self.users = users
    }
    
    func addUser(user: User){
        guard !users.contains(where: { $0 == user}) else {
        //alert "This user already exist" here
            return
        }
        users.append(user)
    }
    
    func addCamera(position: CameraPosition, userName: String, camNumber: String){
        let cam = Camera(position: position)
        cam.cameraMan = possibleUsers.first(where: { $0.name == userName}) ?? User()
        cam.cameraMan.reserved = true
        if !possibleCameras.isEmpty, let index = possibleCameras.firstIndex(of: cam){
            possibleCameras.remove(at: index)
            cameras.append(cam)
        }
    }
    
    func deleteCamera(indexSet: IndexSet){
        indexSet.forEach { index in
            cameras[index].cameraMan.reserved = false
            possibleCameras.insert(Camera(position: cameras[index].position), at: 0)
            print(cameras[index])
        }
        cameras.remove(atOffsets: indexSet)
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
    
    
    
    //
    var isUsersAvailable: Bool {
         !users.filter({!$0.reserved}).isEmpty
    }
    var possibleUsers: [User] {
        users.filter { !$0.reserved }
    }
 
    var isCamerasAvailable: Bool {
        !possibleCameras.isEmpty
    }
}
