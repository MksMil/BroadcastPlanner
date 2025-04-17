import Combine
import CoreData
import UIKit

enum ContextType {
    case main, bg
}

class DataManager: ObservableObject {

    // MARK: - Properties
    //publishing (type of data & array of id's) of changed elements, for views updates if needed (like current user in session)
    var updatePublisher: PassthroughSubject = PassthroughSubject<
        (GlobalProperties.PublishChanges, [String]), Never
    >()

    var cancellables: Set<AnyCancellable> = []

    let persistentContainer: NSPersistentContainer

    var backgroundContext: NSManagedObjectContext
    var moc: NSManagedObjectContext
    // MARK: - Init

    init(forPreview: Bool = false, name: String = "BroadcastPlanner") {
        self.persistentContainer = NSPersistentContainer(name: name)
        if forPreview {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
            print("[CoreData] Store type: \(description.type)")
        }

        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.backgroundContext.automaticallyMergesChangesFromParent = true

        self.moc = persistentContainer.viewContext
    }

}

// MARK: - Generics
extension DataManager {

    func fetchOrCreateObject<T: NSManagedObject>(
        ofType type: T.Type,
        predicate: NSPredicate,
        in context: NSManagedObjectContext,
        initializer: () -> T
    ) -> T {
        let request = T.fetchRequest()
        request.predicate = predicate
        if let result = try? context.fetch(request).first as? T {
            return result
        } else {
            return initializer()
        }
    }
}

// MARK: - User CRUD
extension DataManager {

    func createOrUpdateLocalUserWithUser(
        _ user: UserDTO,
        inContext contextType: ContextType
    ) -> LocalUser {
        let context = contextFromType(contextType)
        let localUser = fetchOrCreateObject(
            ofType: LocalUser.self,
            predicate: NSPredicate(format: "id == %@", user.id),
            in: context
        ) {
            let newUser = LocalUser(context: context)
            newUser.id = user.id
            return newUser
        }
        updateLocalUser(localUser, with: user, inContext: contextType)
        return localUser
    }
    // map
    func updateLocalUser(
        _ localUser: LocalUser,
        with bpUser: UserDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localUser.id = bpUser.id
            localUser.firstName = bpUser.firstName
            localUser.lastName = bpUser.lastName
            localUser.isOnline = bpUser.isOnline
            localUser.phoneNumber = bpUser.phoneNumber
            localUser.email = bpUser.email
            localUser.homeAddress = bpUser.homeAddress
            localUser.specializations = bpUser.specialization.joined(
                separator: ","
            )
            localUser.creationDate = bpUser.creationDate.dateValue()
            localUser.leaveDate = bpUser.leaveDate.dateValue()
            let image = self.fetchOrCreateObject(
                ofType: LocalImage.self,
                predicate: NSPredicate(format: "id == %@", bpUser.id),
                in: context
            ) {
                let newImage = LocalImage(context: context)
                newImage.id = bpUser.id
                return newImage
            }
            localUser.image = image
            image.parentUser = localUser
        }
    }
    //just for consistency, no scenario to delete user

    func removeUser(
        _ user: UserDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        let request = LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id)

        context.performAndWait { [weak self] in
            guard let self else { return }
            if let userToRemove = try? context.fetch(request).first {
                self.removeLocalUser(userToRemove, inContext: contextType)
            } else {
                print("error removing local user with id = \(user.id)")
            }
        }
    }

    func removeLocalUser(
        _ localUser: LocalUser,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            if let imageToRemove = localUser.image {
                self.removeLocalImage(imageToRemove, inContext: contextType)
            }
            context.delete(localUser)
        }
    }

    func fetchUsersAvailableToEvent(_ event: LocalEvent) -> [LocalUser] {
        let request = LocalUser.fetchRequest()
        do {
            let users = try moc.fetch(request)
            return users.filter { $0.isAvailableToEvent(event: event) }
        } catch {
            print("DataManager: error fetching available users")
            return []
        }
    }
}

// MARK: - Event CRUD
extension DataManager {
    func createOrUpdateLocalEventWithEvent(
        _ event: EventDTO,
        inContext contextType: ContextType
    ) -> LocalEvent {
        let context = contextFromType(contextType)
        let localEvent = fetchOrCreateObject(
            ofType: LocalEvent.self,
            predicate: NSPredicate(format: "id == %@", event.id),
            in: context
        ) {
            let newEvent = LocalEvent(context: context)
            newEvent.id = event.id
            return newEvent
        }
        updateLocalEvent(localEvent, with: event, inContext: contextType)

        return localEvent
    }

    func updateLocalEvent(
        _ localEvent: LocalEvent,
        with event: EventDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localEvent.date = event.date
            localEvent.id = event.id
            if let obvanId = event.obVanId {
                let obvan = self.fetchOrCreateObject(
                    ofType: LocalObvan.self,
                    predicate: NSPredicate(format: "id == %@", obvanId),
                    in: context
                ) {
                    let newObvan = LocalObvan(context: context)
                    newObvan.id = obvanId
                    return newObvan
                }
                localEvent.obvan = obvan
                obvan.addToEvents(localEvent)
            }

            if let locationID = event.locationID {
                let location = self.fetchOrCreateObject(
                    ofType: LocalLocation.self,
                    predicate: NSPredicate(format: "id == %@", locationID),
                    in: context
                ) {
                    let newLocation = LocalLocation(context: context)
                    newLocation.id = locationID
                    return newLocation
                }
                localEvent.location = location
                location.addToEvents(localEvent)
            }

            if let homeClubId = event.homeClubId {
                let homeClub = self.fetchOrCreateObject(
                    ofType: LocalClub.self,
                    predicate: NSPredicate(format: "id == %@", homeClubId),
                    in: context
                ) {
                    let newClub = LocalClub(context: context)
                    newClub.id = homeClubId
                    return newClub
                }
                localEvent.homeClub = homeClub
                homeClub.addToHomeEvent(localEvent)
            }

            if let guestClubId = event.guestClubId {
                let guestClub = self.fetchOrCreateObject(
                    ofType: LocalClub.self,
                    predicate: NSPredicate(format: "id == %@", guestClubId),
                    in: context
                ) {
                    let newClub = LocalClub(context: context)
                    newClub.id = guestClubId
                    return newClub
                }
                localEvent.guestClub = guestClub
                guestClub.addToGuestEvent(localEvent)
            }
            if let locationPreviewId = event.locationPreviewId {
                let localImage = self.fetchOrCreateObject(
                    ofType: LocalImage.self,
                    predicate: NSPredicate(
                        format: "id == %@",
                        locationPreviewId
                    ),
                    in: context
                ) {
                    let newImage = LocalImage(context: context)
                    newImage.id = locationPreviewId
                    return newImage
                }
                localEvent.locationPreview = localImage
                localImage.parentLocationPreviewEvent = localEvent
            }
            if let obvanPreviewId = event.obvanPreviewId {
                let localImage = self.fetchOrCreateObject(
                    ofType: LocalImage.self,
                    predicate: NSPredicate(format: "id == %@", obvanPreviewId),
                    in: context
                ) {
                    let newImage = LocalImage(context: context)
                    newImage.id = obvanPreviewId
                    return newImage
                }
                localEvent.obvanPreview = localImage
                localImage.parentObvanPreviewEvent = localEvent
            }
            for ownerId in event.ownersIds {
                let user = self.fetchOrCreateObject(
                    ofType: LocalUser.self,
                    predicate: NSPredicate(format: "id == %@", ownerId),
                    in: context
                ) {
                    let newUser = LocalUser(context: context)
                    newUser.id = ownerId
                    return newUser
                }

                localEvent.addToOwners(user)
                user.addToOwnedEvents(localEvent)
            }
            for user in event.usersIds {
                let user = self.fetchOrCreateObject(
                    ofType: LocalUser.self,
                    predicate: NSPredicate(format: "id == %@", user),
                    in: context
                ) {
                    let newUser = LocalUser(context: context)
                    newUser.id = user
                    return newUser
                }

                user.addToParticipateEvents(localEvent)
                localEvent.addToUsers(user)
            }
            for locationPoint in event.locationPoints {
                let point = self.createOrUpdateLocalPointWithLocationPoint(
                    locationPoint,
                    inContext: contextType
                )
                localEvent.addToLocationPoints(point)
                point.event = localEvent

            }
            for unit in event.obVanUnits {
                let localUnit = self.createOrUpdateLocalObvanUnitWithObvanUnit(
                    unit,
                    inContext: contextType
                )
                localEvent.addToObvanUnits(localUnit)
                localUnit.event = localEvent
            }
        }
    }
    @MainActor
    func removeEvent(_ event: EventDTO, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id)
        context.performAndWait { [weak self] in
            guard let self else { return }
            if let eventToRemove = try? context.fetch(request).first {
                self.removeLocalEvent(eventToRemove, inContext: contextType)
            } else {
                print("error removing event with id = \(event.id)")
            }
        }
    }

    @MainActor
    func removeLocalEvent(
        _ localEvent: LocalEvent,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            for locationPoint in localEvent.viewLocationPoints {
                self.removeLocalLocationPoint(
                    locationPoint,
                    inContext: contextType
                )
            }
            for unit in localEvent.viewObvanUnits {
                self.removeLocalObvanUnit(unit, inContext: contextType)
            }
            context.delete(localEvent)
        }
    }
}

// MARK: - Image CRUD
extension DataManager {

    func fetchImagesByType(
        _ type: GlobalProperties.ImageType,
        inContext contextType: ContextType
    ) async -> [LocalImage] {
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        let context = contextFromType(contextType)
        return await context.perform {
            return (try? context.fetch(request)) ?? []
        }
    }

    func createOrUpdateLocalImageWithId(
        _ id: String,
        withImage image: UIImage,
        andType type: GlobalProperties.ImageType,
        inContext contextType: ContextType
    ) -> LocalImage {
        let context = contextFromType(contextType)
        let localImage = fetchOrCreateObject(
            ofType: LocalImage.self,
            predicate: NSPredicate(format: "id == %@", id),
            in: context
        ) {
            let newImage = LocalImage(context: context)
            newImage.id = id
            return newImage
        }

        let _ = ImagesManager.saveResizedImages(
            image: image,
            id: id,
            type: type
        )

        assignType(
            type: type.rawValue,
            toLocalImage: localImage,
            inContext: contextType
        )
        return localImage
    }

    func createOrUpdateLocalImageWithImageData(
        imageData: ImageDTO,
        withImage image: UIImage,
        inContext contextType: ContextType
    ) -> LocalImage {
        let context = contextFromType(contextType)
        let localImage = fetchOrCreateObject(
            ofType: LocalImage.self,
            predicate: NSPredicate(format: "id == %@", imageData.id),
            in: context
        ) {
            let newImage = LocalImage(context: context)
            newImage.id = imageData.id
            return newImage
        }
        let type =
            GlobalProperties.ImageType.init(rawValue: imageData.type) ?? .none
        assignType(
            type: imageData.type,
            toLocalImage: localImage,
            inContext: contextType
        )
        let _ = ImagesManager.saveResizedImages(
            image: image,
            id: imageData.id,
            type: type
        )
        return localImage
    }

    func assignType(
        type: String,
        toLocalImage image: LocalImage,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            image.type = type
        }
    }

    func removeImageWithId(_ id: String, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        context.perform { [weak self] in
            guard let self else { return }
            if let imageToRemove = try? context.fetch(request).first {
                self.removeLocalImage(imageToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalImage(
        _ localImage: LocalImage,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        let _ = ImagesManager.removeImageFromDevice(
            withId: localImage.viewId
        )
        context.performAndWait {
            context.delete(localImage)
        }
    }
}

// MARK: - Location CRUD
extension DataManager {

    func createOrUpdateLocalLocationWithLocation(
        _ location: LocationDTO,
        inContext contextType: ContextType
    ) async -> LocalLocation {
        let context = contextFromType(contextType)
        let localLocation = fetchOrCreateObject(
            ofType: LocalLocation.self,
            predicate: NSPredicate(format: "id == %@", location.id),
            in: context
        ) {
            let newLocation = LocalLocation(context: context)
            newLocation.id = location.id
            return newLocation
        }
        await updateLocalLocation(
            localLocation,
            withLocation: location,
            inContext: contextType
        )
        return localLocation
    }

    func cleanImagesInLocalLocation(_ localLocation: LocalLocation,inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        await withTaskGroup { group in
            for image in localLocation.viewLocalImages{
                group.addTask { [weak self] in
                    guard let self else { return }
                    self.removeLocalImage(image, inContext: contextType)
                    await context.perform {
                        localLocation.removeFromImages(image)
                    }
                }
            }
            if let backgroundImage = localLocation.background{
                group.addTask { [weak self] in
                    guard let self else { return }
                    self.removeLocalImage(backgroundImage, inContext: contextType)
                    await context.perform {
                        localLocation.background = nil
                    }
                }
            }
        }
    }
    
    func updateLocalLocation(
        _ localLocation: LocalLocation,
        withLocation location: LocationDTO,
        inContext contextType: ContextType
    ) async {
        let context = contextFromType(contextType)
        //clean images
        await cleanImagesInLocalLocation(localLocation, inContext: contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localLocation.title = location.title
            localLocation.address = location.address
            for id in location.imagesIds {
                let image = self.fetchOrCreateObject(
                    ofType: LocalImage.self,
                    predicate: NSPredicate(format: "id == %@", id),
                    in: context
                ) {
                    let newImage = LocalImage(context: context)
                    newImage.id = id
                    return newImage
                }
                localLocation.addToImages(image)
                image.parentLocationImage = localLocation
            }
            if let imageId = location.locationBackgroundId {
                let backgroundImage = self.fetchOrCreateObject(
                    ofType: LocalImage.self,
                    predicate: NSPredicate(format: "id == %@", imageId),
                    in: context
                ) {
                    let newImage = LocalImage(context: context)
                    newImage.id = imageId
                    return newImage
                }
                localLocation.background = backgroundImage
                backgroundImage.parentLocationBackground = localLocation
            }
        }
    }

    func updateLocalLocation(
        _ location: LocalLocation,
        withTitle title: String,
        address: String,
        localImages: [UIImage],
        locationBackground: LocalImage?
    ) async {
        //clean images
        await self.cleanImagesInLocalLocation(location, inContext: .main)
        await withTaskGroup(of: Void.self) { group in
            
            for localImage in localImages {
                group.addTask { [weak self] in
                    guard let self else { return }
                    //backgroundImages add to set
                    let newImage = createOrUpdateLocalImageWithImageData(
                        imageData: ImageDTO(
                            id: UUID().uuidString,
                            type: GlobalProperties.ImageType.location.rawValue
                        ),
                        withImage: localImage,
                        inContext: .main
                    )
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
            await saveContext(
                type: .main,
                publish: .locations,
                id: []
            )
        }
    }

    func removeLocalLocation(
        _ location: LocalLocation,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { [weak self] in
            guard let self else { return }
            for localImage in location.viewLocalImages {
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(location)
        }
    }
}

// MARK: - obvan CRUD
extension DataManager {

    func createOrUpdateLocalObvanWithObvan(
        _ obvan: ObvanDTO,
        inContext contextType: ContextType
    ) -> LocalObvan {
        let context = contextFromType(contextType)
        let localObvan = fetchOrCreateObject(
            ofType: LocalObvan.self,
            predicate: NSPredicate(format: "id == %@", obvan.id),
            in: context
        ) {
            let newObvan = LocalObvan(context: context)
            newObvan.id = obvan.id
            return newObvan
        }
        updateLocalObvan(localObvan, withObvan: obvan, inContext: contextType)
        return localObvan

    }

    func updateLocalObvan(
        _ localObvan: LocalObvan,
        withObvan obvan: ObvanDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localObvan.name = obvan.name
            let image = self.fetchOrCreateObject(
                ofType: LocalImage.self,
                predicate: NSPredicate(format: "id == %@", obvan.imageId),
                in: context
            ) {
                let newImage = LocalImage(context: context)
                newImage.id = obvan.imageId
                return newImage
            }
            localObvan.image = image
            image.parentObvan = localObvan
        }
    }

    //from local user
    func removeObvan(_ obvan: LocalObvan, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.perform { [weak self] in
            guard let self else { return }
            if let localImage = obvan.image {
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(obvan)
        }
    }

    //another local version
    func removeObvanWithId(
        _ id: String,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        let request = LocalObvan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        context.perform { [weak self] in
            guard let self else { return }
            if let obvanToRemove = try? context.fetch(request).first {
                removeObvan(obvanToRemove, inContext: contextType)
            }
        }
    }
}

// MARK: - Club CRUD
extension DataManager {

    func fetchAllLocalClubs(inContext contextType: ContextType) -> [LocalClub] {
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        return context.performAndWait {
            return (try? context.fetch(request)) ?? []
        }
    }

    func createOrUpdateLocalClubWithClub(
        _ club: ClubDTO,
        inContext contextType: ContextType
    ) -> LocalClub {
        let context = contextFromType(contextType)
        let localClub = fetchOrCreateObject(
            ofType: LocalClub.self,
            predicate: NSPredicate(format: "id == %@", club.id),
            in: context
        ) {
            let newClub = LocalClub(context: context)
            newClub.id = club.id
            return newClub
        }
        updateLocalClub(localClub, withClub: club, inContext: contextType)
        return localClub
    }

    func updateLocalClub(
        _ localClub: LocalClub,
        withClub club: ClubDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localClub.title = club.title
            localClub.contacts = club.contacts
            localClub.urlString = club.urlString
            let image = self.fetchOrCreateObject(
                ofType: LocalImage.self,
                predicate: NSPredicate(format: "id == %@", club.id),
                in: context
            ) {
                let newImage = LocalImage(context: context)
                newImage.id = club.id
                return newImage
            }
            localClub.imageLogo = image
            if let locationId = club.homeLocationID {
                let location = self.fetchOrCreateObject(
                    ofType: LocalLocation.self,
                    predicate: NSPredicate(format: "id == %@", locationId),
                    in: context
                ) {
                    let newLocation = LocalLocation(context: context)
                    newLocation.id = locationId
                    return newLocation
                }
                localClub.homeLocation = location
                location.addToHomeClub(localClub)
            }
        }
    }

    func updateClubWith(
        id: String,
        title: String,
        uiimage: UIImage?,
        contacts: String,
        urlString: String,
        location: LocalLocation?,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
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
                                inContext: contextType
                            )
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
        club: LocalClub,
        title: String,
        uiimage: UIImage?,
        contacts: String,
        urlString: String,
        location: LocalLocation?,
        inContext contextType: ContextType
    ) async {
        let context = contextFromType(contextType)
        await context.perform { [weak self] in
            guard let self else { return }
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
                            inContext: contextType
                        )
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

    func removeClub(club: ClubDTO, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", club.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let clubToRemove = try? context.fetch(request).first {
                self.removeLocalClub(
                    localClub: clubToRemove,
                    inContext: contextType
                )
            }
        }
    }

    func removeLocalClub(
        localClub: LocalClub,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { [weak self] in
            guard let self else { return }
            if let localImage = localClub.imageLogo {
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(localClub)
        }
    }
}

// MARK: - Environment CRUD
extension DataManager {
    //camera
    func createOrUpdateCamera(
        _ camera: CameraDTO,
        inContext contextType: ContextType
    ) -> LocalCamera {
        let context = contextFromType(contextType)
        let localCamera = fetchOrCreateObject(
            ofType: LocalCamera.self,
            predicate: NSPredicate(format: "id == %@", camera.id),
            in: context
        ) {
            let newCamera = LocalCamera(context: context)
            newCamera.id = camera.id
            return newCamera
        }
        updateLocalCamera(
            localCamera,
            withCamera: camera,
            inContext: contextType
        )
        return localCamera
    }
    func updateLocalCamera(
        _ localCamera: LocalCamera,
        withCamera camera: CameraDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localCamera.optic = camera.optic.rawValue
        }
    }

    func linkLocalCamera(
        _ camera: LocalCamera,
        withPoint point: LocalLocationPoint,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            camera.point = point
            point.addToCameras(camera)
        }
    }

    func removeCamera(camera: CameraDTO, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalCamera.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", camera.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let cameraToRemove = try? context.fetch(request).first {
                self.removeLocalCamera(cameraToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalCamera(
        _ camera: LocalCamera,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { context.delete(camera) }
    }
    //sound
    func createOrUpdateSound(
        _ sound: SoundDTO,
        inContext contextType: ContextType
    ) -> LocalSound {
        let context = contextFromType(contextType)
        let localSound = fetchOrCreateObject(
            ofType: LocalSound.self,
            predicate: NSPredicate(format: "id == %@", sound.id),
            in: context
        ) {
            let newSound = LocalSound(context: context)
            newSound.id = sound.id
            return newSound
        }
        updateLocalSound(localSound, withSound: sound, inContext: contextType)
        return localSound
    }
    func updateLocalSound(
        _ localSound: LocalSound,
        withSound sound: SoundDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localSound.placeType = sound.placeType.rawValue
            localSound.windDefence = sound.windDefence.rawValue
        }
    }

    func linkLocalSound(
        _ sound: LocalSound,
        withPoint point: LocalLocationPoint,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            sound.point = point
            point.addToSounds(sound)
        }
    }

    func removeSound(sound: SoundDTO, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalSound.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", sound.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let soundToRemove = try? context.fetch(request).first {
                self.removeLocalSound(soundToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalSound(
        _ sound: LocalSound,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { context.delete(sound) }
    }
    //light
    func createOrUpdateLocalLightWithLight(
        _ light: LightDTO,
        inContext contextType: ContextType
    ) -> LocalLight {
        let context = contextFromType(contextType)
        let localLight = fetchOrCreateObject(
            ofType: LocalLight.self,
            predicate: NSPredicate(format: "id == %@", light.id),
            in: context
        ) {
            let newLight = LocalLight(context: context)
            newLight.id = light.id
            return newLight
        }
        updateLocalLight(localLight, withLight: light, inContext: contextType)
        return localLight
    }

    func updateLocalLight(
        _ localLight: LocalLight,
        withLight light: LightDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localLight.lightType = light.lightType.rawValue
        }
    }

    func linkLocalLight(
        _ light: LocalLight,
        WithPoint point: LocalLocationPoint,
        InContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            light.point = point
            point.addToLights(light)
        }
    }

    func removeLight(light: LightDTO, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalLight.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", light.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let lightToRemove = try? context.fetch(request).first {
                self.removeLocalLight(lightToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalLight(
        _ light: LocalLight,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { context.delete(light) }
    }

    //hardware
    func createOrUpdateLocalHardwareWithHardware(
        _ hardware: HardwareDTO,
        inContext contextType: ContextType
    ) -> LocalHardware {
        let context = contextFromType(contextType)
        let localHardware = fetchOrCreateObject(
            ofType: LocalHardware.self,
            predicate: NSPredicate(format: "id == %@", hardware.id),
            in: context
        ) {
            let newHardware = LocalHardware(context: context)
            newHardware.id = hardware.id
            return newHardware
        }
        updateLocalHardware(
            localHardware,
            withHardware: hardware,
            inContext: contextType
        )
        return localHardware
    }

    func updateLocalHardware(
        _ localHardware: LocalHardware,
        withHardware hardware: HardwareDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localHardware.type = hardware.envType.rawValue
            localHardware.channels = hardware.chanels.joined(separator: ",")
        }
    }

    func linkLocalHardware(
        _ hardware: LocalHardware,
        WithUnit unit: LocalUnit,
        InContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            hardware.obVanUnit = unit
            unit.hardware = hardware
        }
    }

    func removeHardware(
        _ hardware: HardwareDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        let request = LocalHardware.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hardware.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let hardwareToRemove = try? context.fetch(request).first {
                self.removeLocalHardware(
                    hardwareToRemove,
                    inContext: contextType
                )
            }
        }
    }

    func removeLocalHardware(
        _ localhardware: LocalHardware,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { context.delete(localhardware) }
    }
}

// MARK: - Location Points OBVan Units CRUD
extension DataManager {
    //location point
    func createOrUpdateLocalPointWithLocationPoint(
        _ point: PointDTO,
        inContext contextType: ContextType
    ) -> LocalLocationPoint {
        let context = contextFromType(contextType)
        let localPoint = fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: NSPredicate(format: "id == %@", point.id),
            in: context
        ) {
            let newLocationPoint = LocalLocationPoint(context: context)
            newLocationPoint.id = point.id
            return newLocationPoint
        }
        updateLocalPoint(
            localPoint,
            withLocationPoint: point,
            inContext: contextType
        )
        return localPoint

    }

    func updateLocalPoint(
        _ localPoint: LocalLocationPoint,
        withX x: Double,
        y: Double,
        rotation: Int,
        scaleFactor: Double,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localPoint.coordinateX = Float(x)
            localPoint.coordinateY = Float(y)
            localPoint.rotation = Int16(rotation)
            localPoint.scaleFactor = Float(scaleFactor)
        }

    }

    func updateLocalPoint(
        _ localPoint: LocalLocationPoint,
        withLocationPoint point: PointDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localPoint.coordinateX = Float(point.coordinateX)
            localPoint.coordinateY = Float(point.coordinateY)
            localPoint.rotation = Int16(point.rotation)
            localPoint.scaleFactor = Float(point.scale)
            localPoint.number = Int16(point.number)

            let image = self.fetchOrCreateObject(
                ofType: LocalImage.self,
                predicate: NSPredicate(format: "id == %@", point.imageId),
                in: context
            ) {
                let newImage = LocalImage(context: context)
                newImage.id = point.imageId
                return newImage
            }
            localPoint.image = image
            image.addToLocationPoint(localPoint)

            localPoint.pointDescription = point.description
            localPoint.task = point.task

            for id in point.userId {
                let user = fetchOrCreateObject(
                    ofType: LocalUser.self,
                    predicate: NSPredicate(format: "id == %@", id),
                    in: context
                ) {
                    let newUser = LocalUser(context: context)
                    newUser.id = id
                    return newUser
                }

                localPoint.addToUser(user)
                user.addToLocationPoints(localPoint)
            }

            for sound in point.sounds {
                let localSound = createOrUpdateSound(
                    sound,
                    inContext: contextType
                )
                localPoint.addToSounds(localSound)
                localSound.point = localPoint
            }
            for cam in point.cameras {
                let camera = createOrUpdateCamera(cam, inContext: contextType)
                localPoint.addToCameras(camera)
                camera.point = localPoint

            }
            for light in point.lights {
                let localLight = createOrUpdateLocalLightWithLight(
                    light,
                    inContext: contextType
                )
                localPoint.addToLights(localLight)
                localLight.point = localPoint
            }
        }
    }

    func updateLocalPoint(
        _ localPoint: LocalLocationPoint,
        withTemplatePoint point: LocalTemplatePoint,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localPoint.coordinateX = point.coordinateX
            localPoint.coordinateY = point.coordinateY
            localPoint.rotation = point.rotation
            localPoint.scaleFactor = point.scaleFactor
            localPoint.number = point.number

            localPoint.pointDescription = point.pointDescription
            localPoint.task = point.task

            for sound in point.viewSounds {
                let localSound = createOrUpdateSound(
                    sound,
                    inContext: contextType
                )
                localPoint.addToSounds(localSound)
                localSound.point = localPoint
            }
            for cam in point.viewCameras {
                let camera = createOrUpdateCamera(cam, inContext: contextType)
                localPoint.addToCameras(camera)
                camera.point = localPoint

            }
            for light in point.viewLights {
                let localLight = createOrUpdateLocalLightWithLight(
                    light,
                    inContext: contextType
                )
                localPoint.addToLights(localLight)
                localLight.point = localPoint
            }
        }
    }

    func removeLocationPoint(
        _ point: PointDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", point.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let pointToRemove = try? context.fetch(request).first {
                self.removeLocalLocationPoint(
                    pointToRemove,
                    inContext: contextType
                )
            }
        }
    }

    func removeLocalLocationPoint(
        _ localPoint: LocalLocationPoint,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { [weak self] in
            guard let self else { return }
            for camera in localPoint.viewLocalCameras {
                self.removeLocalCamera(camera, inContext: contextType)
            }

            for sound in localPoint.viewLocalSounds {
                self.removeLocalSound(sound, inContext: contextType)
            }

            for light in localPoint.viewLocalLights {
                self.removeLocalLight(light, inContext: contextType)
            }
            if let loacImage = localPoint.image {
                self.removeLocalImage(loacImage, inContext: contextType)
            }
            context.delete(localPoint)
        }
    }
}
// MARK: - Units
extension DataManager {
    func createOrUpdateLocalObvanUnitWithObvanUnit(
        _ obvanUnit: UnitDTO,
        inContext contextType: ContextType
    ) -> LocalUnit {
        let context = contextFromType(contextType)
        let localUnit = fetchOrCreateObject(
            ofType: LocalUnit.self,
            predicate: NSPredicate(format: "id == %@", obvanUnit.id),
            in: context
        ) {
            let newLocalUnit = LocalUnit(context: context)
            newLocalUnit.id = obvanUnit.id
            return newLocalUnit
        }
        updateLocalUnit(localUnit, withUnit: obvanUnit, inContext: contextType)
        return localUnit

    }

    func createOrUpdateLocalObvanUnitWithUser(
        _ user: LocalUser,
        andPosition position: String,
        andHardware hardware: ReplayType?,
        inContext contextType: ContextType
    ) -> LocalUnit {
        let context = contextFromType(contextType)
        let localUnit = fetchOrCreateObject(
            ofType: LocalUnit.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: context
        ) {
            let newLocalUnit = LocalUnit(context: context)
            newLocalUnit.id = UUID().uuidString
            return newLocalUnit
        }
        updateLocalUnit(
            localUnit,
            withPosition: position,
            andUser: user,
            andHardware: hardware,
            inContext: contextType
        )
        return localUnit

    }

    func updateLocalUnit(
        _ localUnit: LocalUnit,
        withUnit unit: UnitDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localUnit.position = unit.position.rawValue
            localUnit.coordinateX = Float(unit.coordinateX)
            localUnit.coordinateY = Float(unit.coordinateY)
            localUnit.rotation = Int16(unit.rotation)
            let user = fetchOrCreateObject(
                ofType: LocalUser.self,
                predicate: NSPredicate(format: "id == %@", unit.userId),
                in: context
            ) {
                let newUser = LocalUser(context: context)
                newUser.id = unit.userId
                return newUser
            }

            localUnit.user = user
            user.addToObVanUnits(localUnit)

            for hardware in unit.hardwares {
                let hardware = fetchOrCreateObject(
                    ofType: LocalHardware.self,
                    predicate: NSPredicate(format: "id == %@", hardware.id),
                    in: context
                ) {
                    let newHardware = LocalHardware(context: context)
                    newHardware.id = hardware.id
                    return newHardware
                }
                localUnit.hardware = hardware
                hardware.obVanUnit = localUnit
            }
        }
    }

    func updateLocalUnit(
        _ localUnit: LocalUnit,
        withPosition position: String,
        andUser user: LocalUser,
        andHardware hardware: ReplayType?,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localUnit.position = position

            localUnit.user = user
            user.addToObVanUnits(localUnit)

            if let hardware {
                let localHardware = fetchOrCreateObject(
                    ofType: LocalHardware.self,
                    predicate: NSPredicate(
                        format: "id == %@",
                        UUID().uuidString
                    ),
                    in: context
                ) {
                    let newHardware = LocalHardware(context: context)
                    newHardware.id = UUID().uuidString
                    return newHardware
                }
                localHardware.type = hardware.rawValue
                localUnit.hardware = localHardware
                localHardware.obVanUnit = localUnit
            }
        }
    }

    @MainActor
    func removeObvanUnit(unit: UnitDTO, inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalUnit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", unit.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let unitToRemove = try? context.fetch(request).first {
                self.removeLocalObvanUnit(unitToRemove, inContext: contextType)
            }
        }
    }
    @MainActor
    func removeLocalObvanUnit(
        _ unit: LocalUnit,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.perform { [weak self] in
            guard let self else { return }
            if let hardware = unit.hardware {
                self.removeLocalHardware(hardware, inContext: contextType)
            }
            context.delete(unit)
        }
    }
}
// MARK: - Template / TemplatePoints
extension DataManager {
    //template
    func createOrUpdateLocalTemplateWithTemplate(
        _ template: TemplateDTO,
        inConext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        let localTemplate = fetchOrCreateObject(
            ofType: LocalTemplate.self,
            predicate: NSPredicate(format: "id == %@", template.id),
            in: context
        ) {
            let newTemplate = LocalTemplate(context: context)
            newTemplate.id = template.id
            return newTemplate
        }
        updateLocalTemplate(
            localTemplate,
            WithTemplate: template,
            inConext: contextType
        )
    }

    func updateLocalTemplate(
        _ localtemplate: LocalTemplate,
        WithTemplate template: TemplateDTO,
        inConext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localtemplate.id = template.id
            localtemplate.name = template.name
            localtemplate.removeFromTemplatePoints(
                localtemplate.templatePoints ?? []
            )
            for point in template.templatePoints {
                let localTemplatePoint =
                    createOrUpdateLocalTemplatePointWithTemplatePoint(
                        point,
                        inContext: contextType
                    )
                localtemplate.addToTemplatePoints(localTemplatePoint)
            }
        }
    }
    func removeLocalTemplate(
        _ template: LocalTemplate,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            for point in template.templatePoints as? Set<LocalTemplatePoint>
                ?? []
            {
                removeLocalTemplatePoint(point, inContext: contextType)
            }
            context.delete(template)
        }
    }

    //templatePoint
    func createOrUpdateLocalTemplatePointWithTemplatePoint(
        _ point: TemplatePointDTO,
        inContext contextType: ContextType
    ) -> LocalTemplatePoint {
        let context = contextFromType(contextType)
        let localPoint = fetchOrCreateObject(
            ofType: LocalTemplatePoint.self,
            predicate: NSPredicate(format: "id == %@", point.id),
            in: context
        ) {
            let newTemplatePoint = LocalTemplatePoint(context: context)
            newTemplatePoint.id = point.id
            return newTemplatePoint
        }
        updateLocalTemplatePoint(
            localPoint,
            withTemplatePoint: point,
            inContext: contextType
        )
        return localPoint
    }

    func updateLocalTemplatePoint(
        _ localPoint: LocalTemplatePoint,
        withTemplatePoint point: TemplatePointDTO,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localPoint.coordinateX = Float(point.coordinateX)
            localPoint.coordinateY = Float(point.coordinateY)
            localPoint.rotation = Int16(point.rotation)
            localPoint.scaleFactor = Float(point.scaleFactor)
            localPoint.number = Int16(point.number)
            localPoint.pointDescription = point.pointDescription
            localPoint.task = point.task
            localPoint.cameras = point.cameras.map { $0.optic.rawValue }.joined(
                separator: ","
            )
            localPoint.sounds = point.sounds.map { $0.placeType.rawValue }
                .joined(separator: ",")
            localPoint.lights = point.lights.map { $0.lightType.rawValue }
                .joined(separator: ",")
        }
    }
    func removeLocalTemplatePoint(
        _ point: LocalTemplatePoint,
        inContext contextType: ContextType
    ) {
        let context = contextFromType(contextType)
        context.delete(point)
    }
}

// MARK: - map TemplatePoint to LocalLocationPoint
extension DataManager {
    func createLocalLocationPointFromTemplatePoint(
        _ templatePoint: LocalTemplatePoint,
        inContext contextType: ContextType
    ) -> LocalLocationPoint {
        let context = contextFromType(contextType)
        let localLocationPoint = fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: context
        ) {
            let newLocationPoint = LocalLocationPoint(context: context)
            newLocationPoint.id = UUID().uuidString
            return newLocationPoint
        }
        context.performAndWait {
            localLocationPoint.coordinateX = templatePoint.coordinateX
            localLocationPoint.coordinateY = templatePoint.coordinateY
            localLocationPoint.rotation = templatePoint.rotation
            localLocationPoint.scaleFactor = templatePoint.scaleFactor
            localLocationPoint.pointDescription = templatePoint.pointDescription
            localLocationPoint.number = templatePoint.number
            localLocationPoint.task = templatePoint.task
            for camera in templatePoint.viewCameras {
                localLocationPoint.addToCameras(
                    createOrUpdateCamera(camera, inContext: contextType)
                )
            }
            for sound in templatePoint.viewSounds {
                localLocationPoint.addToSounds(
                    createOrUpdateSound(sound, inContext: contextType)
                )
            }
            for light in templatePoint.viewLights {
                localLocationPoint.addToLights(
                    createOrUpdateLocalLightWithLight(
                        light,
                        inContext: contextType
                    )
                )
            }
        }
        return localLocationPoint
    }

    func mapTemplateToLocationPoints(
        template: LocalTemplate,
        inContext contextType: ContextType
    ) -> [LocalLocationPoint] {

        var array = [LocalLocationPoint]()
        for point in template.viewPoints {
            array.append(
                createLocalLocationPointFromTemplatePoint(
                    point,
                    inContext: contextType
                )
            )
        }
        return array
    }

    func createTemplateWithLocalLocationPoints(
        _ points: [LocalLocationPoint],
        andName name: String,
        inContext contextType: ContextType
    ) -> LocalTemplate {
        let context = contextFromType(contextType)
        let template = fetchOrCreateObject(
            ofType: LocalTemplate.self,
            predicate: NSPredicate(format: "id == %@", name),
            in: context
        ) {
            let newTemplate = LocalTemplate(context: context)
            newTemplate.id = name
            return newTemplate
        }

        context.performAndWait { [weak self] in
            guard let self else { return }
            template.name = name
            for point in points {
                let localTemplatePoint =
                    createTemplatePointFromLocalLocationPoint(
                        point,
                        inContext: contextType
                    )
                //localLocaltionPoint -> LocalTemplatePoint
                template.addToTemplatePoints(localTemplatePoint)
                //                localTemplatePoint.parentTemplate = template
            }
        }
        return template
    }

    func createTemplatePointFromLocalLocationPoint(
        _ point: LocalLocationPoint,
        inContext contextType: ContextType
    ) -> LocalTemplatePoint {
        let context = contextFromType(contextType)
        let tp = fetchOrCreateObject(
            ofType: LocalTemplatePoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: context
        ) {
            let newTemplatePoint = LocalTemplatePoint(context: context)
            newTemplatePoint.id = UUID().uuidString
            return newTemplatePoint
        }
        context.performAndWait {
            tp.coordinateX = point.coordinateX
            tp.coordinateY = point.coordinateY
            tp.number = point.number
            tp.pointDescription = point.pointDescription
            tp.task = point.task
            tp.scaleFactor = point.scaleFactor
            tp.rotation = point.rotation
            tp.cameras = point.viewLocalCameras.map { $0.viewOptic.rawValue }
                .joined(separator: ",")
            tp.sounds = point.viewLocalSounds.map { $0.viewPlaceType.rawValue }
                .joined(separator: ",")
            tp.lights = point.viewLocalLights.map { $0.viewLightType.rawValue }
                .joined(separator: ",")
        }
        return tp
    }
}

// MARK: - Save context and publish changes to update ui
extension DataManager {
    func saveContext(
        type contextType: ContextType,
        publish: GlobalProperties.PublishChanges,
        id: [String]
    ) async {
        let context = contextFromType(contextType)
        await context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                    if publish != .none {
                        Task {
                            await MainActor.run {
                                self.updatePublisher.send((publish, id))
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
