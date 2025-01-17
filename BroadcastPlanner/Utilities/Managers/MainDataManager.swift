import UIKit
import CoreData



class MainDataManager: ObservableObject {
    
    let localDataManager: DataManager
    let globalDataManager: NetworkManager
    let currentUser: LocalUser
    let currentId: String
    
    init(localDataManager: DataManager,
         globalDataManager: NetworkManager,
         userId: String?) {
        self.localDataManager = localDataManager
        self.globalDataManager = globalDataManager
        if let userId {
            currentId = userId
        } else {
            currentId = UUID().uuidString
        }
        currentUser = localDataManager.fetchOrCreateUserWithId(currentId, inContext: .main)
    }
    
    //creates new user cloud entity
    func createUser(id: String) async {
        await globalDataManager.createUser(id: id)
    }
    
    func rollBackMoc(){
        localDataManager.moc.rollback()
    }
    
}

// MARK: - User Managment
extension MainDataManager{
    
    func updateUserData() async {
       
//            localUser.id = id
//            localUser.firstName = firstName
//            localUser.lastName = lastName
//            localUser.email = email
//            localUser.phoneNumber = phoneNumber
//            localUser.homeAddress = address
//            localUser.specializations = userSpecialization.joined(separator: ",")
//            
//            if let image = inputImage{
//                if let localImage = localUser.image{
//                    localImage.uploadImage(uiimage: image)
//                    localUser.image = localImage
//                    localImage.parentUser = localUser
//                } else {
//                    let localImage = DataManager.shared.fetchOrCreateImageWithId(id, inContext: .main)
//                    localImage.uploadImage(uiimage: image)
//                    localUser.image = localImage
//                    localImage.parentUser = localUser
//                }
//            }
            
//            await DataManager.shared.saveContext(type: .main,
//                                                 publish: .none,
//                                                 id: [])
//            await NetworkManager.shared
//                .saveUser(user: BPUser.makeBPUser(localUser: localUser),
//                          image: inputImage)
        }
}
// MARK: - Event managment
extension MainDataManager{
    
}


// MARK: - Club managment
extension MainDataManager{
    func getNewClub() -> LocalClub{
        localDataManager.fetchOrCreateClubWithId(UUID().uuidString, inContext: .main)
    }
    
    func updateClubWithClub(club: LocalClub, title: String, uiimage: UIImage?, contacts: String,
                            urlString: String, location: LocalLocation?,
                            inContext contextType: ContextType) async {
        await localDataManager.updateClubWithClub(club: club, title: title, uiimage: uiimage, contacts: contacts, urlString: urlString, location: location, inContext: .main)
        await globalDataManager.saveClub(Club.mapToClub(localClub: club))
    }
    
    func removeCub(_ club: LocalClub) async {
        await globalDataManager.removeClub(club: club)
        localDataManager.removeLocalClub(localClub: club, inContext: .main)
        await localDataManager.saveContext(type: .main, publish: .clubs, id: [])
    }
}

// MARK: - LocationManagment
extension MainDataManager{
    
    func getNewLocation() -> LocalLocation{
        localDataManager.fetchOrCreateLocationWithId(UUID().uuidString, inContext: .main)
    }
    
    func updateLocalLocation(_ location: LocalLocation, withTitle title: String, address: String, images: [UIImage], background: LocalImage?)async{
        
        await localDataManager.updateLocalLocation(location, withTitle: title, address: address, localImages: images, locationBackground: background)
        
        await localDataManager.saveContext(type: .main, publish: .locations, id: [])
        
        await globalDataManager.saveLocation(location.mapToLocation())
    }
    
    func removeLocation(_ location: LocalLocation) async {
        await globalDataManager.removeLocation(location)
        localDataManager.removeLocalLocation(location, inContext: .main)
        await localDataManager.saveContext(type: .main,
                                           publish: .none,
                                           id: [])
    }
}

// MARK: - Change Online status
extension MainDataManager {
    
    func changeOnlineStatus(isOnline: Bool){
        if isOnline{
            
        } else {
            
        }
    }
    
}

