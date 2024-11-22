import SwiftUI
import UIKit
import CoreData

@MainActor
final class ClubSheetViewModel: ObservableObject{
    @Published var isEditState: Bool = false
    @Published var selectedClub: LocalClub?
        
    var buttonTitle: String {
        guard let selectedClub else {return "Choose Club" }
        return "Edit \(selectedClub.viewTitle)"
    }
    var isAcceptDissabled: Bool {
        selectedClub == nil
    }
    
    init(){}
      
    func updateClubWith(title: String, uiimage: UIImage?,contacts: String ,urlString: String, location: LocalLocation?){
        if let selectedClub{
               
            Task{
                DataManager.shared.updateClubWith(id: selectedClub.viewId,
                                                  title: title,
                                                  uiimage: uiimage,
                                                  contacts: contacts,
                                                  urlString: urlString,
                                                  location: location,
                                                  inContext: .main)
                DataManager.shared.saveContext(type: .main, publish: .clubs, id: [])
                guard let uiimage else { return }
                await NetworkManager.shared.saveImageToGlobalStorage(id: selectedClub.imageLogo?.viewId ?? UUID().uuidString, uiimage: uiimage, type: .club)
            }
        }
        withAnimation{
            isEditState = false
        }
    }
    func editWithNewClub(){
        Task{
            selectedClub = DataManager.shared.fetchOrCreateClubWithId(UUID().uuidString,inContext: .main)
//            await MainActor.run {   
                withAnimation{
                    isEditState = true
                }
//            }
        }
    }
    func removeSelectedClub(){
        guard let selectedClub else { return }
       
        withAnimation{
            self.selectedClub = nil
            isEditState = false
        }
        Task{
            DataManager.shared.removeLocalClub(localClub: selectedClub, inContext: .main)
            DataManager.shared.saveContext(type: .main,
                                           publish: .clubs,
                                           id: [])
        }
        
    }
}
