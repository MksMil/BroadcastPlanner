import UIKit
import CoreData

class MainDataManager: ObservableObject {
    
    let localDataManager: DataManager
    let globalDataManager: NetworkManager
    
    let currentId: String
    let currentUser: LocalUser
    
    init(localDataManager: DataManager,
         globalDataManager: NetworkManager,
         userId: String) {
        self.localDataManager = localDataManager
        self.globalDataManager = globalDataManager
        self.currentId = userId
        self.currentUser = localDataManager.fetchOrCreateUserWithId(userId, inContext: .main)
    }
    //creates new user cloud entity
    @MainActor
    func createUser(id: String) async {
        await globalDataManager.createUser(id: id)
    }
    @MainActor
    func rollBackMoc(){
        localDataManager.moc.rollback()
    }
}

// MARK: - User Managment
extension MainDataManager{
    @MainActor
    func updateUserData(firstName: String,
                        lastName: String,
                        email: String,
                        phoneNumber: String,
                        address: String,
                        userSpecialization:[String],
    inputImage: UIImage?){
             localDataManager.moc.performAndWait {
                currentUser.firstName = firstName
                currentUser.lastName = lastName
                currentUser.email = email
                currentUser.phoneNumber = phoneNumber
                currentUser.homeAddress = address
                currentUser.specializations = userSpecialization.joined(separator: ",")
                if let image = inputImage{
                    if let localImage = currentUser.image{
                        localImage.uploadImage(uiimage: image)
                        currentUser.image = localImage
                        localImage.parentUser = currentUser
                    } else {
                        let localImage = localDataManager.fetchOrCreateImageWithId(currentId, inContext: .main)
                        localImage.uploadImage(uiimage: image)
                        currentUser.image = localImage
                        localImage.parentUser = currentUser
                    }
                }
                
                saveContext(type: .main,
                            publish: .none,
                            id: [])
            }
            Task{
                await globalDataManager
                    .saveUser(user: BPUser.makeBPUser(localUser: currentUser),
                              image: inputImage)
            }
        }
    @MainActor
    func fetchUsersAvailableForEvent(_ event: LocalEvent) -> [LocalUser]{
        localDataManager.fetchUsersAvailableToEvent(event)
    }
}
// MARK: - Event managment
extension MainDataManager{
    @MainActor
    func createEventWithCurrentUserOwnerInContextType(_ type: ContextType) -> LocalEvent{
        let event = localDataManager.fetchOrCreateEventWithId(UUID().uuidString, inContext: type)
        //link event to user
        localDataManager.contextFromType(type).perform { [weak self] in
            guard let self else { return }
            event.addToOwners(self.currentUser)
            currentUser.addToOwnedEvents(event)
        }
        return event
    }
    @MainActor
    func updateEvent(_ event: LocalEvent, homeClub: LocalClub?,guestClub: LocalClub?, eventDate: Date, location: LocalLocation?){
        //coreData save
        localDataManager.moc.perform { [weak self] in
            guard let self else { return }
            event.homeClub = homeClub
            event.guestClub = guestClub
            event.date = eventDate
            event.location = location
            event.addToOwners(self.currentUser)
            saveContext(type: .main, publish: .events, id: [event.viewId])
        }
        
        //network save
        Task{
            await globalDataManager.saveEvent(BPEvent.mapLocalEventToEvent(localEvent: event))
        }
  }
    @MainActor
    func removeEvent(event: LocalEvent) {
        Task{
            await  globalDataManager.removeEventWithId(event.viewId)
            localDataManager.removeLocalEvent(
                event,
                inContext: .main)
//            await localDataManager.saveContext(
//                type: .main,
//                publish: .events,
//                id: [])
            saveContext(type: .main, publish: .events, id: [])
        }
    }
    
    func assignSnapshot(_ image:UIImage?, toEvent event: LocalEvent){
        if let image {
            let localImage = localDataManager.createOrUpdateLocalImageWithImageData(imageData: .init(id: UUID().uuidString, type: GlobalProperties.ImageType.locationPreview.rawValue), withImage: image, inContext: .main)
            localDataManager.moc.performAndWait {
                event.locationPreview = localImage
                localImage.parentLocationPreviewEvent = event
            }
        }
    }
}

// MARK: - LocalLocaltionPoints
extension MainDataManager{
    @MainActor
    func updateEvent(_ event: LocalEvent,withPoints points: [LocalLocationPoint]){
        localDataManager.moc.performAndWait {
            event.locationPoints = Set(points) as NSSet
        }
        
    }
    @MainActor
    func updatePoint(_ point: LocalLocationPoint, x: Double, y: Double, rotation: Int, scaleFactor: Double){
        localDataManager.updateLocalPoint(point,
                                          withX: x,
                                          y: y,
                                          rotation: rotation,
                                          scaleFactor: scaleFactor,
                                          inContext: .main)
    }
    @MainActor
    func updatePoint(_ point: LocalLocationPoint?,withNumber num: Int) async {
        guard let point else { return }
            localDataManager.moc.performAndWait {
                point.number = Int16(num)
            }
    }
    @MainActor
    func updatePoint(_ point: LocalLocationPoint?,withDescription desk: String) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.pointDescription = desk
        }
    }
    
    @MainActor
    func updatePoint(_ point: LocalLocationPoint?, withCamera camera: LocalCamera) async {
        guard let point else { return }
        
        localDataManager.moc.performAndWait {
            point.addToCameras(camera)
            print("camera adding complete")
        }
    }
    @MainActor
    func removeCamera(_ camera: LocalCamera, fromPoint point: LocalLocationPoint?) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.removeFromCameras(camera)
        }
        localDataManager.removeLocalCamera(camera, inContext: .main)
    }
    @MainActor
    func updatePoint(_ point: LocalLocationPoint?, withSound sound: LocalSound) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.addToSounds(sound)
        }
    }
    @MainActor
    func removeSound(_ sound: LocalSound, fromPoint point: LocalLocationPoint?) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.removeFromSounds(sound)
        }
        localDataManager.removeLocalSound(sound, inContext: .main)
    }
    @MainActor
    func updatePoint(_ point: LocalLocationPoint?, withLight light: LocalLight) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.addToLights(light)
        }
    }
    @MainActor
    func removeLight(_ light: LocalLight, fromPoint point: LocalLocationPoint?) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.removeFromLights(light)
        }
        localDataManager.removeLocalLight(light, inContext: .main)
    }
    @MainActor
    func addUser(_ user: LocalUser, toPoint point: LocalLocationPoint?)async{
        if let point {
            localDataManager.moc.performAndWait {
                point.addToUser(user)
                user.addToLocationPoints(point)
                if let event = point.event{
                    user.addToParticipateEvents(event)
                    event.addToUsers(user)
                } else {
                    print("event in point error occured")
                }
            }
        }
    }
    @MainActor
    func removeUser(_ user: LocalUser, fromPoint point:  LocalLocationPoint?) async {
        if let point {
            localDataManager.moc.performAndWait {
                point.removeFromUser(user)
                user.removeFromLocationPoints(point)
                if let event = point.event{
                    event.removeFromUsers(user)
                    user.removeFromParticipateEvents(event)
                } else {
                    print("event in point error occured")
                }
            }
        }
    }
    
    
    @MainActor
    func newPointInEvent(_ event: LocalEvent, withNumber number: Int)->LocalLocationPoint{
        let newPoint = localDataManager.fetchOrCreateLocationPointWithId(UUID().uuidString, inContext: .main)
        localDataManager.moc.perform {
            newPoint.number = Int16(number)
            event.addToLocationPoints(newPoint)
        }
        return newPoint
    }
    @MainActor
    func deletePoint(_ point: LocalLocationPoint,inEvent event: LocalEvent){
        localDataManager.removeLocalLocationPoint(point, inContext: .main)
    }
}
// MARK: - ObvanUnit managment
extension MainDataManager{
    @MainActor
    func removeObvanUnit(_ unit: LocalObvanUnit){
        localDataManager.moc.perform {
            if let event = unit.event, let user = unit.user{
                user.removeFromParticipateEvents(event)
                event.removeFromUsers(user)
            }
        }
        localDataManager.removeLocalObvanUnit(unit, inContext: .main)
    }
    func createNewObvanUnitWithUser(_ user: LocalUser,
                                    andSpecialization specialization: UserSpecialization,
                                    andHardware hardware: Hardware.ReplayType?, inEvent event: LocalEvent) -> LocalObvanUnit{
        
    let unit = localDataManager.createOrUpdateLocalObvanUnitWithUser(user, andPosition: specialization.rawValue, andHardware: hardware, inContext: .main)
        localDataManager.moc.perform {
            event.addToObVanUnits(unit)
            event.addToUsers(user)
            user.addToParticipateEvents(event)
            user.addToObVanUnits(unit)
            unit.user = user
            unit.event = event
        }
        return unit
    }

}

// MARK: - Club managment
extension MainDataManager{
    @MainActor
    func getNewClub() -> LocalClub{
        localDataManager.fetchOrCreateClubWithId(UUID().uuidString, inContext: .main)
    }
    @MainActor
    func updateClubWithClub(club: LocalClub, title: String, uiimage: UIImage?, contacts: String,
                            urlString: String, location: LocalLocation?,
                            inContext contextType: ContextType) async {
        await localDataManager.updateClubWithClub(club: club, title: title, uiimage: uiimage, contacts: contacts, urlString: urlString, location: location, inContext: .main)
        await globalDataManager.saveClub(Club.mapToClub(localClub: club))
    }
    @MainActor
    func removeCub(_ club: LocalClub) async {
        await globalDataManager.removeClub(clubId: club.viewId,
                                           logoId: club.imageLogo?.viewId ?? "")
        localDataManager.removeLocalClub(localClub: club, inContext: .main)
        await localDataManager.saveContext(type: .main, publish: .clubs, id: [])
    }
}

// MARK: - LocationManagment
extension MainDataManager{
    @MainActor
    func getNewLocation() -> LocalLocation{
        localDataManager.fetchOrCreateLocationWithId(UUID().uuidString, inContext: .main)
    }
    @MainActor
    func updateLocalLocation(_ location: LocalLocation, withTitle title: String, address: String, images: [UIImage], background: LocalImage?)async{
        await localDataManager.updateLocalLocation(location, withTitle: title, address: address, localImages: images, locationBackground: background)
        await localDataManager.saveContext(type: .main, publish: .locations, id: [])
        await globalDataManager.saveLocation(location.mapToLocation())
    }
    @MainActor
    func removeLocation(_ location: LocalLocation) {
        globalDataManager.removeLocation(location.viewId,
                                         imagesIds: location.viewLocalImages.map{$0.viewId}, backgroundId: location.background?.viewId ?? "")
            localDataManager.removeLocalLocation(location, inContext: .main)
            saveContext(type: .main,
                        publish: .none,
                        id: [])
    }
}


// MARK: - Image
extension MainDataManager {
    @MainActor
    func createNewLocalImageWith(uiimage: UIImage){
        let _ = localDataManager
            .createOrUpdateLocalImageWithId(UUID().uuidString,
                                            withImage: uiimage,
                                            andType: GlobalProperties.ImageType.eventTemplate,
                                            inContext: .bg)
        saveContext(type: .bg,
                    publish: .none,
                    id: [])
        
    }
    @MainActor
    func removeImage(selectedImage: LocalImage?){
        if let localImageToRemove = selectedImage{
            
            localDataManager.removeLocalImage(localImageToRemove,
                                              inContext: .main)
            saveContext(type: .main, publish: .none, id: [])
        }
    }
}


// MARK: - template crud
extension MainDataManager {
    //tempplate or Id
    @MainActor
    func makeLocalPointFromTemplate(_ template: LocalTemplate) -> [LocalLocationPoint]{
        return localDataManager.mapTemplateToLocationPoints(template: template, inContext: .main)
    }
    
    @MainActor
    func saveTemplateFromSchema(localPoints: [LocalLocationPoint], withName name: String) {
        print("save template")
        
        let _ = localDataManager.createTemplateWithLocalLocationPoints(localPoints, andName: name,inContext: .main)
//       saveContext(type: .main, publish: .templates, id: [])
    }
    
    func removeLocalTemplate(_ template: LocalTemplate){
        localDataManager.removeLocalTemplate(template, inContext: .main)
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

// MARK: - CoreDate Context
extension MainDataManager {

    func saveContext(type: ContextType, publish: GlobalProperties.PublishChanges, id:[String]){
        Task{
            await localDataManager.saveContext(type: type, publish: publish, id: id)
        }
    }
}

