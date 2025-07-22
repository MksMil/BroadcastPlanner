import SwiftUI
import _PhotosUI_SwiftUI

struct AddEditObvanView: View {
    
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager

    @EnvironmentObject var router: Router
    @StateObject var vm: AddEditObvanViewModel = AddEditObvanViewModel()
    
    let obvan: Obvan
    
    var body: some View {
        ZStack{
         MainBackground()
            Text("Hello, World!")
            //choose back image from library
            PhotosPicker(selection: $vm.selectedPhoto) {
                Text("Select photo")
                    .frame(width: 100, height: 20)
                    .padding(5)
                    
            }
            //accessAction(add to SKScene) in vm?
            
            //scscene
            
            //add edit panel
            
            //collection of crew
            
            //joystick
            
            
        }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    AddEditObvanView()
//}
