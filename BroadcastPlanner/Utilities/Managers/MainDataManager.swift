import CoreData
import Combine
import UIKit

class MainDataManager: ObservableObject {

    let localDataManager: DataManager
    let globalDataManager: NetworkManager

    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
    var cancellables: Set<AnyCancellable> = []
    let currentId: String
    let currentUser: LocalUser

    init(
        localDataManager: DataManager,
        globalDataManager: NetworkManager,
        userId: String
    ) {
        self.localDataManager = localDataManager
        self.globalDataManager = globalDataManager
        self.currentId = userId
        self.currentUser = localDataManager.fetchOrCreateObject(
            ofType: LocalUser.self,
            predicate: NSPredicate(format: "id == %@", userId),
            in: localDataManager.mainContext
        ) { ctx in
            let newUser = LocalUser(context: ctx)
            newUser.id = userId
            return newUser
        }
        self.globalDataManager.syncDelegate = self
        Task{
            await self.globalDataManager.start()
        }
        self.localDataManager.updatePublisher.sink { value in
            self.updatePublisher.send(value)
        }
        .store(in: &cancellables)
    }
}
//bg work
extension MainDataManager: @preconcurrency UpdateDelegateProtocol {
    func updateObvans(dtos: [ObvanDTO]) {
        print("obvans updated: \(dtos)")
        //fetch all entity data
        localDataManager.backgroundContext.performAndWait {
            let request = Obvan.fetchRequest()
            do{
                let obvans = try localDataManager.backgroundContext.fetch(request)
                for obvan in obvans{
                    if dtos.contains (where: { dto in
                        obvan.viewId == dto.id
                    }){} else {
                        localDataManager.removeObvan(obvan, inContext: .bg)
                    }
                }
                for dto in dtos {
                    if obvans.contains(where: { obvan in
                        if obvan.viewId == dto.id {
                            if obvan.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                localDataManager.updateLocalObvan(obvan,
                                                                  withObvan: dto, inContext: .bg)
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        _ = localDataManager.createOrUpdateLocalObvanWithDTO(dto, inContext: .bg)
                    }
                }
                localDataManager.saveContextSync(type: .bg, publish: .obvans, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateObvans error: \(error)")
            }
        }
        //compare id's and lastUdate
        //create / update / continue
    }
    
    func updateEvents(dtos: [EventDTO]) {
        print("events updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Event.fetchRequest()
            do{
                let events = try localDataManager.backgroundContext.fetch(request)
                for event in events{
                    if dtos.contains (where: { dto in
                        event.viewId == dto.id
                    }){} else {
                        localDataManager.removeLocalEvent(event, inContext: .bg)
                    }
                }
                for dto in dtos {
                    if events.contains(where: { event in
                        if event.viewId == dto.id {
                            if event.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                localDataManager.updateLocalEvent(event, withDTO: dto, inContext: .bg)
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        _ = localDataManager.createOrUpdateLocalEventWithEventDTO(dto, inContext: .bg)
                    }
                }
                localDataManager.saveContextSync(type: .bg, publish: .events, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateEvents error: \(error)")
            }
        }
    }
    
    func updateClubs(dtos: [ClubDTO]) {
        print("clubs updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Club.fetchRequest()
            do{
                let clubs = try localDataManager.backgroundContext.fetch(request)
                for club in clubs{
                    if dtos.contains (where: { dto in
                        club.viewId == dto.id
                    }){} else {
                        localDataManager.removeLocalClub(localClub: club, inContext: .bg)
                    }
                }
                for dto in dtos {
                    if clubs.contains(where: { club in
                        if club.viewId == dto.id {
                            if club.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                localDataManager.updateLocalClub(club, withDTO: dto, inContext: .bg)
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        _ = localDataManager.createOrUpdateLocalClubWithDTO(dto, inContext: .bg)
                    }
                }
                localDataManager.saveContextSync(type: .bg, publish: .clubs, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateClubs error: \(error)")
            }
        }
    }
    
    func updateLocations(dtos: [LocationDTO]) {
        print("locations updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Location.fetchRequest()
            do{
                let locations = try localDataManager.backgroundContext.fetch(request)
                for location in locations{
                    if dtos.contains (where: { dto in
                        location.viewId == dto.id
                    }){} else {
                        localDataManager.removeLocalLocation(location, inContext: .bg)
                    }
                }
                for dto in dtos {
                    if locations.contains(where: { location in
                        if location.viewId == dto.id {
                            if location.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                localDataManager.updateLocalLocation(location, withDTO: dto, inContext: .bg)
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        _ = localDataManager.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .bg)
                    }
                }
                localDataManager.saveContextSync(type: .bg, publish: .locations, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateLocations error: \(error)")
            }
        }
    }
    
    func updateTemplates(dtos: [TemplateDTO]) {
        print("templates updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Template.fetchRequest()
            do{
                let templates = try localDataManager.backgroundContext.fetch(request)
                for template in templates{
                    if dtos.contains (where: { dto in
                        template.viewId == dto.id
                    }){} else {
                        localDataManager.removeLocalTemplate(template, inContext: .bg)
                    }
                }
                for dto in dtos {
                    if templates.contains(where: { template in
                        if template.viewId == dto.id {
                            if template.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                localDataManager.updateLocalTemplate(template, withTemplateDTO: dto, inConext: .bg)
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        _ = localDataManager.createOrUpdateLocalTemplateWithTemplateDTO(dto, inConext: .bg)
                    }
                }
                localDataManager.saveContextSync(type: .bg, publish: .templates, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateTemplates error: \(error)")
            }
        }
    }
    
    func updateImages(dtos: [ImageDTO]) {
        print("images updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = LocalImage.fetchRequest()
            do{
                let images = try localDataManager.backgroundContext.fetch(request)
                for image in images{
                    if dtos.contains (where: { dto in
                        image.viewId == dto.id
                    }){} else {
                        localDataManager.removeLocalImage(image, inContext: .bg)
                    }
                }
                for dto in dtos {
                    if images.contains(where: { image in
                        if image.viewId == dto.id {
                            if image.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                globalDataManager.loadImageFromGlobalStorage(id: dto.id) { uiimage in
                                    _ = self.localDataManager.createOrUpdateLocalImageWithImageData(imageDTO: dto, withImage: uiimage, inContext: .bg)
                                }
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        globalDataManager.loadImageFromGlobalStorage(id: dto.id) { uiimage in
                            _ = self.localDataManager.createOrUpdateLocalImageWithImageData(imageDTO: dto, withImage: uiimage, inContext: .bg)
                        }
                    }
                }
                localDataManager.saveContextSync(type: .bg, publish: .images, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateImages error: \(error)")
            }
        }
    }
    
    func updateUsers(dtos: [UserDTO]) {
        print("users updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = LocalUser.fetchRequest()
            do{
                let users = try self.localDataManager.backgroundContext.fetch(request)
                
                for user in users{
                    if dtos.contains (where: { dto in
                        user.viewId == dto.id
                    }){} else {
                        localDataManager.removeLocalUser(user, inContext: .bg)
                    }
                }
                
                for dto in dtos {
                    if users.contains(where: { user in
                        if user.viewId == dto.id {
                            if user.viewLastUpdated == dto.lastUpdated{
                                //id, lastUpdate ==
                                return true
                            } else {
                                // id ==, lastUpdate !=
                                self.localDataManager.updateLocalUser(user, withUserDTO: dto, inContext: .bg)
                                return true
                            }
                        }
                        return false
                    }){
                        
                    } else {
                        //entity with dto.id doesn't exist
                        _ = self.localDataManager.createOrUpdateLocalUserWithUserDTO(dto, inContext: .bg)
                    }
                }
                self.localDataManager.saveContextSync(type: .bg, publish: .users, id: dtos.map{$0.id})
            } catch {
                print("MDM: updateUsers error: \(error)")
            }
        }
    }
    @MainActor
    func handleListenerEvent<T: BPDataProtocol>(updated: Bool, value: T){
        localDataManager.backgroundContext.performAndWait {
            var type: GlobalProperties.PublishChanges = .none
            var publishId: String = ""
            switch value {
                case is UserDTO:
                    print("isLocalUser")
                    if let dto = value as? UserDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalUserWithUserDTO(dto, inContext: .bg)
                        } else {
                            localDataManager.removeUserWithDTO(dto, inContext: .bg)
                        }
                        type = .users
                        publishId = dto.id
                    }
                case is EventDTO:
                    print("isEvent")
                    if let dto = value as? EventDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalEventWithEventDTO(dto, inContext: .bg)
                        } else {
                            print("procees with event listener")
                            localDataManager.removeEventWithDTO(dto, inContext: .bg)
                        }
                        type = .events
                        publishId = dto.id
                    }
                case is ClubDTO:
                    print("isClub")
                    if let dto = value as? ClubDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalClubWithDTO(dto, inContext: .bg)
                        } else {
                            localDataManager.removeClubWithDTO(dto, inContext: .bg)
                        }
                        type = .clubs
                        publishId = dto.id
                    }
                case is LocationDTO:
                    print("isLocation")
                    if let dto = value as? LocationDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .bg)
                        } else {
                            localDataManager.removeLocationWithDTO(dto, inContext: .bg)
                        }
                        type = .locations
                        publishId = dto.id
                    }
                case is ObvanDTO:
                    print("isObvan")
                    if let dto = value as? ObvanDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalObvanWithDTO(dto, inContext: .bg)
                        } else {
                            localDataManager.removeObvanWithId(dto.id, inContext: .bg)
                        }
                        type = .obvans
                        publishId = dto.id
                    }
                case is TemplateDTO:
                    print("isTemplate")
                    if let dto = value as? TemplateDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalTemplateWithTemplateDTO(dto, inConext: .bg)
                        } else {
                            localDataManager.removeTemplateWithDTO(dto, inContext: .bg)
                        }
                        type = .templates
                        publishId = dto.id
                    }
                case is ImageDTO:
                    print("isImage")
                    if let dto = value as? ImageDTO{
                        if updated {
                            globalDataManager.loadImageFromGlobalStorage(id: dto.id) { uiimage in
                                _ = self.localDataManager.createOrUpdateLocalImageWithImageData(imageDTO: dto, withImage: uiimage, inContext: .bg)
                            }
                            
                        } else {
                            localDataManager.removeImageWithId(dto.id, inContext: .bg)
                        }
                        type = .images
                        publishId = dto.id
                    }
                default: print("unexpected update type")
            }
            localDataManager.saveContextSync(type: .bg, publish: type, id: [publishId])
        }
    }
}

// MARK: - User managment
extension MainDataManager {
    //creates new user cloud entity
    @MainActor
    func createUser(id: String) async {
        let userDTO = UserDTO(id: id)
        await globalDataManager.saveData(
            userDTO,
            withId: id,
            withType: GlobalProperties.Path.users
        )
    }
    @MainActor
    func updateUserData(
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        address: String,
        userSpecialization: [String],
        inputImage: UIImage?
    ) async {
        await localDataManager.mainContext.perform { [weak self] in
            guard let self else { return }
            currentUser.firstName = firstName
            currentUser.lastName = lastName
            currentUser.email = email
            currentUser.phoneNumber = phoneNumber
            currentUser.homeAddress = address
            currentUser.specializations = userSpecialization.joined(
                separator: ","
            )
            if let image = inputImage {
                if let localImage = currentUser.image {
                    localImage.uploadImage(uiimage: image)
                    currentUser.image = localImage
                    localImage.parentUser = currentUser
                } else {
                    let localImage = localDataManager.fetchOrCreateObject(
                        ofType: LocalImage.self,
                        predicate: NSPredicate(format: "id == %@", currentId),
                        in: localDataManager.mainContext
                    ) { ctx in
                        let newImage = LocalImage(context: ctx)
                        newImage.id = self.currentId
                        return newImage
                    }
                    localImage.uploadImage(uiimage: image)
                    currentUser.image = localImage
                    localImage.parentUser = currentUser
                }
            }
        }
        await saveContextAsync(
            type: .main,
            publish: .none,
            id: []
        )

        if let inputImage {
            await globalDataManager.saveImageToGlobalStorage(
                id: currentId,
                uiimage: inputImage,
                type: GlobalProperties.ImageType.user
            )
        }
        await globalDataManager
            .saveData(
                currentUser.dto,
                withId: currentId,
                withType: GlobalProperties.Path.users
            )
    }
    func removeCurrrentUser() {
        //remove user and user image in global

        // remove user and user image in local
    }

    func removeUser(user: UserDTO) {
        // remove user and user image in local
    }

    @MainActor
    func fetchUsersAvailableForEvent(_ event: Event) -> [LocalUser] {
        localDataManager.fetchUsersAvailableToEvent(event)
    }
}
// MARK: - Event managment
extension MainDataManager {
    
    func availabletoEdit(event: Event)->Bool {
        if currentUser.accessLevel == 0 {
            return false
        } else if currentUser.accessLevel == 1, event.viewOwners.contains(currentUser){
            return false
        } else {
            return true
        }
    }
    
    @MainActor
    func createEventWithCurrentUserOwnerInContextType(_ type: ContextType)
        -> Event {
        let event = localDataManager.fetchOrCreateObject(
            ofType: Event.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newEvent = Event(context: ctx)
            newEvent.id = UUID().uuidString
            return newEvent
        }
        //link event to user
        localDataManager.contextFromType(type).perform { [weak self] in
            guard let self else { return }
            event.addToOwners(self.currentUser)
            currentUser.addToOwnedEvents(event)
        }
            saveContextSync(type: .main, publish: GlobalProperties.PublishChanges.events, id: [])
        return event
    }
    @MainActor
    func updateEvent(
        _ event: Event,
        homeClub: Club?,
        guestClub: Club?,
        eventDate: Date,
        location: Location?) async {
        //coreData save
        await localDataManager.mainContext.perform { [weak self] in
            guard let self else { return }
            event.homeClub = homeClub
            event.guestClub = guestClub
            event.date = eventDate
            event.location = location
            event.addToOwners(self.currentUser)
        }
        await saveContextAsync(type: .main, publish: .events, id: [event.viewId])

        //network save
        await globalDataManager.saveData(
            event.dto,
            withId: event.viewId,
            withType: GlobalProperties.Path.events
        )
    }
    @MainActor
    func removeEvent(event: Event) async {
        let id = event.viewId
        localDataManager.removeLocalEvent(event, inContext: .main)
        await saveContextAsync(type: .main, publish: .events, id: [])
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.events,
            withId: id
        )
    }
    @MainActor
    func assignSnapshot(_ image: UIImage?,
        toEvent event: Event) async {
        if let image {
            let localImage =
                 localDataManager.createOrUpdateLocalImageWithImageData(
                    imageDTO: .init(
                        id: UUID().uuidString,
                        type: GlobalProperties.ImageType.locationPreview
                            .rawValue,
                        lastUpdated: .now
                    ),
                    withImage: image,
                    inContext: .main
                )
            localDataManager.mainContext.performAndWait {
                event.locationPreview = localImage
                localImage.parentLocationPreviewEvent = event
            }
        }
    }
}
// MARK: - Points managment
extension MainDataManager {
    @MainActor
    func updateEvent(
        _ event: Event,
        withPoints points: [LocationPoint]
    ) {
        localDataManager.mainContext.performAndWait {
            event.points = Set(points) as NSSet
        }
    }

    @MainActor
    func updatePoint(
        _ point: LocationPoint,
        x: Double,
        y: Double,
        rotation: Int,
        scaleFactor: Double
    ) {
        localDataManager.updateLocalPoint(
            point,
            withX: x,
            y: y,
            rotation: rotation,
            scaleFactor: scaleFactor,
            inContext: .main
        )
    }
    @MainActor
    func updatePoint(
        _ point: LocationPoint?,
        withNumber num: Int
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.number = Int16(num)
        }
    }
    @MainActor
    func updatePoint(
        _ point: LocationPoint?,
        withDescription desk: String
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.pointDescription = desk
        }
    }

    @MainActor
    func updatePoint(
        _ point: LocationPoint?,
        withCamera camera: Camera
    ) async {
        guard let point else { return }

        localDataManager.mainContext.performAndWait {
            point.addToCameras(camera)
            print("camera adding complete")
        }
    }
    @MainActor
    func removeCamera(
        _ camera: Camera,
        fromPoint point: LocationPoint?
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.removeFromCameras(camera)
        }
        localDataManager.removeLocalCamera(camera, inContext: .main)
    }
    @MainActor
    func updatePoint(
        _ point: LocationPoint?,
        withSound sound: Sound
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.addToSounds(sound)
        }
    }
    @MainActor
    func removeSound(
        _ sound: Sound,
        fromPoint point: LocationPoint?
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.removeFromSounds(sound)
        }
        localDataManager.removeLocalSound(sound, inContext: .main)
    }
    @MainActor
    func updatePoint(
        _ point: LocationPoint?,
        withLight light: Light
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.addToLights(light)
        }
    }
    @MainActor
    func removeLight(
        _ light: Light,
        fromPoint point: LocationPoint?
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.removeFromLights(light)
        }
        localDataManager.removeLocalLight(light, inContext: .main)
    }
    @MainActor
    func addUser(
        _ user: LocalUser,
        toPoint point: LocationPoint?
    ) async {
        if let point {
            localDataManager.mainContext.performAndWait {
                point.addToUser(user)
                user.addToPoints(point)
                if let event = point.event {
                    user.addToParticipateEvents(event)
                    event.addToUsers(user)
                } else {
                    print("event in point error occured")
                }
            }
        }
    }
    @MainActor
    func removeUser(
        _ user: LocalUser,
        fromPoint point: LocationPoint?
    ) async {
        if let point {
            localDataManager.mainContext.performAndWait {
                point.removeFromUser(user)
                user.removeFromPoints(point)
                if let event = point.event {
                    event.removeFromUsers(user)
                    user.removeFromParticipateEvents(event)
                } else {
                    print("event in point error occured")
                }
            }
        }
    }

    @MainActor
    func newPointInEvent(
        _ event: Event,
        withNumber number: Int
    ) -> LocationPoint {
        let newPoint = localDataManager.fetchOrCreateObject(
            ofType: LocationPoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newLocationPoint = LocationPoint(context: ctx)
            newLocationPoint.id = UUID().uuidString
            return newLocationPoint
        }
        localDataManager.mainContext.perform {
            newPoint.number = Int16(number)
            event.addToPoints(newPoint)
        }
        return newPoint
    }
    @MainActor
    func deletePoint(
        _ point: LocationPoint,
        inEvent event: Event
    ) {
        localDataManager.removeLocalLocationPoint(point, inContext: .main)
    }
}
// MARK: - Unit managment
extension MainDataManager {
    @MainActor
    func removeUnit(_ unit: Unit) {
        localDataManager.mainContext.perform {
            if let event = unit.event, let user = unit.user {
                user.removeFromParticipateEvents(event)
                event.removeFromUsers(user)
            }
        }
        localDataManager.removeLocalUnit(unit, inContext: .main)
    }
    func createUnitWithUser(
        _ user: LocalUser,
        andSpecialization specialization: UserSpecialization,
        andHardware hardware: ReplayType?,
        inEvent event: Event
    ) -> Unit {
        let unit = localDataManager.createUnitWithUser(
            user,
            andPosition: specialization,
            andHardware: hardware,
            inContext: .main
        )
        localDataManager.mainContext.perform {
            event.addToUnits(unit)
            event.addToUsers(user)
            user.addToParticipateEvents(event)
            user.addToUnits(unit)
            unit.user = user
            unit.event = event
        }
        return unit
    }

}
// MARK: - Club managment
extension MainDataManager {
    @MainActor
    func createClub() -> Club {
        let id = UUID().uuidString
        return localDataManager.fetchOrCreateObject(
            ofType: Club.self,
            predicate: NSPredicate(format: "id == %@", id),
            in: localDataManager.mainContext
        ) { ctx in
            let newClub = Club(context: ctx)
            newClub.id = id
            return newClub
        }
    }

    @MainActor
    func updateClub(_ club: Club,
                    withTitle: String,
                    uiimage: UIImage?,
                    contacts: String,
                    urlString: String,
                    location: Location?,
                    inContext contextType: ContextType) async {
        //save image logo in local storage,

         localDataManager.updateClubWithClub(
            club: club,
            title: withTitle,
            uiimage: uiimage,
            contacts: contacts,
            urlString: urlString,
            location: location,
            inContext: .main
        )
        await saveContextAsync(type: .main, publish: .clubs, id: [club.viewId])

        //upload image to firestore and image properties and clubDTO to firebase
        if let imageId = club.imageLogo?.viewId, let uiimage {
            await self.globalDataManager.saveImageToGlobalStorage(
                id: imageId,
                uiimage: uiimage,
                type: GlobalProperties.ImageType.club
            )
        }
        await self.globalDataManager.saveData(
            club.dto,
            withId: club.viewId,
            withType: GlobalProperties.Path.clubs
        )
    }
    @MainActor
    func removeCub(_ club: Club) async {
        //remove image from firestore, and image properties and club from firebase
        let id = club.viewId
        if let imageId = club.imageLogo?.id {
            await self.globalDataManager.removeImage(localImageId: imageId)
        }
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.clubs,
            withId: id
        )
        //remove club from coredata and image logo from local storage
        localDataManager.removeLocalClub(localClub: club, inContext: .main)
        await saveContextAsync(type: .main, publish: .clubs, id: [])
    }
}
// MARK: - LocationManagment
extension MainDataManager {
    @MainActor
    func getNewLocation() -> Location {
        localDataManager.fetchOrCreateObject(
            ofType: Location.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newLocation = Location(context: ctx)
            newLocation.id = UUID().uuidString
            return newLocation
        }
    }
    @MainActor
    func updateLocalLocation(
        _ location: Location,
        withTitle title: String,
        address: String,
        images: [UIImage],
        background: LocalImage?
    ) async {
        //update coredata entity
            localDataManager.updateLocalLocation(
            location,
            withTitle: title,
            address: address,
            localImages: images,
            locationBackground: background,
            inContext: .main
        )
        await localDataManager.saveContextAsync(
            type: .main,
            publish: .locations,
            id: []
        )
        // location image upload to firestore, and image properties in firebase
        let images = location.viewLocalImages
        if !images.isEmpty {
            await withTaskGroup { group in
                images.forEach { image in
                    if let uiimage = image.makeUIImage() {
                        group.addTask { [weak self] in
                            guard let self else { return }
                            await globalDataManager.saveImageToGlobalStorage(
                                id: image.viewId,
                                uiimage: uiimage,
                                type: GlobalProperties.ImageType.location
                            )
                        }
                    }
                }
            }
            //            group.addTask { [weak self] in
            //                //background?
            //            }

        }
        await globalDataManager.saveData(
            location.dto,
            withId: location.viewId,
            withType: GlobalProperties.Path.locations
        )
    }
    @MainActor
    func removeLocation(_ location: Location) async {
        //remove background images for location from firestore, and image properties from firebase
        await withTaskGroup { group in
            let imageIds = location.viewLocalImages.map { $0.viewId }
            if !imageIds.isEmpty {
                imageIds.forEach { id in
                    group.addTask { [weak self] in
                        guard let self else { return }
                        await self.globalDataManager.removeImage(
                            localImageId: id
                        )
                    }
                }
            }
        }
        //remove location from firebase
        await globalDataManager.removeDataOfType(
            .locations,
            withId: location.viewId
        )
        //remove images and location from CoreData
         localDataManager.removeLocalLocation(location, inContext: .main)
        await saveContextAsync(type: .main, publish: .locations, id: [])
    }
}
// MARK: - Template managment
extension MainDataManager {
    @MainActor
    func makeLocalPointFromTemplate(_ template: Template)
        -> [LocationPoint]
    {
        return localDataManager.mapTemplateToLocationPoints(
            template: template,
            inContext: .main
        )
    }

    @MainActor
    func saveTemplateFromSchema(
        localPoints: [LocationPoint],
        withName name: String
    ) async {
        let template =
             localDataManager.createTemplateWithLocalLocationPoints(
                localPoints,
                andName: name,
                inContext: .main
            )
        await saveContextAsync(type: .main, publish: .templates, id: [])

        await globalDataManager.saveData(
            template.dto,
            withId: template.viewId,
            withType: .templates
        )
    }

    func removeLocalTemplate(_ template: Template) async {
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.templates,
            withId: template.viewId
        )
        localDataManager.removeLocalTemplate(template, inContext: .main)
        await saveContextAsync(type: .main, publish: .templates, id: [])
    }
}
// MARK: - Obvan managment
extension MainDataManager {
    func createObvanWithName(
        _ name: String,
        broadcaster: String,
        image: UIImage?
    ) -> Obvan {
        localDataManager.fetchOrCreateObject(
            ofType: Obvan.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newObvan = Obvan(context: ctx)
            newObvan.id = UUID().uuidString
            return newObvan
        }

    }

    func updateObvan(_ localObvan: Obvan) async {
        //update local

        //update global
        await globalDataManager.saveData(
            localObvan.dto,
            withId: localObvan.viewId,
            withType: GlobalProperties.Path.obvans
        )
    }

    func removeObvan(_ obvan: Obvan) async {
        //remove from global
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.obvans,
            withId: obvan.viewId
        )

        //remove from local
    }

}

// MARK: - Image managment
extension MainDataManager {
    @MainActor
    func createNewLocalImageWith(uiimage: UIImage) {
        let _ =
            localDataManager
            .createOrUpdateLocalImageWithId(
                UUID().uuidString,
                withImage: uiimage,
                andType: GlobalProperties.ImageType.eventTemplate,
                inContext: .main
            )
        Task {
            await saveContextAsync(
                type: .main,
                publish: .none,
                id: []
            )
        }
    }
    @MainActor
    func removeImage(selectedImage: LocalImage?) {
        if let localImageToRemove = selectedImage {
            localDataManager.removeLocalImage(
                localImageToRemove,
                inContext: .main
            )
            Task {
                await saveContextAsync(type: .main, publish: .none, id: [])
            }
        }
    }
}
// MARK: - Online status managment
extension MainDataManager {
    func changeOnlineStatus(isOnline: Bool) async {
        if isOnline {
            await globalDataManager.goOnline(id: currentId)
        } else {
            await globalDataManager.goOffline(id: currentId)
        }
    }
}

// MARK: - CoreDate Context
extension MainDataManager {
    @MainActor
    func rollBackMoc() {
        localDataManager.mainContext.rollback()
    }

    func saveContextAsync(
        type: ContextType,
        publish: GlobalProperties.PublishChanges,
        id: [String]
    ) async {
        await localDataManager.saveContextAsync(type: type, publish: publish, id: id)
    }
    
    func saveContextSync(
        type: ContextType,
        publish: GlobalProperties.PublishChanges,
        id: [String]
    )  {
        localDataManager.saveContextSync(type: type, publish: publish, id: id)
    }
}
