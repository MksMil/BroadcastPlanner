import SwiftUI
import UIKit
import CoreData

@MainActor
final class ClubSheetViewModel: ObservableObject{
    @Published var isEditState: Bool = false
    @Published var selectedClub: LocalClub?
    
    @Published var images: [(LocalClub,Image)] = []
    var selectedImage: Image = Image(systemName: "xmark")
    init(){
        fetchImages()
    }
    
//    @MainActor
    func fetchImages() {
        Task{
            images = ( DataManager.shared.fetchAllLocalClubs(inContext: .main).map({ club in
                (club,club.imageLogo?.smallImage ?? Image(systemName: "xmark"))
            })
            )
        }
    }
//    @MainActor
    func updateClubWith(title: String, uiimage: UIImage?,contacts: String ,urlString: String, location: LocalLocation?){
        if let selectedClub{
                if let uiimage {
                    images.append((selectedClub,Image(uiImage: uiimage)))
                } else {
                    images.append((selectedClub,Image(systemName: "xmark")))
                }
            Task{
                DataManager.shared.updateClubWith(id: selectedClub.viewId,
                                                  title: title,
                                                  uiimage: uiimage,
                                                  contacts: contacts,
                                                  urlString: urlString,
                                                  location: location,
                                                  inContext: .main)
                DataManager.shared.saveContext(type: .main, publish: .clubs, id: [])
                // TODO: Network upload club + image
                guard let uiimage else { return }
                await NetworkManager.shared.saveImageToGlobalStorage(id: selectedClub.imageLogo?.viewId ?? UUID().uuidString, uiimage: uiimage, type: .club)
            }
        }
        withAnimation{
//            self.selectedClub = nil
            isEditState = false
        }
    }
//    @MainActor
    func editWithNewClub(){
        
        Task{
            selectedClub = DataManager.shared.fetchOrCreateClubWithId(UUID().uuidString,inContext: .main)
        withAnimation{
            print("\(selectedClub == nil)")
            isEditState = true
        }
        }
    }
//    @MainActor
    func removeSelectedClub(){
        guard let selectedClub else { return }
        images.removeAll { (localClub, _) in
            selectedClub == localClub
        }
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
