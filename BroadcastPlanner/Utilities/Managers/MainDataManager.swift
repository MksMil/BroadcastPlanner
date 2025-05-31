import CoreData
import Combine
import UIKit

class MainDataManager: ObservableObject {

    let localDataManager: DataManager
    let globalDataManager: NetworkManager

    var mainContext: NSManagedObjectContext {
        localDataManager.mainContext
    }
    var backgroundContext: NSManagedObjectContext {
        localDataManager.backgroundContext
    }
    
    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
    var cancellables: Set<AnyCancellable> = []
    
    let currentId: String
    let currentUserID: NSManagedObjectID

    var currentUserInMainContext: Member {
        mainContext.performAndWait {
            try! mainContext.existingObject(with: currentUserID) as! Member
        }
    }

    var currentUserInBackgroundContext: Member {
        backgroundContext.performAndWait {
            try! backgroundContext.existingObject(with: currentUserID) as! Member
        }
    }


    init(
        localDataManager: DataManager,
        globalDataManager: NetworkManager,
        userId: String
    ) {
        self.localDataManager = localDataManager
        self.globalDataManager = globalDataManager
        self.currentId = userId
        //init coredata context here?
        let currentMember: Member = localDataManager.mainContext.fetchOrCreateObject(withID: userId)
        self.currentUserID = currentMember.objectID
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
extension MainDataManager: UpdateDelegateProtocol {
    
    func updateWithDTO(_ dto: any CoreDataRepresentable){
        backgroundContext.performAndWait {
           _ = dto.updateOrCreate(in: backgroundContext)
        }
    }
    
    
    func removeWithDTO(_ dto: any CoreDataRepresentable){
        backgroundContext.performAndWait {
            dto.remove(in: backgroundContext)
        }
    }
    
    /// Синхронизирует сущности из массива DTO: обновляет/создаёт + удаляет лишние
    func sync<DTO: CoreDataRepresentable>(with dtos: [DTO]) {
        localDataManager.backgroundContext.performAndWait {
            createOrUpdate(dtos: dtos, in: localDataManager.backgroundContext)
            removeMissing(dtos: dtos,in: localDataManager.backgroundContext)
            try? localDataManager.backgroundContext.save()
        }
       }
       
       /// Создаёт или обновляет объекты Core Data из DTO
    func createOrUpdate<DTO: CoreDataRepresentable>(dtos: [DTO],in context: NSManagedObjectContext) {
        for dto in dtos {
            let object: DTO.Entity = context.fetchOrCreateObject(withID: dto.id)
            object.updateFromDTO(dto, in: context)
        }
        
    }

       /// Удаляет объекты Core Data, которых нет среди DTO.id
    func removeMissing<DTO: CoreDataRepresentable>(dtos: [DTO],in context: NSManagedObjectContext) {
        let ids = dtos.map { $0.id }
        let request = DTO.Entity.fetchRequest()
        request.predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        
        do {
            if let toDelete = try context.fetch(request) as? [DTO.Entity] {
                toDelete.forEach { context.delete($0) }
            }
        } catch {
            print("❌ Ошибка при удалении объектов типа \(DTO.Entity.self): \(error)")
        }
        
    }
}

// MARK: - User managment
extension MainDataManager {
    //creates new member cloud entity
    
    func createUser(id: String) async {
        let userDTO = MemberDTO(id: id)
        await globalDataManager.saveData(
            userDTO,
            withId: id,
            withType: GlobalProperties.Path.members
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
        await mainContext.perform {
            var localImage: LocalImage?
            if let inputImage {
                localImage = self.mainContext.fetchOrCreateObject(withID: self.currentId)
                localImage?.updateValues(type: GlobalProperties.ImageType.member.rawValue,
                                         lastUpdated: Date.now,
                                         uiimage: inputImage,
                                         in: self.mainContext)
            }
            self.currentUserInMainContext.updateValues(firstName: firstName,
                                          lastName: lastName,
                                          phoneNumber: phoneNumber,
                                          homeAddress: address,
                                          email: email,
                                          image: localImage,
                                          accessLevel: nil,
                                          isOnline: nil,
                                          lastUpdated: Date.now,
                                          creationDate: nil,
                                          leaveDate: nil,
                                          specializations:userSpecialization.joined(separator: ","),
                                          in: self.mainContext)
            try? self.mainContext.save()
        }

        if let inputImage {
            _ = await globalDataManager.saveImageToGlobalStorage(
                id: currentId,
                uiimage: inputImage,
                type: GlobalProperties.ImageType.member
            )
        }
        await globalDataManager
            .saveData(
                currentUserInMainContext.dto,
                withId: currentId,
                withType: GlobalProperties.Path.members
            )
    }
    func removeCurrrentUser() {
        //remove member and member image in global

        // remove member and member image in local
    }

    func removeUser(user: MemberDTO) {
        // remove member and member image in local
    }

    @MainActor
    func fetchUsersAvailableForEvent(_ event: Broadcast) -> [Member] {
        localDataManager.fetchUsersAvailableToEvent(event)
    }
}
// MARK: - Broadcast managment
extension MainDataManager {
    
    func availabletoEdit(event: Broadcast)->Bool {
        let user = currentUserInMainContext
        if user.accessLevel == 0 {
            return false
        } else if user.accessLevel == 1, event.viewOwners.map({$0.viewId}).contains(currentId){
            return false
        } else {
            return true
        }
    }
    
    @MainActor
    func createEventWithCurrentUserOwnerInContextType() async throws -> Broadcast {
        try await mainContext.perform {
            let broadcast: Broadcast = self.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
            let user = self.currentUserInMainContext
            broadcast.addToOwners(user)
            user.addToOwnedBroadcasts(broadcast)
            try self.mainContext.save()
            return broadcast
        }
    }

    @MainActor
    func updateEvent(
        _ event: Broadcast,
        homeClub: Club?,
        guestClub: Club?,
        eventDate: Date,
        location: Venue?) async {
        //coreData save
//        await localDataManager.mainContext.perform { [weak self] in
//            guard let self else { return }
//            event.homeClub = homeClub
//            event.guestClub = guestClub
//            event.date = eventDate
//            event.venue = location
//            event.addToOwners(self.currentUser)
//        }
//        await saveContextAsync(type: .main, publish: .broadcasts, id: [event.viewId])
//
//        //network save
//        await globalDataManager.saveData(
//            event.dto,
//            withId: event.viewId,
//            withType: GlobalProperties.Path.broadcasts
//        )
    }
    @MainActor
    func removeEvent(event: Broadcast) async {
        let id = event.viewId
        localDataManager.removeLocalEvent(event, inContext: .main)
        await saveContextAsync(type: .main, publish: .broadcasts, id: [])
        await globalDataManager.removeDataOfType(
            GlobalProperties.Path.broadcasts,
            withId: id
        )
    }
    @MainActor
    func assignSnapshot(_ image: UIImage?,
        toEvent event: Broadcast) async {
        if let image {
            let localImage =
                 localDataManager.createOrUpdateLocalImageWithImageData(
                    imageDTO: .init(
                        id: UUID().uuidString,
                        type: GlobalProperties.ImageType.venuePreview
                            .rawValue,
                        lastUpdated: .now
                    ),
                    withImage: image,
                    inContext: .main
                )
            localDataManager.mainContext.performAndWait {
                event.venueSchemaPreview = localImage
                localImage.parentVenuePreview = event
            }
        }
    }
}
// MARK: - Points managment
extension MainDataManager {
    @MainActor
    func updateEvent(
        _ event: Broadcast,
        withPoints points: [VenuePoint]
    ) {
        localDataManager.mainContext.performAndWait {
            event.venuePoints = Set(points) as NSSet
        }
    }

    @MainActor
    func updatePoint(
        _ point: VenuePoint,
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
    @MainActor func updatePoint(_ point: VenuePoint?, withNumber number: Int, user: Member?, optic: OpticType, placeType: PlaceType, windDefence: WindDefence, lightType: LightType){
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.number = Int16(number)
                //remove member
                if let userToRemove = point.viewMembers.first{
                    point.removeFromMembers(userToRemove)
                    userToRemove.removeFromVenuePoints(point)
                    if let event = point.broadcast {
                        event.removeFromOwners(userToRemove)
                    } else {
                        print("event in venuePoint error occured")
                    }
                }
            if let user{
                //add new member
                point.addToMembers(user)
                user.addToVenuePoints(point)
            }
            //
            for cam in point.viewCameras {
                point.removeFromCameras(cam)
                localDataManager.removeLocalCamera(cam, inContext: .main)
            }
            if optic != .none{
                let cameraDTO = CameraDTO(id: UUID().uuidString, optic: optic)
                let camera = localDataManager.createOrUpdateCamera(cameraDTO, inContext: .main)
                localDataManager.linkLocalCamera(camera, withPoint: point, inContext: .main)
            }
            for sound in point.viewSounds {
                point.removeFromSounds(sound)
                localDataManager.removeLocalSound(sound, inContext: .main)
            }
            
            if  placeType != .none{
                let soundDto = SoundDTO(id: UUID().uuidString,windDefence: windDefence,placeType: placeType)
                let sound = localDataManager.createOrUpdateSound(soundDto, inContext: .main)
                localDataManager.linkLocalSound(sound, withPoint: point, inContext: .main)
            }
            
                for light in point.viewLights {
                    point.removeFromLights(light)
                    localDataManager.removeLocalLight(light, inContext: .main)
                }
            if lightType != .none{
                let lightDto = LightDTO(id: UUID().uuidString, lightType: lightType)
                let light = localDataManager.createOrUpdateLight(lightDto, inContext: .main)
                localDataManager.linkLocalLight(light, WithPoint: point, InContext: .main)
            }
//            saveContextSync(type: .main, publish: .venuePoint, id: [venuePoint.viewId])
        }
    }
    
    @MainActor
    func updatePoint(
        _ point: VenuePoint?,
        withNumber num: Int
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.number = Int16(num)
        }
    }
    @MainActor
    func updatePoint(
        _ point: VenuePoint?,
        withDescription desk: String
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.pointDescription = desk
        }
    }

    @MainActor
    func updatePoint(
        _ point: VenuePoint?,
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
        fromPoint point: VenuePoint?
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.removeFromCameras(camera)
        }
        localDataManager.removeLocalCamera(camera, inContext: .main)
    }
    @MainActor
    func updatePoint(
        _ point: VenuePoint?,
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
        fromPoint point: VenuePoint?
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.removeFromSounds(sound)
        }
        localDataManager.removeLocalSound(sound, inContext: .main)
    }
    @MainActor
    func updatePoint(
        _ point: VenuePoint?,
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
        fromPoint point: VenuePoint?
    ) async {
        guard let point else { return }
        localDataManager.mainContext.performAndWait {
            point.removeFromLights(light)
        }
        localDataManager.removeLocalLight(light, inContext: .main)
    }
    @MainActor
    func addUser(
        _ user: Member,
        toPoint point: VenuePoint?
    ) async {
        if let point {
            localDataManager.mainContext.performAndWait {
                point.addToMembers(user)
                user.addToVenuePoints(point)
            }
        }
    }
    @MainActor
    func removeUser(
        _ user: Member,
        fromPoint point: VenuePoint?
    ) async {
        if let point {
            localDataManager.mainContext.performAndWait {
                point.removeFromMembers(user)
                user.removeFromVenuePoints(point)
            }
        }
    }

    @MainActor
    func newPointInEvent(
        _ event: Broadcast,
        withNumber number: Int
    ) -> VenuePoint {
        let newPoint = localDataManager.fetchOrCreateObject(
            ofType: VenuePoint.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newLocationPoint = VenuePoint(context: ctx)
            newLocationPoint.id = UUID().uuidString
            return newLocationPoint
        }
        localDataManager.mainContext.perform {
            newPoint.number = Int16(number)
            event.addToVenuePoints(newPoint)
        }
        return newPoint
    }
    @MainActor
    func deletePoint(
        _ point: VenuePoint,
        inEvent event: Broadcast
    ) {
        localDataManager.removeLocalLocationPoint(point, inContext: .main)
    }
}
// MARK: - Crew managment
extension MainDataManager {
    @MainActor
    func removeUnit(_ unit: Crew) {
        localDataManager.removeLocalUnit(unit, inContext: .main)
    }
    func createUnitWithUser(
        _ user: Member,
        andSpecialization specialization: UserSpecialization,
        andHardware hardware: HardwareType?,
        inEvent event: Broadcast
    ) -> Crew {
        let unit = localDataManager.createUnitWithUser(
            user,
            andPosition: specialization,
            andHardware: hardware,
            inContext: .main
        )
        localDataManager.mainContext.perform {
            event.addToCrews(unit)
            user.addToCrews(unit)
            unit.member = user
            unit.broadcast = event
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
                    location: Venue?,
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
            _ = await self.globalDataManager.saveImageToGlobalStorage(
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
    func getNewLocation() -> Venue {
        localDataManager.fetchOrCreateObject(
            ofType: Venue.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newLocation = Venue(context: ctx)
            newLocation.id = UUID().uuidString
            return newLocation
        }
    }
    @MainActor
    func updateLocalLocation(
        _ location: Venue,
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
            publish: .venues,
            id: []
        )
        // venue image upload to firestore, and image properties in firebase
        let images = location.viewLocalImages
        if !images.isEmpty {
            await withTaskGroup { group in
                images.forEach { image in
                    if let uiimage = image.makeUIImage() {
                        group.addTask { [weak self] in
                            guard let self else { return }
                            _ = await globalDataManager.saveImageToGlobalStorage(
                                id: image.viewId,
                                uiimage: uiimage,
                                type: GlobalProperties.ImageType.venue
                            )
                        }
                    }
                }
            }
            //            group.addTask { [weak self] in
            //                //broadcastSchema?
            //            }

        }
        await globalDataManager.saveData(
            location.dto,
            withId: location.viewId,
            withType: GlobalProperties.Path.venues
        )
    }
    @MainActor
    func removeLocation(_ location: Venue) async {
        //remove broadcastSchema images for venue from firestore, and image properties from firebase
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
        //remove venue from firebase
        await globalDataManager.removeDataOfType(
            .venues,
            withId: location.viewId
        )
        //remove images and venue from CoreData
         localDataManager.removeLocalLocation(location, inContext: .main)
        await saveContextAsync(type: .main, publish: .venues, id: [])
    }
}
// MARK: - Template managment
extension MainDataManager {
    @MainActor
    func makeLocalPointsFromTemplate(_ template: Template)
        -> [VenuePoint]
    {
        return localDataManager.mapTemplateToLocationPoints(
            template: template,
            inContext: .main
        )
    }
    @MainActor func cleanLocalPoints(_ points: [VenuePoint], inEvent event: Broadcast){
        localDataManager.unlinkPoints(points, inContext: .main)
        points.forEach { pointToRemove in
            localDataManager.removeLocalLocationPoint(pointToRemove, inContext: .main)
        }
    }
    
    @MainActor func loadTemplatePoints(_ points:[VenuePoint], toEvent event: Broadcast){
        localDataManager.linkPoints(points, toEvent: event, inContext: .main)
    }

    @MainActor
    func saveTemplateFromSchema(
        localPoints: [VenuePoint],
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
@MainActor
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
    func createNewLocalImagesWith(uiimages: [UIImage],
                                  andType type: GlobalProperties.ImageType,
                                  linkToLocation location: Venue? = nil) {
        var localImages: [LocalImage] = []
        for uiimage in uiimages {
            let id = UUID().uuidString
            localImages.append(
            localDataManager
                .createOrUpdateLocalImageWithId(
                    id,
                    withImage: uiimage,
                    andType: type,
                    inContext: .main
                )
            )
        }
        //link images to venue
        if let location{
            localDataManager.linkImages(localImages, toLocalLocation: location, inContext: .main)
        }
        saveContextSync(
                type: .main,
                publish: .images,
                id: []
            )
        
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
    @MainActor func linkEventTemplate(_ localImage: LocalImage, toLocation location: Venue){
        localDataManager.linkEventTemplate(localImage, toLocalLocation: location, inContext: .main)
        saveContextSync(type: .main, publish: GlobalProperties.PublishChanges.venues, id: [location.viewId])
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
