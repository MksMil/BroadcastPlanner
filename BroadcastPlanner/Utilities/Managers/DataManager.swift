import Combine
import CoreData
import UIKit

enum ContextType { case main, bg }

class DataManager: ObservableObject {
    // MARK: - Properties
    //publishing (type of data & array of id's) of changed elements, for views updates if needed (like current user in session)
    var updatePublisher: PassthroughSubject = PassthroughSubject<
        (GlobalProperties.PublishChanges, [String]), Never>()
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

        persistentContainer.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent =
            true

        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
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
        initializer: (NSManagedObjectContext) -> T
    ) -> T {
        let request = T.fetchRequest()
        request.predicate = predicate
        if let result = try? context.fetch(request).first as? T {
            return result
        } else {
            return initializer(context)
        }
    }
}
// MARK: - User CRUD
extension DataManager {
    func createOrUpdateLocalUserWithUserDTO(_ user: UserDTO,
                                            inContext contextType: ContextType) -> LocalUser {
        let context = contextFromType(contextType)
        let localUser = fetchOrCreateObject(ofType: LocalUser.self,
                                            predicate: NSPredicate(format: "id == %@",
                                                                   user.id),
                                            in: context ) { ctx in
            let newUser = LocalUser(context: ctx)
            newUser.id = user.id
            return newUser
        }
        updateLocalUser(localUser, withUserDTO: user, inContext: contextType)
        return localUser
    }
    func updateLocalUser(_ localUser: LocalUser,
                         withUserDTO userDto: UserDTO,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localUser.id = userDto.id
            localUser.firstName = userDto.firstName
            localUser.lastName = userDto.lastName
            localUser.isOnline = userDto.isOnline
            localUser.phoneNumber = userDto.phoneNumber
            localUser.email = userDto.email
            localUser.homeAddress = userDto.homeAddress
            localUser.specializations = userDto.specialization.joined(
                separator: ",")
            localUser.creationDate = userDto.creationDate.dateValue()
            localUser.leaveDate = userDto.leaveDate.dateValue()
            let image = self.fetchOrCreateObject(ofType: LocalImage.self,
                                                 predicate: NSPredicate(format: "id == %@", userDto.id),
                                                 in: context) { ctx in
                let newImage = LocalImage(context: ctx)
                newImage.id = userDto.id
                return newImage
            }
            localUser.image = image
            image.parentUser = localUser
        }
    }
    func removeUserWithDTO(_ user: UserDTO,
                           inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id)
        if let userToRemove = try? context.fetch(request).first {
            self.removeLocalUser(userToRemove, inContext: contextType)
        } else {
            print("error removing local user with id = \(user.id)")
        }
    }
    func removeLocalUser(_ localUser: LocalUser,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        if let imageToRemove = localUser.image {
            self.removeLocalImage(imageToRemove, inContext: contextType)
        }
        context.performAndWait { context.delete(localUser) }
    }
    func fetchUsersAvailableToEvent(_ event: LocalEvent) -> [LocalUser] {
        let request = LocalUser.fetchRequest()
        do {
            let users = try moc.fetch(request)
            return users.filter { $0.isAvailableToEvent(event: event) }
        } catch {
            return []
        }
    }
}

// MARK: - Event CRUD
extension DataManager {
    func createOrUpdateLocalEventWithEventDTO(_ event: EventDTO,
                                              inContext contextType: ContextType) async -> LocalEvent {
        let context = contextFromType(contextType)
        let localEvent = fetchOrCreateObject(
            ofType: LocalEvent.self,
            predicate: NSPredicate(format: "id == %@", event.id),
            in: context) { ctx in
            let newEvent = LocalEvent(context: ctx)
            newEvent.id = event.id
            return newEvent
        }
        await updateLocalEvent(localEvent,
                               withDTO: event,
                               inContext: contextType)
        return localEvent
    }
    func updateLocalEvent( _ localEvent: LocalEvent,
                           withDTO eventDto: EventDTO,
                           inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        await context.perform {
            localEvent.date = eventDto.date
            localEvent.id = eventDto.id
        }
        if let obvanId = eventDto.obVanId {
            let obvan = self.fetchOrCreateObject(
                ofType: LocalObvan.self,
                predicate: NSPredicate(format: "id == %@", obvanId),
                in: context) { ctx in
                let newObvan = LocalObvan(context: ctx)
                newObvan.id = obvanId
                return newObvan
            }
            await context.perform {
                localEvent.obvan = obvan
                obvan.addToEvents(localEvent)
            }
        }
        if let locationID = eventDto.locationID {
            let location = self.fetchOrCreateObject(
                ofType: LocalLocation.self,
                predicate: NSPredicate(format: "id == %@", locationID),
                in: context
            ) { ctx in
                let newLocation = LocalLocation(context: ctx)
                newLocation.id = locationID
                return newLocation
            }
            await context.perform {
                localEvent.location = location
                location.addToEvents(localEvent)
            }
        }
        if let homeClubId = eventDto.homeClubId {
            let homeClub = self.fetchOrCreateObject(ofType: LocalClub.self,
                                                    predicate: NSPredicate(format: "id == %@", homeClubId),
                                                    in: context) { ctx in
                let newClub = LocalClub(context: ctx)
                newClub.id = homeClubId
                return newClub
            }
            await context.perform {
                localEvent.homeClub = homeClub
                homeClub.addToHomeEvent(localEvent)
            }
        }
        if let guestClubId = eventDto.guestClubId {
            let guestClub = self.fetchOrCreateObject(
                ofType: LocalClub.self,
                predicate: NSPredicate(format: "id == %@", guestClubId),
                in: context) { ctx in
                let newClub = LocalClub(context: ctx)
                newClub.id = guestClubId
                return newClub
            }
            await context.perform {
                localEvent.guestClub = guestClub
                guestClub.addToGuestEvent(localEvent)
            }
        }
        if let locationPreviewId = eventDto.locationPreviewId {
            let localImage = self.fetchOrCreateObject(ofType: LocalImage.self,
                                                      predicate: NSPredicate(
                                                        format: "id == %@",
                                                        locationPreviewId
                                                      ),
                                                      in: context) { ctx in
                let newImage = LocalImage(context: ctx)
                newImage.id = locationPreviewId
                return newImage
            }
            await context.perform {
                localEvent.locationPreview = localImage
                localImage.parentLocationPreviewEvent = localEvent
            }
        }
        if let obvanPreviewId = eventDto.obvanPreviewId {
            let localImage = self.fetchOrCreateObject(ofType: LocalImage.self,
                predicate: NSPredicate(format: "id == %@", obvanPreviewId),
                in: context) { ctx in
                let newImage = LocalImage(context: ctx)
                newImage.id = obvanPreviewId
                return newImage
            }
            await context.perform {
                localEvent.obvanPreview = localImage
                localImage.parentObvanPreviewEvent = localEvent
            }
        }
        for ownerId in eventDto.ownersIds {
            let user = self.fetchOrCreateObject(ofType: LocalUser.self,
                predicate: NSPredicate(format: "id == %@", ownerId),
                in: context) { ctx in
                let newUser = LocalUser(context: ctx)
                newUser.id = ownerId
                return newUser
            }
            await context.perform {
                localEvent.addToOwners(user)
                user.addToOwnedEvents(localEvent)
            }
        }
        for user in eventDto.usersIds {
            let user = self.fetchOrCreateObject(ofType: LocalUser.self,
                predicate: NSPredicate(format: "id == %@", user),
                in: context) { ctx in
                let newUser = LocalUser(context: ctx)
                newUser.id = user
                return newUser
            }
            await context.perform {
                user.addToParticipateEvents(localEvent)
                localEvent.addToUsers(user)
            }
        }
        for locationPoint in eventDto.locationPoints {
            let point = self.createOrUpdateLocalPointWithPointDTO(
                locationPoint,
                inContext: contextType
            )
            await context.perform {
                localEvent.addToPoints(point)
                point.event = localEvent
            }

        }
        for unit in eventDto.obVanUnits {
            let localUnit = self.createOrUpdateLocalUnitWithUnitDTO(unit,
                                                                    inContext: contextType)
            await context.perform {
                localEvent.addToUnits(localUnit)
                localUnit.event = localEvent
            }
        }
    }
    //    @MainActor
    func removeEventWithDTO(_ event: EventDTO,
                            inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id)
        if let eventToRemove = try? context.fetch(request).first {
            await self.removeLocalEvent(eventToRemove,
                                        inContext: contextType)
        } else {
            print("error removing event with id = \(event.id)")
        }
    }
    @MainActor
    func removeLocalEvent(_ localEvent: LocalEvent,
                          inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        await withTaskGroup { group in
            for locationPoint in localEvent.viewLocationPoints {
                group.addTask { [weak self] in
                    guard let self else { return }
                    self.removeLocalLocationPoint(locationPoint,
                                                  inContext: contextType)
                }
            }
            for unit in localEvent.viewObvanUnits {
                group.addTask { [weak self] in
                    guard let self else { return }
                    await self.removeLocalUnit(unit, inContext: contextType)
                }
            }
            if let eventPreview = localEvent.locationPreview {
                group.addTask { [weak self] in
                    guard let self else { return }
                    self.removeLocalImage(eventPreview,
                                          inContext: contextType)
                }
            }
            if let obvanPreview = localEvent.obvanPreview {
                group.addTask { [weak self] in
                    guard let self else { return }
                    self.removeLocalImage(obvanPreview,
                                          inContext: contextType)
                }
            }
        }
        await context.perform {
            context.delete(localEvent)
        }
    }
}
// MARK: - Image CRUD
extension DataManager {
    func fetchImagesByType(_ type: GlobalProperties.ImageType,
                           inContext contextType: ContextType) async -> [LocalImage] {
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        let context = contextFromType(contextType)
        return await context.perform {
            return (try? context.fetch(request)) ?? []
        }
    }

    func createOrUpdateLocalImageWithId(_ id: String,
                                        withImage image: UIImage,
                                        andType type: GlobalProperties.ImageType,
                                        inContext contextType: ContextType) -> LocalImage {
        let context = contextFromType(contextType)
        let localImage = fetchOrCreateObject(ofType: LocalImage.self,
                                             predicate: NSPredicate(format: "id == %@", id),
                                             in: context) { ctx in
            let newImage = LocalImage(context: ctx)
            newImage.id = id
            return newImage
        }
        let _ = ImagesManager.saveResizedImages(image: image,
                                                id: id,
                                                type: type)
        context.performAndWait {
            localImage.type = type.rawValue
        }
        return localImage
    }
    func createOrUpdateLocalImageWithImageData(imageDTO: ImageDTO,
                                               withImage image: UIImage,
                                               inContext contextType: ContextType) async -> LocalImage {
        let context = contextFromType(contextType)
        let localImage = fetchOrCreateObject(ofType: LocalImage.self,
                                             predicate: NSPredicate(format: "id == %@", imageDTO.id),
                                             in: context) { ctx in
            let newImage = LocalImage(context: ctx)
            newImage.id = imageDTO.id
            return newImage
        }
        let type =
            GlobalProperties.ImageType.init(rawValue: imageDTO.type) ?? .none
        await context.perform {
            localImage.type = type.rawValue
        }
        let _ = await ImagesManager.saveResizedImagesAsync(image: image,
                                                           id: imageDTO.id,
                                                           type: type)
        return localImage
    }

    func assignType(type: String,
                    toLocalImage image: LocalImage,
                    inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { image.type = type }
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

    func removeLocalImage(_ localImage: LocalImage,
                          inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let _ = ImagesManager.removeImageFromDevice(withId: localImage.viewId)
        context.performAndWait {
            context.delete(localImage)
        }
    }
}

// MARK: - Location CRUD
extension DataManager {
    func createOrUpdateLocalLocationWithLocationDTO(_ location: LocationDTO,
                                                    inContext contextType: ContextType) async -> LocalLocation {
        let context = contextFromType(contextType)
        let localLocation = fetchOrCreateObject(ofType: LocalLocation.self,
                                                predicate: NSPredicate(format: "id == %@", location.id),
                                                in: context) { ctx in
            let newLocation = LocalLocation(context: ctx)
            newLocation.id = location.id
            return newLocation
        }
        await updateLocalLocation(localLocation,
                                  withDTO: location,
                                  inContext: contextType)
        return localLocation
    }

    func cleanImagesInLocalLocation(_ localLocation: LocalLocation,
                                    andBackground isBg: Bool,
                                    inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        let imagesToRemove = localLocation.viewLocalImages
        await withTaskGroup { group in
            for image in imagesToRemove {
                group.addTask { [weak self] in
                    guard let self else { return }
                    await context.perform {
                        localLocation.removeFromImages(image)
                        self.removeLocalImage(image, inContext: contextType)
                    }
                }
            }
            if isBg {
                group.addTask {
                    await context.perform {
                        localLocation.background = nil
                    }
                }
            }
        }
    }

    func updateLocalLocation(_ localLocation: LocalLocation,
                             withDTO location: LocationDTO,
                             inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        //clean images
        await cleanImagesInLocalLocation(localLocation,
                                         andBackground: true,
                                         inContext: contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localLocation.title = location.title
            localLocation.address = location.address
            for id in location.imagesIds {
                let image = self.fetchOrCreateObject(ofType: LocalImage.self,
                                                     predicate: NSPredicate(format: "id == %@", id),
                                                     in: context) { ctx in
                    let newImage = LocalImage(context: ctx)
                    newImage.id = id
                    return newImage
                }
                localLocation.addToImages(image)
                image.parentLocationImage = localLocation
            }
            if let imageId = location.locationBackgroundId {
                let backgroundImage = self.fetchOrCreateObject(ofType: LocalImage.self,
                                                               predicate: NSPredicate(format: "id == %@", imageId),
                                                               in: context) { ctx in
                    let newImage = LocalImage(context: ctx)
                    newImage.id = imageId
                    return newImage
                }
                localLocation.background = backgroundImage
                backgroundImage.parentLocationBackground = localLocation
            }
        }
    }

    func updateLocalLocation(_ location: LocalLocation,
                             withTitle title: String,
                             address: String,
                             localImages: [UIImage],
                             locationBackground: LocalImage?) async {
        //clean images
        await cleanImagesInLocalLocation(location,
                                         andBackground: true,
                                         inContext: .main)
        var newLocalImages: [LocalImage] = []
        for image in localImages {
            let newImage = await createOrUpdateLocalImageWithImageData(
                imageDTO: ImageDTO(id: UUID().uuidString,
                                   type: GlobalProperties.ImageType.location.rawValue),
                withImage: image,
                inContext: .main)
            newLocalImages.append(newImage)
        }
        await moc.perform {
            location.title = title
            location.address = address
            for newImage in newLocalImages {
                location.addToImages(newImage)
                newImage.parentLocationImage = location
            }
            if let locationBackground = locationBackground {
                location.background = locationBackground
                locationBackground.parentLocationBackground = location
            }
        }
        await saveContext(type: .main,
                          publish: .locations,
                          id: [])
    }

    func removeLocalLocation(_ location: LocalLocation,
                             inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        await cleanImagesInLocalLocation(location,
                                         andBackground: false,
                                         inContext: contextType)
        await context.perform { context.delete(location) }
    }
}

// MARK: - obvan CRUD
extension DataManager {
    func createOrUpdateLocalObvanWithDTO(_ obvanDTO: ObvanDTO,
                                         inContext contextType: ContextType) async -> LocalObvan {
        let context = contextFromType(contextType)
        let localObvan = fetchOrCreateObject(ofType: LocalObvan.self,
                                             predicate: NSPredicate(format: "id == %@", obvanDTO.id),
                                             in: context) { ctx in
            let newObvan = LocalObvan(context: ctx)
            newObvan.id = obvanDTO.id
            return newObvan
        }
        await updateLocalObvan(localObvan,
                               withObvan: obvanDTO,
                               inContext: contextType)
        return localObvan
    }

    func updateLocalObvan(_ localObvan: LocalObvan,
                          withObvan obvan: ObvanDTO,
                          inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        await context.perform { [weak self] in
            guard let self else { return }
            localObvan.id = obvan.id
            localObvan.name = obvan.name
            localObvan.broadcaster = obvan.broadcaster
            let image = self.fetchOrCreateObject(ofType: LocalImage.self,
                                                 predicate: NSPredicate(format: "id == %@", obvan.imageId),
                                                 in: context) { ctx in
                let newImage = LocalImage(context: ctx)
                newImage.id = obvan.imageId
                return newImage
            }
            assignType(type: GlobalProperties.ImageType.obvan.rawValue,
                       toLocalImage: image,
                       inContext: contextType)
            localObvan.image = image
            image.parentObvan = localObvan
        }
    }
    //from local user
    func removeObvan(_ obvan: LocalObvan, inContext contextType: ContextType) async{
        let context = contextFromType(contextType)
        await context.perform { [weak self] in
            guard let self else { return }
            if let localImage = obvan.image {
                self.removeLocalImage(localImage, inContext: contextType)
            }
            context.delete(obvan)
        }
    }
    //another local version
    func removeObvanWithId(_ id: String,
                           inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        let request = LocalObvan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let obvanToRemove = try? context.fetch(request).first {
            await removeObvan(obvanToRemove, inContext: contextType)
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

    func createOrUpdateLocalClubWithDTO(_ club: ClubDTO,
                                        inContext contextType: ContextType) async -> LocalClub {
        let context = contextFromType(contextType)
        let localClub = fetchOrCreateObject(ofType: LocalClub.self,
                                            predicate: NSPredicate(format: "id == %@", club.id),
                                            in: context) { ctx in
            let newClub = LocalClub(context: ctx)
            newClub.id = club.id
            return newClub
        }
        await updateLocalClub(localClub, withDTO: club, inContext: contextType)
        return localClub
    }

    func updateLocalClub(_ localClub: LocalClub,
                         withDTO club: ClubDTO,
                         inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        let imageId = club.imageLogoID ?? UUID().uuidString
        await context.perform { [weak self] in
            guard let self else { return }
            localClub.title = club.title
            localClub.contacts = club.contacts
            localClub.urlString = club.urlString
            let image = self.fetchOrCreateObject(ofType: LocalImage.self,
                                                 predicate: NSPredicate(format: "id == %@", imageId),
                                                 in: context) { ctx in
                let newImage = LocalImage(context: ctx)
                newImage.id = imageId
                return newImage
            }
            localClub.imageLogo = image
            if let locationId = club.homeLocationID {
                let location = self.fetchOrCreateObject(ofType: LocalLocation.self,
                                                        predicate: NSPredicate(format: "id == %@", locationId),
                                                        in: context) { ctx in
                    let newLocation = LocalLocation(context: ctx)
                    newLocation.id = locationId
                    return newLocation
                }
                localClub.homeLocation = location
                location.addToHomeClub(localClub)
            }
        }
    }

    func updateClubWith(id: String,
                        title: String,
                        uiimage: UIImage?,
                        contacts: String,
                        urlString: String,
                        location: LocalLocation?,
                        inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let club = try? context.fetch(request).first {
            await updateClubWithClub(club: club,
                                     title: title,
                                     uiimage: uiimage,
                                     contacts: contacts,
                                     urlString: urlString,
                                     location: location,
                                     inContext: contextType)
        }
    }
    func updateClubWithClub(club: LocalClub,
                            title: String,
                            uiimage: UIImage?,
                            contacts: String,
                            urlString: String,
                            location: LocalLocation?,
                            inContext contextType: ContextType) async {
        let context = contextFromType(contextType)
        await context.perform { [weak self] in
            guard let self else { return }
            club.title = title
            if let uiimage {
                if let localImage = club.imageLogo {
                    localImage.uploadImage(uiimage: uiimage)
                } else {
                    let localImage = self.createOrUpdateLocalImageWithId(UUID().uuidString,
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

    func removeClubWithDTO(_ clubDTO: ClubDTO,
                           inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", clubDTO.id)
        context.perform { [weak self] in
            guard let self else { return }
            if let clubToRemove = try? context.fetch(request).first {
                self.removeLocalClub(localClub: clubToRemove,
                                     inContext: contextType)
            }
        }
    }

    func removeLocalClub(localClub: LocalClub,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
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
    func createOrUpdateCamera(_ camera: CameraDTO,
                              inContext contextType: ContextType) -> LocalCamera {
        let context = contextFromType(contextType)
        var localCamera: LocalCamera!
        context.performAndWait {
            localCamera = fetchOrCreateObject(ofType: LocalCamera.self,
                                              predicate: NSPredicate(format: "id == %@", camera.id),
                                              in: context) { ctx in
                let newCamera = LocalCamera(context: ctx)
                newCamera.id = camera.id
                return newCamera
            }
            localCamera.optic = camera.optic.rawValue
        }
        return localCamera
    }
    func linkLocalCamera(_ camera: LocalCamera,
                         withPoint point: LocalLocationPoint,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            camera.point = point
            point.addToCameras(camera)
        }
    }

    func removeCameraWithDTO(_ cameraDTO: CameraDTO,
                             inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalCamera.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", cameraDTO.id)
        context.perform {
            if let cameraToRemove = try? context.fetch(request).first {
                self.removeLocalCamera(cameraToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalCamera(_ camera: LocalCamera,
                           inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { context.delete(camera) }
    }

    //sound
    func createOrUpdateSound(_ sound: SoundDTO,
                             inContext contextType: ContextType) -> LocalSound {
        let context = contextFromType(contextType)
        var localSound: LocalSound!
        context.performAndWait {
            localSound = fetchOrCreateObject(ofType: LocalSound.self,
                                             predicate: NSPredicate(format: "id == %@", sound.id),
                                             in: context) { ctx in
                let newSound = LocalSound(context: ctx)
                newSound.id = sound.id
                return newSound
            }
            localSound.placeType = sound.placeType.rawValue
            localSound.windDefence = sound.windDefence.rawValue
        }
        return localSound
    }

    func linkLocalSound(_ sound: LocalSound,
                        withPoint point: LocalLocationPoint,
                        inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            sound.point = point
            point.addToSounds(sound)
        }
    }

    func removeSoundWithDTO(_ sound: SoundDTO,
                            inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalSound.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", sound.id)
        context.performAndWait { [weak self] in
            guard let self else { return }
            if let soundToRemove = try? context.fetch(request).first {
                self.removeLocalSound(soundToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalSound(_ sound: LocalSound,
                          inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { context.delete(sound) }
    }
    //light
    func createOrUpdateLight(_ light: LightDTO,
                             inContext contextType: ContextType) -> LocalLight {
        let context = contextFromType(contextType)
        var localLight: LocalLight!
        context.performAndWait {
            localLight = fetchOrCreateObject(ofType: LocalLight.self,
                                             predicate: NSPredicate(format: "id == %@", light.id),
                                             in: context) { ctx in
                let newLight = LocalLight(context: ctx)
                newLight.id = light.id
                return newLight
            }
            localLight.lightType = light.lightType.rawValue
        }
        return localLight
    }

    func linkLocalLight(_ light: LocalLight,
                        WithPoint point: LocalLocationPoint,
                        InContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            light.point = point
            point.addToLights(light)
        }
    }

    func removeLightWithDTO(_ light: LightDTO,
                            inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalLight.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", light.id)
        context.performAndWait { [weak self] in
            guard let self else { return }
            if let lightToRemove = try? context.fetch(request).first {
                self.removeLocalLight(lightToRemove, inContext: contextType)
            }
        }
    }

    func removeLocalLight(_ light: LocalLight,
                          inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { context.delete(light) }
    }

    //hardware
    func createOrUpdateHardwareWithDTO(_ hardwareDTO: HardwareDTO,
                                       inContext contextType: ContextType) -> LocalHardware {
        let context = contextFromType(contextType)
        var localHardware: LocalHardware!
        context.performAndWait {
            localHardware = fetchOrCreateObject(ofType: LocalHardware.self,
                                                predicate: NSPredicate(format: "id == %@", hardwareDTO.id),
                                                in: context) { ctx in
                let newHardware = LocalHardware(context: ctx)
                newHardware.id = hardwareDTO.id
                return newHardware
            }
            localHardware.type = hardwareDTO.envType.rawValue
            localHardware.channels = hardwareDTO.chanels.joined(separator: ",")
        }
        return localHardware
    }
    func linkLocalHardware(_ hardware: LocalHardware,
                           withUnit unit: LocalUnit,
                           inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            hardware.obVanUnit = unit
            unit.hardware = hardware
        }
    }

    func removeHardwareWithDTO(_ hardware: HardwareDTO,
                               inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalHardware.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hardware.id)
        if let hardwareToRemove = try? context.fetch(request).first {
            self.removeLocalHardware(hardwareToRemove,
                                     inContext: contextType)
        }
    }

    func removeLocalHardware(_ localhardware: LocalHardware,
                             inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { context.delete(localhardware) }
    }
}

// MARK: - Location Points CRUD
extension DataManager {
    //location point
    func createOrUpdateLocalPointWithPointDTO(_ point: PointDTO,
                                              inContext contextType: ContextType) -> LocalLocationPoint {
        let context = contextFromType(contextType)
        let localPoint = fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: NSPredicate(format: "id == %@", point.id),
            in: context) { ctx in
            let newLocationPoint = LocalLocationPoint(context: ctx)
            newLocationPoint.id = point.id
            return newLocationPoint
        }
        updateLocalPoint(localPoint,
                         withPointDTO: point,
                         inContext: contextType)
        return localPoint
    }

    func updateLocalPoint(_ localPoint: LocalLocationPoint,
                          withPointDTO point: PointDTO,
                          inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localPoint.coordinateX = Float(point.coordinateX)
            localPoint.coordinateY = Float(point.coordinateY)
            localPoint.rotation = Int16(point.rotation)
            localPoint.scaleFactor = Float(point.scale)
            localPoint.number = Int16(point.number)
            let image = self.fetchOrCreateObject(
                ofType: LocalImage.self,
                predicate: NSPredicate(format: "id == %@", point.imageId),
                in: context) { ctx in
                let newImage = LocalImage(context: ctx)
                newImage.id = point.imageId
                return newImage
            }
            localPoint.image = image
            image.addToLocationPoint(localPoint)
            localPoint.pointDescription = point.description
            localPoint.task = point.task
            for user in localPoint.viewUsers {
                localPoint.removeFromUser(user)
            }
            for id in point.userId {
                let user = fetchOrCreateObject(
                    ofType: LocalUser.self,
                    predicate: NSPredicate(format: "id == %@", id),
                    in: context
                ) { ctx in
                    let newUser = LocalUser(context: ctx)
                    newUser.id = id
                    return newUser }
                localPoint.addToUser(user)
                user.addToLocationPoints(localPoint)
            }
            for cam in localPoint.viewLocalCameras {
                localPoint.removeFromCameras(cam)
                removeLocalCamera(cam, inContext: contextType)
            }
            for cam in point.cameras {
                let camera = createOrUpdateCamera(cam, inContext: contextType)
                localPoint.addToCameras(camera)
                camera.point = localPoint
            }
            for sound in localPoint.viewLocalSounds {
                localPoint.removeFromSounds(sound)
                removeLocalSound(sound, inContext: contextType)
            }
            for sound in point.sounds {
                let localSound = createOrUpdateSound(
                    sound,
                    inContext: contextType
                )
                localPoint.addToSounds(localSound)
                localSound.point = localPoint
            }
            for light in localPoint.viewLocalLights {
                localPoint.removeFromLights(light)
                removeLocalLight(light, inContext: contextType)
            }
            for light in point.lights {
                let localLight = createOrUpdateLight(
                    light,
                    inContext: contextType
                )
                localPoint.addToLights(localLight)
                localLight.point = localPoint
            }
        }
    }

    func updateLocalPoint(_ localPoint: LocalLocationPoint,
                          withX x: Double,
                          y: Double,
                          rotation: Int,
                          scaleFactor: Double,
                          inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localPoint.coordinateX = Float(x)
            localPoint.coordinateY = Float(y)
            localPoint.rotation = Int16(rotation)
            localPoint.scaleFactor = Float(scaleFactor)
        }
    }
    func updateLocalPoint(_ localPoint: LocalLocationPoint,
                          withTemplatePoint point: LocalTemplatePoint,
                          inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localPoint.coordinateX = point.coordinateX
            localPoint.coordinateY = point.coordinateY
            localPoint.rotation = point.rotation
            localPoint.scaleFactor = point.scaleFactor
            localPoint.number = point.number
            localPoint.pointDescription = point.pointDescription
            localPoint.task = point.task
            for sound in localPoint.viewLocalSounds {
                localPoint.removeFromSounds(sound)
                removeLocalSound(sound, inContext: contextType)
            }
            for sound in point.viewSounds {
                let localSound = createOrUpdateSound(sound,
                                                     inContext: contextType)
                localPoint.addToSounds(localSound)
                localSound.point = localPoint
            }
            for cam in localPoint.viewLocalCameras {
                localPoint.removeFromCameras(cam)
                removeLocalCamera(cam, inContext: contextType)
            }
            for cam in point.viewCameras {
                let camera = createOrUpdateCamera(cam, inContext: contextType)
                localPoint.addToCameras(camera)
                camera.point = localPoint
            }
            for light in localPoint.viewLocalLights {
                localPoint.removeFromLights(light)
                removeLocalLight(light, inContext: contextType)
            }
            for light in point.viewLights {
                let localLight = createOrUpdateLight(light,
                                                     inContext: contextType)
                localPoint.addToLights(localLight)
                localLight.point = localPoint
            }
        }
    }

    func removeLocationPoint(_ point: PointDTO,
                             inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", point.id)
        context.performAndWait {
            if let pointToRemove = try? context.fetch(request).first {
                self.removeLocalLocationPoint(pointToRemove,
                                              inContext: contextType)
            }
        }
    }

    func removeLocalLocationPoint(_ localPoint: LocalLocationPoint,
                                  inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
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
    func createOrUpdateLocalUnitWithUnitDTO(_ obvanUnit: UnitDTO,
                                            inContext contextType: ContextType) -> LocalUnit {
        let context = contextFromType(contextType)
        let localUnit = fetchOrCreateObject(
            ofType: LocalUnit.self,
            predicate: NSPredicate(format: "id == %@", obvanUnit.id),
            in: context
        ) { ctx in
            let newLocalUnit = LocalUnit(context: ctx)
            newLocalUnit.id = obvanUnit.id
            return newLocalUnit
        }
        updateLocalUnit(localUnit, withUnit: obvanUnit, inContext: contextType)
        return localUnit
    }

    func createUnitWithUser(_ user: LocalUser,
                            andPosition position: UserSpecialization,
                            andHardware hardware: ReplayType?,
                            inContext contextType: ContextType) -> LocalUnit {
        let context = contextFromType(contextType)
        let localUnit = LocalUnit(context: context)
        localUnit.id = UUID().uuidString
        updateLocalUnit(localUnit,
                        withPosition: position,
                        andUser: user,
                        andHardware: hardware,
                        inContext: contextType)
        return localUnit
    }

    func updateLocalUnit(_ localUnit: LocalUnit,
                         withUnit unit: UnitDTO,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localUnit.position = unit.position.rawValue
            localUnit.coordinateX = Float(unit.coordinateX)
            localUnit.coordinateY = Float(unit.coordinateY)
            localUnit.rotation = Int16(unit.rotation)
            localUnit.scaleFactor = Float(unit.scale)
            localUnit.task = unit.task
            let user = fetchOrCreateObject(
                ofType: LocalUser.self,
                predicate: NSPredicate(format: "id == %@", unit.userId),
                in: context
            ) { ctx in
                let newUser = LocalUser(context: ctx)
                newUser.id = unit.userId
                return newUser
            }
            localUnit.user = user
            user.addToObVanUnits(localUnit)
            let hardwareId = unit.hardware?.id ?? UUID().uuidString
            let hardware = fetchOrCreateObject(
                ofType: LocalHardware.self,
                predicate: NSPredicate(format: "id == %@", hardwareId),
                in: context
            ) { ctx in
                let newHardware = LocalHardware(context: ctx)
                newHardware.id = hardwareId
                return newHardware
            }
            localUnit.hardware = hardware
            hardware.obVanUnit = localUnit
        }
    }

    func updateLocalUnit(_ localUnit: LocalUnit,
                         withPosition position: UserSpecialization,
                         andUser user: LocalUser,
                         andHardware hardware: ReplayType?,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            localUnit.position = position.rawValue
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
                ) { ctx in
                    let newHardware = LocalHardware(context: ctx)
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
    func removeLocalUnitUsingUnitDTO(_ unit: UnitDTO,
                                     inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        let request = LocalUnit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", unit.id)
        if let unitToRemove = try? context.fetch(request).first {
            self.removeLocalUnit(unitToRemove, inContext: contextType)
        }
    }
    @MainActor
    func removeLocalUnit(_ unit: LocalUnit,
                         inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        if let hardware = unit.hardware {
            self.removeLocalHardware(hardware, inContext: contextType)
        }
        context.performAndWait { context.delete(unit) }
    }
}
// MARK: - Template / TemplatePoints
extension DataManager {
    //template
    func createOrUpdateLocalTemplateWithTemplateDTO(_ template: TemplateDTO,
                                                    inConext contextType: ContextType) -> LocalTemplate {
        let context = contextFromType(contextType)
        let localTemplate = fetchOrCreateObject(
            ofType: LocalTemplate.self,
            predicate: NSPredicate(format: "id == %@", template.id),
            in: context
        ) { ctx in
            let newTemplate = LocalTemplate(context: ctx)
            newTemplate.id = template.id
            return newTemplate
        }
        updateLocalTemplate(localTemplate,
                            withTemplateDTO: template,
                            inConext: contextType)
        return localTemplate
    }

    func updateLocalTemplate(_ localtemplate: LocalTemplate,
                             withTemplateDTO template: TemplateDTO,
                             inConext contextType: ContextType) {
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
                    createOrUpdateLocalTemplatePointWithTemplatePoint(point,
                                                                      inContext: contextType)
                localtemplate.addToTemplatePoints(localTemplatePoint)
            }
        }
    }
    func removeLocalTemplate(_ template: LocalTemplate,
                             inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { [weak self] in
            guard let self else { return }
            for point in template.templatePoints as? Set<LocalTemplatePoint> ?? [] {
                removeLocalTemplatePoint(point, inContext: contextType)
            }
            context.delete(template)
        }
    }

    //templatePoint
    func createOrUpdateLocalTemplatePointWithTemplatePoint(_ point: TemplatePointDTO,
                                                           inContext contextType: ContextType) -> LocalTemplatePoint {
        let context = contextFromType(contextType)
        let localPoint = fetchOrCreateObject(
            ofType: LocalTemplatePoint.self,
            predicate: NSPredicate(format: "id == %@", point.id),
            in: context
        ) { ctx in
            let newTemplatePoint = LocalTemplatePoint(context: ctx)
            newTemplatePoint.id = point.id
            return newTemplatePoint
        }
        updateLocalTemplatePoint(localPoint,
                                 withTemplatePoint: point,
                                 inContext: contextType)
        return localPoint
    }
    func updateLocalTemplatePoint(_ localPoint: LocalTemplatePoint,
                                  withTemplatePoint point: TemplatePointDTO,
                                  inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait {
            localPoint.coordinateX = Float(point.coordinateX)
            localPoint.coordinateY = Float(point.coordinateY)
            localPoint.rotation = Int16(point.rotation)
            localPoint.scaleFactor = Float(point.scaleFactor)
            localPoint.number = Int16(point.number)
            localPoint.pointDescription = point.pointDescription
            localPoint.task = point.task
            localPoint.cameras = point.cameras.map({ $0.optic.rawValue }).joined(separator: ",")
            localPoint.sounds = point.sounds.map({ $0.placeType.rawValue }).joined(separator: ",")
            localPoint.lights = point.lights.map({ $0.lightType.rawValue }).joined(separator: ",")
        }
    }
    func removeLocalTemplatePoint(_ point: LocalTemplatePoint,
                                  inContext contextType: ContextType) {
        let context = contextFromType(contextType)
        context.performAndWait { context.delete(point) }
    }
}

// MARK: - map TemplatePoint to LocalLocationPoint
extension DataManager {
    // id for point must be unique for every event
    func createLocalLocationPointFromTemplatePoint(_ templatePoint: LocalTemplatePoint,
                                                   inContext contextType: ContextType) -> LocalLocationPoint {
        let context = contextFromType(contextType)
        let localLocationPoint = fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: context
        ) { ctx in
            let newLocationPoint = LocalLocationPoint(context: ctx)
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
            if localLocationPoint.viewLocalCameras.count > 0 {
                localLocationPoint.viewLocalCameras.forEach {
                    localLocationPoint.removeFromCameras($0)
                }
            }
            for camera in templatePoint.viewCameras {
                localLocationPoint.addToCameras(
                    createOrUpdateCamera(camera, inContext: contextType)
                )
            }
            if localLocationPoint.viewLocalSounds.count > 0 {
                localLocationPoint.viewLocalSounds.forEach {
                    localLocationPoint.removeFromSounds($0)
                }
            }
            for sound in templatePoint.viewSounds {
                localLocationPoint.addToSounds(
                    createOrUpdateSound(sound, inContext: contextType)
                )
            }
            if localLocationPoint.viewLocalLights.count > 0 {
                localLocationPoint.viewLocalLights.forEach {
                    localLocationPoint.removeFromLights($0)
                }
            }
            for light in templatePoint.viewLights {
                localLocationPoint.addToLights(
                    createOrUpdateLight(light,
                                        inContext: contextType)
                )
            }
        }
        return localLocationPoint
    }

    func mapTemplateToLocationPoints(template: LocalTemplate,
                                     inContext contextType: ContextType) -> [LocalLocationPoint] {
        var array = [LocalLocationPoint]()
        for point in template.viewPoints {
            array.append(self.createLocalLocationPointFromTemplatePoint(point,
                                                                        inContext: contextType)
            )
        }
        return array
    }

    func createTemplateWithLocalLocationPoints(_ points: [LocalLocationPoint],
                                               andName name: String,
                                               inContext contextType: ContextType) async -> LocalTemplate {
        let context = contextFromType(contextType)
        let template = fetchOrCreateObject(
            ofType: LocalTemplate.self,
            predicate: NSPredicate(format: "id == %@", name),
            in: context
        ) { ctx in
            let newTemplate = LocalTemplate(context: ctx)
            newTemplate.id = name
            return newTemplate
        }
        await context.perform { template.name = name }
        if !template.viewPoints.isEmpty {
            for point in template.viewPoints {
                template.removeFromTemplatePoints(point)
                removeLocalTemplatePoint(point, inContext: contextType)
            }
        }
        for point in points {
            let localTemplatePoint =
            await self.createTemplatePointFromLocalLocationPoint(point,
                                                                 inContext: contextType)
            await context.perform {
                template.addToTemplatePoints(localTemplatePoint)
                localTemplatePoint.parentTemplate = template
            }
        }
        return template
    }

    func createTemplatePointFromLocalLocationPoint(_ point: LocalLocationPoint,
                                                   inContext contextType: ContextType) async -> LocalTemplatePoint {
        let context = contextFromType(contextType)
        let tp = fetchOrCreateObject(
            ofType: LocalTemplatePoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: context
        ) { ctx in
            let newTemplatePoint = LocalTemplatePoint(context: ctx)
            newTemplatePoint.id = UUID().uuidString
            return newTemplatePoint
        }
        await context.perform {
            tp.coordinateX = point.coordinateX
            tp.coordinateY = point.coordinateY
            tp.number = point.number
            tp.pointDescription = point.pointDescription
            tp.task = point.task
            tp.scaleFactor = point.scaleFactor
            tp.rotation = point.rotation
            tp.cameras = point.viewLocalCameras.map({ $0.viewOptic.rawValue }).joined(separator: ",")
            tp.sounds = point.viewLocalSounds.map({ $0.viewPlaceType.rawValue }).joined(separator: ",")
            tp.lights = point.viewLocalLights.map({ $0.viewLightType.rawValue }).joined(separator: ",")
        }
        return tp
    }
}

// MARK: - Save context and publish changes to update ui
extension DataManager {
    func saveContext(type contextType: ContextType,
                     publish: GlobalProperties.PublishChanges,
                     id: [String]) async {
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
