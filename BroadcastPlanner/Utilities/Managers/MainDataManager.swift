import CoreData
import UIKit

class MainDataManager: ObservableObject {

    let localDataManager: DataManager
    let globalDataManager: NetworkManager

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
            in: localDataManager.moc
        ) { ctx in
            let newUser = LocalUser(context: ctx)
            newUser.id = userId
            return newUser
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
        await localDataManager.moc.perform { [weak self] in
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
                        in: localDataManager.moc
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
        await saveContext(
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
    func fetchUsersAvailableForEvent(_ event: LocalEvent) -> [LocalUser] {
        localDataManager.fetchUsersAvailableToEvent(event)
    }
}
// MARK: - Event managment
extension MainDataManager {
    @MainActor
    func createEventWithCurrentUserOwnerInContextType(_ type: ContextType)
        -> LocalEvent {
        let event = localDataManager.fetchOrCreateObject(
            ofType: LocalEvent.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.moc
        ) { ctx in
            let newEvent = LocalEvent(context: ctx)
            newEvent.id = UUID().uuidString
            return newEvent
        }
        //link event to user
        localDataManager.contextFromType(type).perform { [weak self] in
            guard let self else { return }
            event.addToOwners(self.currentUser)
            currentUser.addToOwnedEvents(event)
        }
        return event
    }
    @MainActor
    func updateEvent(
        _ event: LocalEvent,
        homeClub: LocalClub?,
        guestClub: LocalClub?,
        eventDate: Date,
        location: LocalLocation?) async {
        //coreData save
        await localDataManager.moc.perform { [weak self] in
            guard let self else { return }
            event.homeClub = homeClub
            event.guestClub = guestClub
            event.date = eventDate
            event.location = location
            event.addToOwners(self.currentUser)
        }
        await saveContext(type: .main, publish: .events, id: [event.viewId])

        //network save
        await globalDataManager.saveData(
            event.dto,
            withId: event.viewId,
            withType: GlobalProperties.Path.events
        )
    }
    @MainActor
    func removeEvent(event: LocalEvent) async {
        let id = event.viewId
        await localDataManager.removeLocalEvent(event, inContext: .main)
        await saveContext(type: .main, publish: .events, id: [])
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.events,
            withId: id
        )
    }
    @MainActor
    func assignSnapshot(_ image: UIImage?,
        toEvent event: LocalEvent) async {
        if let image {
            let localImage =
                await localDataManager.createOrUpdateLocalImageWithImageData(
                    imageDTO: .init(
                        id: UUID().uuidString,
                        type: GlobalProperties.ImageType.locationPreview
                            .rawValue
                    ),
                    withImage: image,
                    inContext: .main
                )
            localDataManager.moc.performAndWait {
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
        _ event: LocalEvent,
        withPoints points: [LocalLocationPoint]
    ) {
        localDataManager.moc.performAndWait {
            event.points = Set(points) as NSSet
        }
    }

    @MainActor
    func updatePoint(
        _ point: LocalLocationPoint,
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
        _ point: LocalLocationPoint?,
        withNumber num: Int
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.number = Int16(num)
        }
    }
    @MainActor
    func updatePoint(
        _ point: LocalLocationPoint?,
        withDescription desk: String
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.pointDescription = desk
        }
    }

    @MainActor
    func updatePoint(
        _ point: LocalLocationPoint?,
        withCamera camera: LocalCamera
    ) async {
        guard let point else { return }

        localDataManager.moc.performAndWait {
            point.addToCameras(camera)
            print("camera adding complete")
        }
    }
    @MainActor
    func removeCamera(
        _ camera: LocalCamera,
        fromPoint point: LocalLocationPoint?
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.removeFromCameras(camera)
        }
        localDataManager.removeLocalCamera(camera, inContext: .main)
    }
    @MainActor
    func updatePoint(
        _ point: LocalLocationPoint?,
        withSound sound: LocalSound
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.addToSounds(sound)
        }
    }
    @MainActor
    func removeSound(
        _ sound: LocalSound,
        fromPoint point: LocalLocationPoint?
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.removeFromSounds(sound)
        }
        localDataManager.removeLocalSound(sound, inContext: .main)
    }
    @MainActor
    func updatePoint(
        _ point: LocalLocationPoint?,
        withLight light: LocalLight
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.addToLights(light)
        }
    }
    @MainActor
    func removeLight(
        _ light: LocalLight,
        fromPoint point: LocalLocationPoint?
    ) async {
        guard let point else { return }
        localDataManager.moc.performAndWait {
            point.removeFromLights(light)
        }
        localDataManager.removeLocalLight(light, inContext: .main)
    }
    @MainActor
    func addUser(
        _ user: LocalUser,
        toPoint point: LocalLocationPoint?
    ) async {
        if let point {
            localDataManager.moc.performAndWait {
                point.addToUser(user)
                user.addToLocationPoints(point)
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
        fromPoint point: LocalLocationPoint?
    ) async {
        if let point {
            localDataManager.moc.performAndWait {
                point.removeFromUser(user)
                user.removeFromLocationPoints(point)
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
        _ event: LocalEvent,
        withNumber number: Int
    ) -> LocalLocationPoint {
        let newPoint = localDataManager.fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.moc
        ) { ctx in
            let newLocationPoint = LocalLocationPoint(context: ctx)
            newLocationPoint.id = UUID().uuidString
            return newLocationPoint
        }
        localDataManager.moc.perform {
            newPoint.number = Int16(number)
            event.addToPoints(newPoint)
        }
        return newPoint
    }
    @MainActor
    func deletePoint(
        _ point: LocalLocationPoint,
        inEvent event: LocalEvent
    ) {
        localDataManager.removeLocalLocationPoint(point, inContext: .main)
    }
}
// MARK: - Unit managment
extension MainDataManager {
    @MainActor
    func removeUnit(_ unit: LocalUnit) {
        localDataManager.moc.perform {
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
        inEvent event: LocalEvent
    ) -> LocalUnit {
        let unit = localDataManager.createUnitWithUser(
            user,
            andPosition: specialization,
            andHardware: hardware,
            inContext: .main
        )
        localDataManager.moc.perform {
            event.addToUnits(unit)
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
extension MainDataManager {
    @MainActor
    func createClub() -> LocalClub {
        let id = UUID().uuidString
        return localDataManager.fetchOrCreateObject(
            ofType: LocalClub.self,
            predicate: NSPredicate(format: "id == %@", id),
            in: localDataManager.moc
        ) { ctx in
            let newClub = LocalClub(context: ctx)
            newClub.id = id
            return newClub
        }
    }

    @MainActor
    func updateClub(_ club: LocalClub,
                    withTitle: String,
                    uiimage: UIImage?,
                    contacts: String,
                    urlString: String,
                    location: LocalLocation?,
                    inContext contextType: ContextType) async {
        //save image logo in local storage,

        await localDataManager.updateClubWithClub(
            club: club,
            title: withTitle,
            uiimage: uiimage,
            contacts: contacts,
            urlString: urlString,
            location: location,
            inContext: .main
        )
        await saveContext(type: .main, publish: .clubs, id: [club.viewId])

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
    func removeCub(_ club: LocalClub) async {
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
        await saveContext(type: .main, publish: .clubs, id: [])
    }
}
// MARK: - LocationManagment
extension MainDataManager {
    @MainActor
    func getNewLocation() -> LocalLocation {
        localDataManager.fetchOrCreateObject(
            ofType: LocalLocation.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.moc
        ) { ctx in
            let newLocation = LocalLocation(context: ctx)
            newLocation.id = UUID().uuidString
            return newLocation
        }
    }
    @MainActor
    func updateLocalLocation(
        _ location: LocalLocation,
        withTitle title: String,
        address: String,
        images: [UIImage],
        background: LocalImage?
    ) async {
        //update coredata entity
        await localDataManager.updateLocalLocation(
            location,
            withTitle: title,
            address: address,
            localImages: images,
            locationBackground: background
        )
        await localDataManager.saveContext(
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
    func removeLocation(_ location: LocalLocation) async {
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
        await localDataManager.removeLocalLocation(location, inContext: .main)
        await saveContext(type: .main, publish: .locations, id: [])
    }
}
// MARK: - Template managment
extension MainDataManager {
    @MainActor
    func makeLocalPointFromTemplate(_ template: LocalTemplate)
        -> [LocalLocationPoint]
    {
        return localDataManager.mapTemplateToLocationPoints(
            template: template,
            inContext: .main
        )
    }

    @MainActor
    func saveTemplateFromSchema(
        localPoints: [LocalLocationPoint],
        withName name: String
    ) async {
        let template =
            await localDataManager.createTemplateWithLocalLocationPoints(
                localPoints,
                andName: name,
                inContext: .main
            )
        await saveContext(type: .main, publish: .templates, id: [])

        await globalDataManager.saveData(
            template.dto,
            withId: template.viewId,
            withType: .templates
        )
    }

    func removeLocalTemplate(_ template: LocalTemplate) async {
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.templates,
            withId: template.viewId
        )
        localDataManager.removeLocalTemplate(template, inContext: .main)
        await saveContext(type: .main, publish: .templates, id: [])
    }
}
// MARK: - Obvan managment
extension MainDataManager {
    func createObvanWithName(
        _ name: String,
        broadcaster: String,
        image: UIImage?
    ) -> LocalObvan {
        localDataManager.fetchOrCreateObject(
            ofType: LocalObvan.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.moc
        ) { ctx in
            let newObvan = LocalObvan(context: ctx)
            newObvan.id = UUID().uuidString
            return newObvan
        }

    }

    func updateObvan(_ localObvan: LocalObvan) async {
        //update local

        //update global
        await globalDataManager.saveData(
            localObvan.dto,
            withId: localObvan.viewId,
            withType: GlobalProperties.Path.obvans
        )
    }

    func removeObvan(_ obvan: LocalObvan) async {
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
            await saveContext(
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
                await saveContext(type: .main, publish: .none, id: [])
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
        localDataManager.moc.rollback()
    }

    func saveContext(
        type: ContextType,
        publish: GlobalProperties.PublishChanges,
        id: [String]
    ) async {

        await localDataManager.saveContext(type: type, publish: publish, id: id)

    }
}
