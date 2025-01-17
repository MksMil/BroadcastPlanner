import CoreData
import UIKit
import Combine

enum ContextType {
    case main, bg
}

class DataManager: ObservableObject {

    // MARK: - Properties
    //publishing (type of data & array of id's) of changed elements, for views updates if needed (like current user in session)
    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
    
    var cancellables: Set<AnyCancellable> = []
    
//    public static let shared = DataManager(forPreview: false)
//    public static let preview = DataManager(forPreview: true)

    public let persistentContainer: NSPersistentContainer

    var backgroundContext: NSManagedObjectContext
    var moc: NSManagedObjectContext
    // MARK: - Init
     init(forPreview: Bool = false) {
        if forPreview {
            self.persistentContainer = NSPersistentContainer(
                name: "BroadcastPlanner")
            persistentContainer.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null")
        } else {
            self.persistentContainer = NSPersistentContainer(
                name: "BroadcastPlanner")
        }
        persistentContainer.loadPersistentStores { _, _ in }
        persistentContainer.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent =
            true

        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.automaticallyMergesChangesFromParent = true

        self.moc = persistentContainer.viewContext
    }
}

// MARK: - User CRUD
extension DataManager {

    //cases = newUser created(.main) / newUser from firebase (.bg)
    func fetchOrCreateUserWithId(_ id: String, inContext contextType: ContextType) -> LocalUser {
        let context = contextFromType(contextType)
        let request = LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let user = try? context.fetch(request).first {
                return user
            } else {
                let user = LocalUser(context: context)
                return user
            }
        }
    }

    //in bg
    func createOrUpdateLocalUserWithUser(_ user: BPUser,
                                         inContext contextType: ContextType) -> LocalUser {
        let localUser = fetchOrCreateUserWithId(user.id, inContext: contextType)
        updateLocalUser(localUser, with: user, inContext: contextType)
        return  localUser
    }
    // map
    func updateLocalUser(_ localUser: LocalUser,
                         with bpUser: BPUser,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localUser.firstName = bpUser.firstName
            localUser.lastName = bpUser.lastName
            localUser.isOnline = bpUser.isOnline
            localUser.phoneNumber = bpUser.phoneNumber
            localUser.email = bpUser.email
            localUser.homeAddress = bpUser.homeAddress
            localUser.specializations = bpUser.specialization.joined(separator: ",")
            localUser.creationDate = bpUser.creationDate.dateValue()
            localUser.leaveDate = bpUser.leaveDate.dateValue()
            let image = self.fetchOrCreateImageWithId(bpUser.id, inContext: contextType)
            localUser.image = image
            image.parentUser = localUser
        }
    }
    //just for consistency, no scenario to delete user

    func removeUser(_ user: BPUser, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id)

        context.perform {
            if let userToRemove = try? context.fetch(request).first {
                self.removeLocalUser(userToRemove, inContext: contextType)
            } else {
                print("error removing local user with id = \(user.id)")
            }
        }
    }

    func removeLocalUser(_ localUser: LocalUser, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            if let imageToRemove = localUser.image{
                self.removeLocalImage(imageToRemove, inContext: contextType)
            }
            context.delete(localUser)
        }
    }
}

// MARK: - Event CRUD
extension DataManager {
    func fetchOrCreateEventWithId(_ id: String, inContext contextType: ContextType) -> LocalEvent {
        let context = contextFromType(contextType)
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let newEvent = try? context.fetch(request).first {
                return newEvent
            } else {
                let newEvent = LocalEvent(context: context)
                newEvent.id = id
                return newEvent
            }
        }
    }

    func createOrUpdateLocalEventWithEvent(_ event: BPEvent,
                                           inContext contextType: ContextType) -> LocalEvent{
        let localEvent = fetchOrCreateEventWithId(event.id, inContext: contextType)
        updateLocalEvent(localEvent, with: event, inContext: contextType)
        return localEvent
    }

    func updateLocalEvent(_ localEvent: LocalEvent, with event: BPEvent,inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localEvent.date = event.date
            if let broadcasterId = event.broadcasterId{
                let broadcaster = self.fetchOrCreateBroadcasterWithId(broadcasterId, inContext: contextType)
                localEvent.broadcaster = broadcaster
                broadcaster.addToEvents(localEvent)
            }
            if let obvanId = event.obVanId{
                let obvan = self.fetchOrCreateObvanWithId(obvanId, inContext: contextType)
                localEvent.obVan = obvan
                obvan.addToEvents(localEvent)
            }
            
            if let locationID = event.locationID{
                let location = self.fetchOrCreateLocationWithId(locationID, inContext: contextType)
                localEvent.location = location
                location.addToEvents(localEvent)
            }
            
            if let homeClubId = event.homeClubId{
                let homeClub = self.fetchOrCreateClubWithId(homeClubId, inContext: contextType)
                localEvent.homeClub = homeClub
                homeClub.addToHomeEvent(localEvent)
            }
            
            if let guestClubId = event.guestClubId{
                let guestClub = self.fetchOrCreateClubWithId(guestClubId, inContext: contextType)
                localEvent.guestClub = guestClub
                guestClub.addToGuestEvent(localEvent)
            }
            if let locationPreviewId = event.locationPreviewId{
                let localImage = self.fetchOrCreateImageWithId(locationPreviewId, inContext: contextType)
                localEvent.locationPreview = localImage
                localImage.parentLocationPreviewEvent = localEvent
            }
            if let obvanPreviewId = event.obvanPreviewId{
                let localImage = self.fetchOrCreateImageWithId(obvanPreviewId, inContext: contextType)
                localEvent.obvanPreview = localImage
                localImage.parentObvanPreviewEvent = localEvent
            }
            for ownerId in event.ownersIds {
                let user = self.fetchOrCreateUserWithId(ownerId, inContext: contextType)
                localEvent.addToOwners(user)
                user.addToOwnedEvents(localEvent)
            }
            for user in event.usersIds {
                let user = self.fetchOrCreateUserWithId(user, inContext: contextType)
                user.addToParticipateEvents(localEvent)
                localEvent.addToUsers(user)
            }
            for locationPoint in event.locationPoints {
                let point = self.createOrUpdateLocalPointWithLocationPoint(locationPoint, inContext: contextType)
                localEvent.addToLocationPoints(point)
                point.event = localEvent
                
            }
            for unit in event.obVanUnits {
                let localUnit = self.createOrUpdateLocalObvanUnitWithObvanUnit(unit, inContext: contextType)
                localEvent.addToObVanUnits(localUnit)
                localUnit.event = localEvent
            }
        }
    }

    func removeEvent(_ event: BPEvent, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id)
        context.perform{
            if let eventToRemove = try? context.fetch(request).first {
                self.removeLocalEvent(eventToRemove, inContext: contextType)
            } else {
                print("error removing event with id = \(event.id)")
            }
        }
    }

    func removeLocalEvent(_ localEvent: LocalEvent, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform{
            for locationPoint in localEvent.viewLocationPoints {
                self.removeLocalLocationPoint(locationPoint, inContext: contextType)
            }
            for unit in localEvent.viewObvanUnits {
                self.removeLocalObvanUnit(unit, inContext: contextType)
            }
            context.delete(localEvent) }
    }
}

// MARK: - Image CRUD
extension DataManager {
    
    func fetchImagesByType(_ type: String, inContext contextType: ContextType) async -> [LocalImage]{
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        let context = contextFromType(contextType)
        return await context.perform {
            return (try? context.fetch(request)) ?? []
        }
  }

    func fetchOrCreateImageWithId(_ id: String, inContext contextType: ContextType) -> LocalImage {
        let context = contextFromType(contextType)
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let value = try? context.fetch(request).first {
                return value
            } else {
                let newImage = LocalImage(context: context)
                newImage.id = id
                return newImage
            }
        }
    }

    func createOrUpdateLocalImageWithId(_ id: String,
                                        withImage image: UIImage,
                                        andType type: GlobalProperties.ImageType,
                                        inContext contextType: ContextType) -> LocalImage {
        let localImage = fetchOrCreateImageWithId(id, inContext: contextType)
        let _ = ImagesManager().saveResizedImages(image: image, id: id, type: type)
        assignType(type: type.rawValue, toLocalImage: localImage, inContext: contextType)
        return localImage
    }

    func createOrUpdateLocalImageWithImageData(imageData: ImageData, withImage image: UIImage, inContext contextType: ContextType) -> LocalImage{
        let localImage = fetchOrCreateImageWithId(imageData.id, inContext: contextType)
        assignType(type: imageData.type, toLocalImage: localImage, inContext: contextType)
        var type: GlobalProperties.ImageType = .none
        if let newType = GlobalProperties.ImageType.init(rawValue: imageData.type){
            type = newType
        }
        let _ = ImagesManager().saveResizedImages(image: image, id: imageData.id,type: type)
        return localImage
    }
    
    func assignType(type: String, toLocalImage image: LocalImage, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            image.type = type
        }
    }

    func removeImageWithId(_ id: String, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        context.perform {
            if let imageToRemove = try? context.fetch(request).first {
                self.removeLocalImage(imageToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalImage(_ localImage: LocalImage, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            let _ = ImagesManager().removeImageFromDevice(withId: localImage.viewId)
            context.delete(localImage)
        }
    }
}

// MARK: - Location CRUD
extension DataManager {

    func fetchOrCreateLocationWithId(_ id: String, inContext contextType: ContextType) -> LocalLocation {
        let context = contextFromType(contextType)
        let request = LocalLocation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait{
            if let location = try? context.fetch(request).first {
                return location
            } else {
                let newLocation = LocalLocation(context: context)
                newLocation.id = id
                return newLocation
            }
        }
    }

    func createOrUpdateLocalLocationWithLocation(_ location: Location, inContext contextType: ContextType) -> LocalLocation {
        let localLocation = fetchOrCreateLocationWithId(location.id, inContext: contextType)
        updateLocalLocation( localLocation, withLocation: location, inContext: contextType)
        return localLocation
    }

    func updateLocalLocation(_ localLocation: LocalLocation, withLocation location: Location,inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localLocation.title = location.title
            localLocation.address = location.address
            for id in location.imagesIds {
                let image = self.fetchOrCreateImageWithId(id, inContext: contextType)
                localLocation.addToImages(image)
                image.parentLocationImage = localLocation
            }
            if let imageId = location.locationBackgroundId{
                let backgroundImage = self.fetchOrCreateImageWithId(
                    imageId, inContext: contextType)
                localLocation.background = backgroundImage
                backgroundImage.parentLocationBackground = localLocation
            }
        }
    }
    
    func updateLocalLocation(_ location: LocalLocation, withTitle title: String, address: String, localImages: [UIImage], locationBackground: LocalImage?) async {
                await withTaskGroup(of: Void.self) { group in
                    for localImage in localImages{
                        group.addTask { [weak self] in
                            guard let self else { return }
                            //backgroundImages add to set
                            print("create new LocalImage")
                            let newImage = createOrUpdateLocalImageWithImageData(imageData: ImageData(id: UUID().uuidString, type: GlobalProperties.ImageType.location.rawValue), withImage: localImage, inContext: .main)
                            await moc.perform {
                                print("linking LocalImage and location")
                                location.addToImages(newImage)
                                newImage.parentLocationImage = location
                            }
                        }
                    }
                    group.addTask { [weak self] in
                        guard let self else { return }
                        //add backgroundToEvent
                        if let locationBackground = locationBackground {
                            print("creating back in cd")
                            await moc.perform {
                                print("saving and linking location")
                                location.background = locationBackground
                                locationBackground.parentLocationBackground = location
                            }
                        }
                        
                        await moc.perform {
                            print("saving title and address")
                            location.title = title
                            location.address = address
                        }
                    }
                    await group.waitForAll()
        //            print("updating final save context")
                    await saveContext(type: .main,
                                      publish: .locations,
                                      id: [])
        //
        //            await NetworkManager.shared.saveLocation(localLocation.mapToLocation())
        //
                }
    }

    func removeLocation(location: Location, inContext contextType: ContextType){
        let context = contextFromType(contextType)
        let request = LocalLocation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", location.id)
        context.perform {
            if let locationToRemove = try? context.fetch(request).first {
                self.removeLocalLocation(locationToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalLocation(_ location: LocalLocation, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            for localImage in location.viewLocalImages{
                self.removeLocalImage(localImage, inContext: contextType)
            }
            if let localImage = location.background{
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(location)
        }
    }
}

// MARK: - Broadcaster / obVan CRUD
extension DataManager {
    //broadcaster
    func fetchOrCreateBroadcasterWithId(_ id: String, inContext contextType: ContextType) -> LocalBroadcaster {
        let context = contextFromType(contextType)
        let request = LocalBroadcaster.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let localBroadcaster = try? context.fetch(request).first {
                return localBroadcaster
            } else {
                let newBroadcaster = LocalBroadcaster(context: context)
                newBroadcaster.id = id
                return newBroadcaster
            }
        }
    }

    func createOrUpdateLocalBroadcasterWithBroadcaster(_ broadcaster: Broadcaster,
                                                       inContext contextType: ContextType)->LocalBroadcaster {
        let localBroadcaster = fetchOrCreateBroadcasterWithId(broadcaster.id, inContext: contextType)
        updateLocalBroadcaster(localBroadcaster,withBroadcaster: broadcaster,inContext: contextType)
        return localBroadcaster
    }

    func updateLocalBroadcaster(_ localBroadcaster: LocalBroadcaster,
                                withBroadcaster broadcaster: Broadcaster,
                                inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localBroadcaster.title = broadcaster.title
            for obvan in broadcaster.obVans {
                let localObvan = self.createOrUpdateLocalObvanWithObvan(obvan, inContext: contextType)
                localBroadcaster.addToCars(localObvan)
                localObvan.broadcaster = localBroadcaster
            }
        }
    }

    func removeBroadcaster( broadcaster: Broadcaster, inContext contextType: ContextType) {
        let context = contextFromType(contextType)

        let request = LocalBroadcaster.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", broadcaster.id)
        context.perform{
            if let broadcasterToRemove = try? context.fetch(request).first {
                self.removeLocalBroadcaster(broadcasterToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalBroadcaster(_ broadcaster: LocalBroadcaster, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            for obvan in broadcaster.viewCars{
                self.removeLocalOBVan(localObvan: obvan, inContext: contextType)
            }
            context.delete(broadcaster)
        }
    }

    //obVan
    func fetchOrCreateObvanWithId(_ id: String, inContext contextType: ContextType) -> LocalOBVan {
        let context = contextFromType(contextType)
        let request = LocalOBVan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let obvan = try? context.fetch(request).first {
                return obvan
            } else {
                let newObvan = LocalOBVan(context: context)
                newObvan.id = id
                return newObvan
            }
        }
    }

    func createOrUpdateLocalObvanWithObvan(_ obvan: OBVan, inContext contextType: ContextType) -> LocalOBVan{
        let localObvan = fetchOrCreateObvanWithId(obvan.id, inContext: contextType)
        updateLocalObvan(localObvan, withObvan: obvan, inContext: contextType)
        return localObvan
        
    }

    func updateLocalObvan(_ localObvan: LocalOBVan, withObvan obvan: OBVan, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localObvan.name = obvan.name
            let image = self.fetchOrCreateImageWithId(obvan.imageId, inContext: contextType)
            localObvan.image = image
            image.parentObVan = localObvan
        }
    }

    func removeObvan(_ obvan: OBVan, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalOBVan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", obvan.id)
        context.perform {
            if let obvanToRemove = try? context.fetch(request).first {
                if let localImage = obvanToRemove.image{
                    self.removeLocalImage(localImage, inContext: contextType)
                }
                context.delete(obvanToRemove)
            }
        }
    }
    
    func removeLocalOBVan(localObvan: LocalOBVan, inContext contextType: ContextType){
        let context = contextFromType(contextType)
        context.perform {
            if let localImage = localObvan.image{
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(localObvan)
        }
    }

    func removeObvanWithId(_ id: String, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalOBVan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        context.perform {
            if let obvanToRemove = try? context.fetch(request).first {
                if let localImage = obvanToRemove.image{
                    self.removeLocalImage(localImage, inContext: contextType)
                }
                context.delete(obvanToRemove)
            }
        }
    }
}

// MARK: - Club CRUD
extension DataManager {
    
    func fetchAllLocalClubs(inContext contextType: ContextType) -> [LocalClub]{
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        return context.performAndWait {
            return (try? context.fetch(request)) ?? []
        }
    }

    func fetchOrCreateClubWithId(_ id: String, inContext contextType: ContextType) -> LocalClub {
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait{
            if let club = try? context.fetch(request).first {
                return club
            } else {
                let newClub = LocalClub(context: context)
                newClub.id = id
                return newClub
            }
        }
    }

    func createOrUpdateLocalClubWithClub(_ club: Club, inContext contextType: ContextType) -> LocalClub {
        let localClub = fetchOrCreateClubWithId(club.id, inContext: contextType)
        updateLocalClub(localClub, withClub: club, inContext: contextType)
        return localClub
    }

    func updateLocalClub(_ localClub: LocalClub, withClub club: Club, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localClub.title = club.title
            localClub.contacts = club.contacts
            localClub.urlString = club.urlString
            let image = self.fetchOrCreateImageWithId(club.id, inContext: contextType)
            localClub.imageLogo = image
            if let clubId = club.homeLocationID{
                let location = self.fetchOrCreateLocationWithId(clubId, inContext: contextType)
                localClub.homeLocation = location
                location.addToHomeClub(localClub)
            }
        }
    }

    func updateClubWith(
        id: String, title: String, uiimage: UIImage?, contacts: String,
        urlString: String, location: LocalLocation?,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            let request = LocalClub.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            if let club = try? context.fetch(request).first {
                club.title = title
                if let uiimage {
                    if let localImage = club.imageLogo {
                        localImage.uploadImage(uiimage: uiimage)
                    } else {
                        let localImage =
                            self.createOrUpdateLocalImageWithId(
                                UUID().uuidString,
                                withImage: uiimage,
                                andType: GlobalProperties.ImageType.club,
                                inContext: contextType)
                        localImage.uploadImage(uiimage: uiimage)
                        club.imageLogo = localImage
                        localImage.parentClubLogo = club
                    }
                }
                club.contacts = contacts
                club.urlString = urlString
                if let location {
                    club.homeLocation = location
                    location.addToHomeClub(club)
                }
            }
        }
    }
    
    func updateClubWithClub(
        club: LocalClub, title: String, uiimage: UIImage?, contacts: String,
        urlString: String, location: LocalLocation?,
        inContext contextType: ContextType
    ) async {
        let context = contextFromType(contextType)
        await context.perform {
                club.title = title
                if let uiimage {
                    if let localImage = club.imageLogo {
                        localImage.uploadImage(uiimage: uiimage)
                    } else {
                        let localImage =
                            self.createOrUpdateLocalImageWithId(
                                UUID().uuidString,
                                withImage: uiimage,
                                andType: GlobalProperties.ImageType.club,
                                inContext: contextType)
                        localImage.uploadImage(uiimage: uiimage)
                        club.imageLogo = localImage
                        localImage.parentClubLogo = club
                    }
                }
                club.contacts = contacts
                club.urlString = urlString
                if let location {
                    club.homeLocation = location
                    location.addToHomeClub(club)
                }
        }
    }

    func removeClub(club: Club, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", club.id)
        context.perform{
            if let clubToRemove = try? context.fetch(request).first {
                self.removeLocalClub(localClub: clubToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalClub(localClub: LocalClub, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            if let localImage = localClub.imageLogo{
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(localClub)
        }
    }
}

// MARK: - Environment CRUD
extension DataManager {
    //camera
    func fetchOrCreateCameraWithId(_ id: String, inContext contextType: ContextType) -> LocalCamera {
        let context = contextFromType(contextType)
        let request = LocalCamera.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait{
            if let localCamera = try? context.fetch(request).first {
                return localCamera
            } else {
                let newCamera = LocalCamera(context: context)
                newCamera.id = id
                return newCamera
            }
        }
    }

    func createOrUpdateCamera(_ camera: Camera, inContext contextType: ContextType) -> LocalCamera {
        let localCamera = fetchOrCreateCameraWithId(camera.id, inContext: contextType)
        updateLocalCamera(localCamera, withCamera: camera, inContext: contextType)
        return localCamera
    }
    func updateLocalCamera(_ localCamera: LocalCamera, withCamera camera: Camera, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localCamera.optic = camera.optic.rawValue
        }
    }
    
    func linkLocalCamera(_ camera: LocalCamera ,WithPoint point:LocalLocationPoint,InContext contextType: ContextType){
        let context = contextFromType(contextType)
        context.perform {
            camera.point = point
            point.addToCameras(camera)
        }
    }
    
    func removeCamera(camera: Camera, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalCamera.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", camera.id)
        context.perform{
            if let cameraToRemove = try? context.fetch(request).first {
                self.removeLocalCamera(cameraToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalCamera(_ camera: LocalCamera, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform{ context.delete(camera) }
    }
    //sound
    func fetchOrCreateSoundWithId(_ id: String, inContext contextType: ContextType) -> LocalSound {
        let context = contextFromType(contextType)
        let request = LocalSound.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let localSound = try? context.fetch(request).first {
                return localSound
            } else {
                let newSound = LocalSound(context: context)
                newSound.id = id
                return newSound
            }
        }
    }

    func createOrUpdateSound(_ sound: Sound, inContext contextType: ContextType) -> LocalSound {
        let localSound = self.fetchOrCreateSoundWithId(sound.id, inContext: contextType)
        updateLocalSound(localSound, withSound: sound, inContext: contextType)
        return localSound
    }
    func updateLocalSound(_ localSound: LocalSound, withSound sound: Sound, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localSound.placeType = sound.placeType.rawValue
            localSound.windDefence = sound.windDefence.rawValue
        }
    }
    
    func linkLocalSound(_ sound: LocalSound ,WithPoint point:LocalLocationPoint,InContext contextType: ContextType){
        let context = contextFromType(contextType)
        context.perform {
            sound.point = point
            point.addToSounds(sound)
        }
    }
    
    func removeSound(sound: Sound, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalSound.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", sound.id)
        context.perform {
            if let soundToRemove = try? context.fetch(request).first {
                self.removeLocalSound(soundToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalSound(_ sound: LocalSound, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform { context.delete(sound) }
    }
    //light

    func fetchOrCreateLightWithId(_ id: String, inContext contextType: ContextType) -> LocalLight {
        let context = contextFromType(contextType)
        let request = LocalLight.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait {
            if let light = try? context.fetch(request).first {
                return light
            } else {
                let newLight = LocalLight(context: context)
                newLight.id = id
                return newLight
            }
        }
    }

    func createOrUpdateLocalLightWithLight(_ light: Light, inContext contextType: ContextType) -> LocalLight {
        let localLight = fetchOrCreateLightWithId(light.id, inContext: contextType)
        updateLocalLight(localLight, withLight: light, inContext: contextType)
        return localLight
    }

    func updateLocalLight(_ localLight: LocalLight, withLight light: Light, inContext contextType: ContextType ) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localLight.lightType = light.lightType.rawValue
        }
    }
    
    func linkLocalLight(_ light: LocalLight ,WithPoint point:LocalLocationPoint,InContext contextType: ContextType){
        let context = contextFromType(contextType)
        context.perform {
            light.point = point
            point.addToLights(light)
        }
    }

    func removeLight(light: Light, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalLight.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", light.id)
        context.perform {
            if let lightToRemove = try? context.fetch(request).first {
                self.removeLocalLight(lightToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalLight(_ light: LocalLight, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform { context.delete(light) }
    }

    //hardware
    func fetchOrCreateHardwareWithId(_ id: String,
                                     inContext contextType: ContextType) -> LocalHardware {
        let context = contextFromType(contextType)
        let request = LocalHardware.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return context.performAndWait{
            if let localHardware = try? context.fetch(request).first {
                return localHardware
            } else {
                let newHardware = LocalHardware(context: context)
                newHardware.id = id
                return newHardware
            }
        }
    }

    func createOrUpdateLocalHardwareWithHardware(_ hardware: Hardware,
                                                 inContext contextType: ContextType) -> LocalHardware {
        let localHardware = fetchOrCreateHardwareWithId(hardware.id, inContext: contextType)
        updateLocalHardware(localHardware, withHardware: hardware, inContext: contextType)
        return localHardware
    }

    func updateLocalHardware(_ localHardware: LocalHardware, withHardware hardware: Hardware, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localHardware.type = hardware.envType.rawValue
            localHardware.channels = hardware.chanels.joined(separator: ",")
        }
    }
    
    func linkLocalHardware(_ hardware: LocalHardware ,WithUnit unit:LocalObvanUnit,InContext contextType: ContextType){
        let context = contextFromType(contextType)
        context.perform {
            hardware.obVanUnit = unit
            unit.hardware = hardware
        }
    }

    func removeHardware(_ hardware: Hardware, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalHardware.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hardware.id)
        context.perform {
            if let hardwareToRemove = try? context.fetch(request).first {
                self.removeLocalHardware(
                    hardwareToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalHardware(_ localhardware: LocalHardware, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform { context.delete(localhardware) }
    }
}

// MARK: - Location Points OBVan Units CRUD
extension DataManager {
    //location point
    func fetchOrCreateLocationPointWithId(_ id: String, inContext contextType: ContextType) -> LocalLocationPoint {
        let context = contextFromType(contextType)
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return  context.performAndWait {
            if let localPoint = try? context.fetch(request).first {
                return localPoint
            } else {
                let newPoint = LocalLocationPoint(context: context)
                newPoint.id = id
                return newPoint
            }
        }
    }

    func createOrUpdateLocalPointWithLocationPoint(_ point: LocationPoint, inContext contextType: ContextType) -> LocalLocationPoint {
        let localPoint = fetchOrCreateLocationPointWithId(point.id, inContext: contextType)
        updateLocalPoint(localPoint, withLocationPoint: point, inContext: contextType)
        return localPoint

    }
    func updateLocalPoint( _ localPoint: LocalLocationPoint,
                           withLocationPoint point: LocationPoint,
                           inContext contextType: ContextType)  {
        let context = contextFromType(contextType)
        context.performAndWait{
            localPoint.coordinateX = Float(point.coordinateX)
            localPoint.coordinateY = Float(point.coordinateY)
            localPoint.rotation = Int16(point.rotation)
            localPoint.number = Int16(point.number)
            
            let image = fetchOrCreateImageWithId(point.imageId, inContext: contextType)
            localPoint.image = image
            image.addToLocationPoint(localPoint)
            
            localPoint.pointDescription = point.description
            localPoint.task = point.task
            
            for id in point.userId {
                let user = fetchOrCreateUserWithId(id, inContext: contextType)
                localPoint.addToUser(user)
                user.addToLocationPoints(localPoint)
            }
            
            for sound in point.sounds {
                let localSound = createOrUpdateSound(sound, inContext: contextType)
                localPoint.addToSounds(localSound)
                localSound.point = localPoint
            }
            for cam in point.cameras {
                let camera = createOrUpdateCamera(cam, inContext: contextType)
                localPoint.addToCameras(camera)
                camera.point = localPoint
                
            }
            for light in point.lights {
                let localLight = createOrUpdateLocalLightWithLight(light, inContext: contextType)
                localPoint.addToLights(localLight)
                localLight.point = localPoint
            }
        }
    }
    func removeLocationPoint(_ point: LocationPoint, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", point.id)
        context.perform {
            if let pointToRemove = try? context.fetch(request).first {
                self.removeLocalLocationPoint(
                    pointToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalLocationPoint(_ localPoint: LocalLocationPoint, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            for camera in localPoint.viewLocalCameras {
                self.removeLocalCamera(camera, inContext: contextType)
            }
            
            for sound in localPoint.viewLocalSounds {
                self.removeLocalSound(sound, inContext: contextType)
            }
            
            for light in localPoint.viewLocalLights{
                self.removeLocalLight(light, inContext: contextType)
            }
            if let loacImage = localPoint.image{
                self.removeLocalImage(loacImage, inContext: contextType)
            }
            context.delete(localPoint)
        }
    }

    //Obvan unit
    func fetchOrCreateObvanUnitWithId(_ id: String, inContext contextType: ContextType) -> LocalObvanUnit {
        let context = contextFromType(contextType)
        let request = LocalObvanUnit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return  context.performAndWait {
            if let value = try? context.fetch(request).first {
                return value
            } else {
                let newUnit = LocalObvanUnit(context: context)
                newUnit.id = id
                return newUnit
            }
        }
    }

    func createOrUpdateLocalObvanUnitWithObvanUnit(_ obvanUnit: OBVanUnit,
                                                   inContext contextType: ContextType) -> LocalObvanUnit {
        let localUnit = fetchOrCreateObvanUnitWithId(obvanUnit.id, inContext: contextType)
        updateLocalUnit(localUnit, withUnit: obvanUnit, inContext: contextType)
        return localUnit

    }

    func updateLocalUnit(_ localUnit: LocalObvanUnit,
                         withUnit unit: OBVanUnit,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait{
            localUnit.position = unit.position.rawValue
            localUnit.coordinateX = Float(unit.coordinateX)
            localUnit.coordinateY = Float(unit.coordinateY)
            localUnit.rotation = Int16(unit.rotation)
            let user = fetchOrCreateUserWithId(unit.userId, inContext: contextType)
            localUnit.user = user
            user.addToObVanUnits(localUnit)
            
            for hardware in unit.hardwares {
                let hardware = fetchOrCreateHardwareWithId(hardware.id, inContext: contextType)
                localUnit.hardware = hardware
                hardware.obVanUnit = localUnit
            }
        }
    }

    func removeObvanUnit(unit: OBVanUnit, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalObvanUnit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", unit.id)
        context.perform {
            if let unitToRemove = try? context.fetch(request).first {
                self.removeLocalObvanUnit(unitToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalObvanUnit(_ unit: LocalObvanUnit, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform {
            if let hardware = unit.hardware{
                self.removeLocalHardware(hardware, inContext: contextType)
            }
            context.delete(unit)
        }
    }
}

// MARK: - Save context and publish changes to update ui
extension DataManager {
    func saveContext(type contextType: ContextType, publish: GlobalProperties.PublishChanges, id: [String]) async {
        let context = contextFromType(contextType)
            await context.perform {
                if context.hasChanges {
                    do {
                        try context.save()
                        if publish != .none {
                            Task{
                                await MainActor.run {
                                    self.updatePublisher.send((publish,id))
                                }
                            }
                        }
                    } catch {
                        print("error save context: \(error.localizedDescription)")
                    }
                } else {
                    print("no changes")
                }
                
            }
    }
}

// MARK: - Context choose
extension DataManager {
    func contextFromType(_ contextType: ContextType) -> NSManagedObjectContext {
        let context: NSManagedObjectContext
        switch contextType {
        case .main:
            context = self.moc
        case .bg:
            context = self.backgroundContext
        }
        return context
    }
}

