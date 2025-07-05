import CoreData
import Combine
import UIKit

class DataManager: ObservableObject {

    let persistentContainer: NSPersistentContainer
    let networkManager: NetworkManager

    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    
    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
//    var cancellables: Set<AnyCancellable> = []
    
    var currentId: String = ""
    var accessLevel: Int = 2
    var currentUserID: NSManagedObjectID = NSManagedObjectID()
    

    // MARK: - Init
    init(forPreview: Bool = false,
         name: String = "BroadcastPlanner",
        globalDataManager: NetworkManager
    ) {
        let name: String = "BroadcastPlanner"
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
//        self.mainContext = persistentContainer.viewContext
        
        
        self.networkManager = globalDataManager
        self.networkManager.syncDelegate = self
        Task{
            await self.networkManager.start()
        }
//        self.updatePublisher.sink { value in
//            self.updatePublisher.send(value)
//        }
//        .store(in: &cancellables)
    }
    
    func setMember(id: String){
        self.currentId = id
        let currentUserInMainContext: Member = mainContext.fetchOrCreateObject(withID: id)
        self.currentUserID = currentUserInMainContext.objectID
        self.accessLevel = Int(currentUserInMainContext.accessLevel)
    }
    
    func clearData(){
        self.currentId = ""
        self.currentUserID = NSManagedObjectID()
        self.accessLevel = 2
    }
}

//bg work
extension DataManager: UpdateDelegateProtocol {
    
    func updateWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO){
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {
           _ = dto.updateOrCreate(in: backgroundContext)
            try? backgroundContext.save()
        }
    }
    
    
    func removeWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO){
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            dto.remove(in: backgroundContext)
            try? backgroundContext.save()
        }
    }
    
    /// Синхронизирует сущности из массива DTO: обновляет/создаёт + удаляет лишние
    func sync<DTO: CoreDataRepresentable>(with dtos: [DTO]) {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.performAndWait {
            createOrUpdate(dtos: dtos, in: context)
            removeMissing(dtos: dtos,in: context)
            try? context.save()
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
extension DataManager {
    //creates new member cloud entity
    @MainActor func fetchOwner() -> Member {
        return  mainContext.fetchOrCreateObject(withID: currentId)
    }
    
    func createUser(id: String) async {
        let userDTO = MemberDTO(id: id)
        await networkManager.saveData(
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
            var localImage: LocalImage?
        let currentUserInMainContext = fetchOwner()
            if let inputImage {
                currentUserInMainContext.image = nil
                localImage = self.mainContext.fetchOrCreateObject(withID: self.currentId)
                localImage?.updateValues(type: GlobalProperties.ImageType.member.rawValue,
                                         lastUpdated: Date.now,
                                         uiimage: inputImage,
                                         in: self.mainContext)
            }
            currentUserInMainContext.updateValues(firstName: firstName,
                                          lastName: lastName,
                                          phoneNumber: phoneNumber,
                                          homeAddress: address,
                                          email: email,
                                          image: localImage,
                                          lastUpdated: Date.now,
                                          specializations:userSpecialization.joined(separator: ","),
                                          in: self.mainContext)
        try? saveContext(publish: .images, id: [currentId])
        

        if let inputImage {
            _ = await networkManager.saveImageToGlobalStorage(
                id: currentId,
                uiimage: inputImage,
                type: GlobalProperties.ImageType.member
            )
        }
        await networkManager
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
        let request = Member.fetchRequest()
        do {
            let users = try mainContext.fetch(request)
            return users.filter { $0.isAvailableTo(broadcast: event) }
        } catch {
            return []
        }
    }
}
// MARK: - Broadcast managment
extension DataManager {
    
    func availabletoEdit(event: Broadcast)->Bool {
//        let user = currentUserInMainContext
//        if user.accessLevel == 0 {
//            return false
//        } else if user.accessLevel == 1, event.viewOwners.map({$0.viewId}).contains(currentId){
//            return false
//        } else {
            return true
//        }
    }
    
    @MainActor
    func createEventWithCurrentUserOwnerInContextType() async throws -> Broadcast {
            let broadcast: Broadcast = self.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
            if let user = mainContext.object(with: currentUserID) as? Member{
                broadcast.addToOwners(user)
                user.addToOwnedBroadcasts(broadcast)
            }
//            try self.mainContext.save()
            return broadcast
    }
    
@MainActor
    func updateBroadcast(
        _ broadcast: Broadcast) async {
            //network save
            await networkManager.saveData(
                broadcast.dto,
                withId: broadcast.viewId,
                withType: GlobalProperties.Path.broadcasts
            )
//            
            if let venuePreview = broadcast.venueSchemaPreview{
                await networkManager.saveData(venuePreview.dto,
                                                 withId: venuePreview.viewId,
                                                 withType: GlobalProperties.Path.images)
                if let uiimage = venuePreview.makeUIImage(){
                    _ = await networkManager.saveImageToGlobalStorage(id: venuePreview.viewId,
                                                                         uiimage: uiimage,
                                                                         type: GlobalProperties.ImageType.venuePreview)
                }
            }
            
            if let obvanPreview = broadcast.obvanPreview{
                await networkManager.saveData(obvanPreview.dto,
                                                 withId: obvanPreview.viewId,
                                                 withType: GlobalProperties.Path.images)
                if let uiimage = obvanPreview.makeUIImage(){
                    _ = await networkManager.saveImageToGlobalStorage(id: obvanPreview.viewId,
                                                                         uiimage: uiimage,
                                                                         type: GlobalProperties.ImageType.obvanPreview)
                }
            }
        }
    @MainActor
    func removeBroadcast(_ broadcast: Broadcast) async {
        let id = broadcast.viewId
        if let previewId = broadcast.venueSchemaPreview?.viewId{
            await networkManager.removeDataOfType(
                GlobalProperties.Path.images,
                withId: previewId
            )
            await networkManager.removeImage(localImageId: previewId)
        }
        if let previewObvanId = broadcast.obvanPreview?.viewId{
            await networkManager.removeDataOfType(
                GlobalProperties.Path.images,
                withId: previewObvanId
            )
            await networkManager.removeImage(localImageId: previewObvanId)
        }
        mainContext.delete(broadcast)
        try? saveContext(publish: .broadcasts, id: [])
        await networkManager.removeDataOfType(
            GlobalProperties.Path.broadcasts,
            withId: id
        )
        
    }
    @MainActor
    func assignSnapshot(_ image: UIImage?,
        toEvent broadcast: Broadcast) async {
        if let image {
            let localImage: LocalImage = mainContext.makeObjectFromDTO(
                ImageDTO(id: UUID().uuidString,
                         type: GlobalProperties.ImageType.venuePreview.rawValue,
                         lastUpdated: .now)
            )
            localImage.uploadImage(uiimage: image)
            broadcast.venueSchemaPreview = localImage
            localImage.parentVenuePreview = broadcast
            try? saveContext(publish: .images, id:[])
        }
    }
//}
//// MARK: - Points managment
//extension DataManager {
//    
//    func updateEvent(
//        _ event: Broadcast,
//        withPoints points: [VenuePoint]
//    ) {
//        mainContext.perform {
//            event.updateValues(venuePoints: points, in: self.mainContext)
//        }
//
//    }
//
//    @MainActor
//    func updatePoint(
//        _ point: VenuePoint,
//        x: Double,
//        y: Double,
//        rotation: Int,
//        scaleFactor: Double
//    ) {
//        localDataManager.updateLocalPoint(
//            point,
//            withX: x,
//            y: y,
//            rotation: rotation,
//            scaleFactor: scaleFactor,
//            inContext: .main
//        )
//    }
////    @MainActor func updatePoint(_ point: VenuePoint?, withNumber number: Int, user: Member?, optic: OpticType, placeType: PlaceType, windDefence: WindDefence, lightType: LightType){
////        guard let point, point.managedObjectContext == mainContext else { return }
////        
////        localDataManager.mainContext.performAndWait {
////            point.number = Int16(number)
////                //remove member
////                if let userToRemove = point.viewMembers.first{
////                    point.removeFromMembers(userToRemove)
////                    userToRemove.removeFromVenuePoints(point)
////                    if let event = point.broadcast {
////                        event.removeFromOwners(userToRemove)
////                    } else {
////                        print("event in venuePoint error occured")
////                    }
////                }
////            if let user{
////                //add new member
////                point.addToMembers(user)
////                user.addToVenuePoints(point)
////            }
////            //
////            for cam in point.viewCameras {
////                point.removeFromCameras(cam)
////                localDataManager.removeLocalCamera(cam, inContext: .main)
////            }
////            if optic != .none{
////                let cameraDTO = CameraDTO(id: UUID().uuidString, optic: optic)
////                let camera = localDataManager.createOrUpdateCamera(cameraDTO, inContext: .main)
////                localDataManager.linkLocalCamera(camera, withPoint: point, inContext: .main)
////            }
////            for sound in point.viewSounds {
////                point.removeFromSounds(sound)
////                localDataManager.removeLocalSound(sound, inContext: .main)
////            }
////            
////            if  placeType != .none{
////                let soundDto = SoundDTO(id: UUID().uuidString,windDefence: windDefence,placeType: placeType)
////                let sound = localDataManager.createOrUpdateSound(soundDto, inContext: .main)
////                localDataManager.linkLocalSound(sound, withPoint: point, inContext: .main)
////            }
////            
////                for light in point.viewLights {
////                    point.removeFromLights(light)
////                    localDataManager.removeLocalLight(light, inContext: .main)
////                }
////            if lightType != .none{
////                let lightDto = LightDTO(id: UUID().uuidString, lightType: lightType)
////                let light = localDataManager.createOrUpdateLight(lightDto, inContext: .main)
////                localDataManager.linkLocalLight(light, WithPoint: point, InContext: .main)
////            }
//////            saveContextSync(type: .main, publish: .venuePoint, id: [venuePoint.viewId])
////        }
////    }
////    
//    @MainActor
//    func updatePoint(
//        _ point: VenuePoint?,
//        withNumber num: Int
//    ) async {
//        guard let point, point.managedObjectContext == mainContext else { return }
//        mainContext.performAndWait {
//            point.number = Int16(num)
//        }
//    }
//    @MainActor
//    func updatePoint(
//        _ point: VenuePoint?,
//        withDescription desk: String
//    ) async {
//        guard let point else { return }
//        localDataManager.mainContext.performAndWait {
//            point.pointDescription = desk
//        }
//    }
//
//    @MainActor
//    func updatePoint(
//        _ point: VenuePoint?,
//        withCamera camera: Camera
//    ) async {
//        guard let point else { return }
//
//        localDataManager.mainContext.performAndWait {
//            point.addToCameras(camera)
//            print("camera adding complete")
//        }
//    }
//    @MainActor
//    func removeCamera(
//        _ camera: Camera,
//        fromPoint point: VenuePoint?
//    ) async {
//        guard let point else { return }
//        localDataManager.mainContext.performAndWait {
//            point.removeFromCameras(camera)
//        }
//        localDataManager.removeLocalCamera(camera, inContext: .main)
//    }
//    @MainActor
//    func updatePoint(
//        _ point: VenuePoint?,
//        withSound sound: Sound
//    ) async {
//        guard let point else { return }
//        localDataManager.mainContext.performAndWait {
//            point.addToSounds(sound)
//        }
//    }
//    @MainActor
//    func removeSound(
//        _ sound: Sound,
//        fromPoint point: VenuePoint?
//    ) async {
//        guard let point else { return }
//        localDataManager.mainContext.performAndWait {
//            point.removeFromSounds(sound)
//        }
//        localDataManager.removeLocalSound(sound, inContext: .main)
//    }
//    @MainActor
//    func updatePoint(
//        _ point: VenuePoint?,
//        withLight light: Light
//    ) async {
//        guard let point else { return }
//        localDataManager.mainContext.performAndWait {
//            point.addToLights(light)
//        }
//    }
//    @MainActor
//    func removeLight(
//        _ light: Light,
//        fromPoint point: VenuePoint?
//    ) async {
//        guard let point else { return }
//        localDataManager.mainContext.performAndWait {
//            point.removeFromLights(light)
//        }
//        localDataManager.removeLocalLight(light, inContext: .main)
//    }
//    @MainActor
//    func addUser(
//        _ user: Member,
//        toPoint point: VenuePoint?
//    ) async {
//        if let point {
//            localDataManager.mainContext.performAndWait {
//                point.addToMembers(user)
//                user.addToVenuePoints(point)
//            }
//        }
//    }
//    @MainActor
//    func removeUser(
//        _ user: Member,
//        fromPoint point: VenuePoint?
//    ) async {
//        if let point {
//            localDataManager.mainContext.performAndWait {
//                point.removeFromMembers(user)
//                user.removeFromVenuePoints(point)
//            }
//        }
//    }
//
//    @MainActor
//    func newPointInEvent(
//        _ event: Broadcast,
//        withNumber number: Int
//    ) -> VenuePoint {
//        let newPoint = localDataManager.fetchOrCreateObject(
//            ofType: VenuePoint.self,
//            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
//            in: localDataManager.mainContext
//        ) { ctx in
//            let newLocationPoint = VenuePoint(context: ctx)
//            newLocationPoint.id = UUID().uuidString
//            return newLocationPoint
//        }
//        localDataManager.mainContext.perform {
//            newPoint.number = Int16(number)
//            event.addToVenuePoints(newPoint)
//        }
//        return newPoint
//    }
//    @MainActor
//    func deletePoint(
//        _ point: VenuePoint,
//        inEvent event: Broadcast
//    ) {
//        localDataManager.removeLocalLocationPoint(point, inContext: .main)
//    }
//}
//// MARK: - Crew managment
//extension DataManager {
//    @MainActor
//    func removeUnit(_ unit: Crew) {
//        localDataManager.removeLocalUnit(unit, inContext: .main)
//    }
//    func createUnitWithUser(
//        _ user: Member,
//        andSpecialization specialization: UserSpecialization,
//        andHardware hardware: HardwareType?,
//        inEvent event: Broadcast
//    ) -> Crew {
//        let unit = localDataManager.createUnitWithUser(
//            user,
//            andPosition: specialization,
//            andHardware: hardware,
//            inContext: .main
//        )
//        localDataManager.mainContext.perform {
//            event.addToCrews(unit)
//            user.addToCrews(unit)
//            unit.member = user
//            unit.broadcast = event
//        }
//        return unit
//    }
//
//}
//// MARK: - Club managment
//extension DataManager {
//    @MainActor
//    func createClub() -> Club {
//        let id = UUID().uuidString
//        return localDataManager.fetchOrCreateObject(
//            ofType: Club.self,
//            predicate: NSPredicate(format: "id == %@", id),
//            in: localDataManager.mainContext
//        ) { ctx in
//            let newClub = Club(context: ctx)
//            newClub.id = id
//            return newClub
//        }
//    }
//
//    @MainActor
//    func updateClub(_ club: Club,
//                    withTitle: String,
//                    uiimage: UIImage?,
//                    contacts: String,
//                    urlString: String,
//                    location: Venue?,
//                    inContext contextType: ContextType) async {
//        //save image logo in local storage,
//
//         localDataManager.updateClubWithClub(
//            club: club,
//            title: withTitle,
//            uiimage: uiimage,
//            contacts: contacts,
//            urlString: urlString,
//            location: location,
//            inContext: .main
//        )
//        await saveContextAsync(type: .main, publish: .clubs, id: [club.viewId])
//
//        //upload image to firestore and image properties and clubDTO to firebase
//        if let imageId = club.imageLogo?.viewId, let uiimage {
//            _ = await self.networkManager.saveImageToGlobalStorage(
//                id: imageId,
//                uiimage: uiimage,
//                type: GlobalProperties.ImageType.club
//            )
//        }
//        await self.networkManager.saveData(
//            club.dto,
//            withId: club.viewId,
//            withType: GlobalProperties.Path.clubs
//        )
//    }
//    @MainActor
//    func removeCub(_ club: Club) async {
//        //remove image from firestore, and image properties and club from firebase
//        let id = club.viewId
//        if let imageId = club.imageLogo?.id {
//            await self.networkManager.removeImage(localImageId: imageId)
//        }
//        await networkManager.removeDataOfType(
//            GlobalProperties.Path.clubs,
//            withId: id
//        )
//        //remove club from coredata and image logo from local storage
//        localDataManager.removeLocalClub(localClub: club, inContext: .main)
//        await saveContextAsync(type: .main, publish: .clubs, id: [])
//    }
//}
//// MARK: - LocationManagment
//extension DataManager {
//    @MainActor
//    func getNewLocation() -> Venue {
//        localDataManager.fetchOrCreateObject(
//            ofType: Venue.self,
//            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
//            in: localDataManager.mainContext
//        ) { ctx in
//            let newLocation = Venue(context: ctx)
//            newLocation.id = UUID().uuidString
//            return newLocation
//        }
//    }
//    @MainActor
//    func updateLocalLocation(
//        _ location: Venue,
//        withTitle title: String,
//        address: String,
//        images: [UIImage],
//        background: LocalImage?
//    ) async {
//        //update coredata entity
//            localDataManager.updateLocalLocation(
//            location,
//            withTitle: title,
//            address: address,
//            localImages: images,
//            locationBackground: background,
//            inContext: .main
//        )
//        await localDataManager.saveContextAsync(
//            type: .main,
//            publish: .venues,
//            id: []
//        )
//        // venue image upload to firestore, and image properties in firebase
//        let images = location.viewLocalImages
//        if !images.isEmpty {
//            await withTaskGroup { group in
//                images.forEach { image in
//                    if let uiimage = image.makeUIImage() {
//                        group.addTask { [weak self] in
//                            guard let self else { return }
//                            _ = await networkManager.saveImageToGlobalStorage(
//                                id: image.viewId,
//                                uiimage: uiimage,
//                                type: GlobalProperties.ImageType.venue
//                            )
//                        }
//                    }
//                }
//            }
//            //            group.addTask { [weak self] in
//            //                //broadcastSchema?
//            //            }
//
//        }
//        await networkManager.saveData(
//            location.dto,
//            withId: location.viewId,
//            withType: GlobalProperties.Path.venues
//        )
//    }
//    @MainActor
//    func removeLocation(_ location: Venue) async {
//        //remove broadcastSchema images for venue from firestore, and image properties from firebase
//        await withTaskGroup { group in
//            let imageIds = location.viewLocalImages.map { $0.viewId }
//            if !imageIds.isEmpty {
//                imageIds.forEach { id in
//                    group.addTask { [weak self] in
//                        guard let self else { return }
//                        await self.networkManager.removeImage(
//                            localImageId: id
//                        )
//                    }
//                }
//            }
//        }
//        //remove venue from firebase
//        await networkManager.removeDataOfType(
//            .venues,
//            withId: location.viewId
//        )
//        //remove images and venue from CoreData
//         localDataManager.removeLocalLocation(location, inContext: .main)
//        await saveContextAsync(type: .main, publish: .venues, id: [])
//    }
//}
//// MARK: - Template managment
//extension DataManager {
//    @MainActor
//    func makeLocalPointsFromTemplate(_ template: Template)
//        -> [VenuePoint]
//    {
//        return localDataManager.mapTemplateToLocationPoints(
//            template: template,
//            inContext: .main
//        )
//    }
//    @MainActor func cleanLocalPoints(_ points: [VenuePoint], inEvent event: Broadcast){
//        localDataManager.unlinkPoints(points, inContext: .main)
//        points.forEach { pointToRemove in
//            localDataManager.removeLocalLocationPoint(pointToRemove, inContext: .main)
//        }
//    }
//    
//    @MainActor func loadTemplatePoints(_ points:[VenuePoint], toEvent event: Broadcast){
//        localDataManager.linkPoints(points, toEvent: event, inContext: .main)
//    }
//
//    @MainActor
//    func saveTemplateFromSchema(
//        localPoints: [VenuePoint],
//        withName name: String
//    ) async {
//        let template =
//             localDataManager.createTemplateWithLocalLocationPoints(
//                localPoints,
//                andName: name,
//                inContext: .main
//            )
//        await saveContextAsync(type: .main, publish: .templates, id: [])
//
//        await networkManager.saveData(
//            template.dto,
//            withId: template.viewId,
//            withType: .templates
//        )
//    }
//@MainActor
//    func removeLocalTemplate(_ template: Template) async {
//        await networkManager.removeDataOfType(
//            GlobalProperties.Path.templates,
//            withId: template.viewId
//        )
//        localDataManager.removeLocalTemplate(template, inContext: .main)
//        await saveContextAsync(type: .main, publish: .templates, id: [])
//    }
//}
//// MARK: - Obvan managment
//extension DataManager {
//    func createObvanWithName(
//        _ name: String,
//        broadcaster: String,
//        image: UIImage?
//    ) -> Obvan {
//        localDataManager.fetchOrCreateObject(
//            ofType: Obvan.self,
//            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
//            in: localDataManager.mainContext
//        ) { ctx in
//            let newObvan = Obvan(context: ctx)
//            newObvan.id = UUID().uuidString
//            return newObvan
//        }
//
//    }
//
//    func updateObvan(_ localObvan: Obvan) async {
//        //update local
//
//        //update global
//        await networkManager.saveData(
//            localObvan.dto,
//            withId: localObvan.viewId,
//            withType: GlobalProperties.Path.obvans
//        )
//    }
//
//    func removeObvan(_ obvan: Obvan) async {
//        //remove from global
//        await networkManager.removeDataOfType(
//            GlobalProperties.Path.obvans,
//            withId: obvan.viewId
//        )
//
//        //remove from local
//    }
//
//}
//
//// MARK: - Image managment
//extension DataManager {
//    @MainActor
//    func createNewLocalImagesWith(uiimages: [UIImage],
//                                  andType type: GlobalProperties.ImageType,
//                                  linkToLocation location: Venue? = nil) {
//        var localImages: [LocalImage] = []
//        for uiimage in uiimages {
//            let id = UUID().uuidString
//            localImages.append(
//            localDataManager
//                .createOrUpdateLocalImageWithId(
//                    id,
//                    withImage: uiimage,
//                    andType: type,
//                    inContext: .main
//                )
//            )
//        }
//        //link images to venue
//        if let location{
//            localDataManager.linkImages(localImages, toLocalLocation: location, inContext: .main)
//        }
//        saveContextSync(
//                type: .main,
//                publish: .images,
//                id: []
//            )
//        
//    }
//    @MainActor
//    func removeImage(selectedImage: LocalImage?) {
//        if let localImageToRemove = selectedImage {
//            localDataManager.removeLocalImage(
//                localImageToRemove,
//                inContext: .main
//            )
//            Task {
//                await saveContextAsync(type: .main, publish: .none, id: [])
//            }
//        }
//    }
//    @MainActor func linkEventTemplate(_ localImage: LocalImage, toLocation location: Venue){
//        localDataManager.linkEventTemplate(localImage, toLocalLocation: location, inContext: .main)
//        saveContextSync(type: .main, publish: GlobalProperties.PublishChanges.venues, id: [location.viewId])
//    }
}
// MARK: - Online status managment
extension DataManager {
    func changeOnlineStatus(isOnline: Bool) async {
        if isOnline {
            await networkManager.goOnline(id: currentId)
        } else {
            await networkManager.goOffline(id: currentId)
        }
    }
}

// MARK: - CoreDate Context
extension DataManager {
    @MainActor
    func rollBackMoc() {
        mainContext.rollback()
    }
    
//    func saveContextSync(
//        type: ContextType,
//        publish: GlobalProperties.PublishChanges,
//        id: [String]
//    )  {
//        localDataManager.saveContextSync(type: type, publish: publish, id: id)
//    }
}

//// MARK: - Save context and publish changes to update ui
extension DataManager {
    @MainActor
    func saveContext(publish: GlobalProperties.PublishChanges,
                     id: [String]) throws {
        if mainContext.hasChanges {
            try mainContext.save()
            if publish != .none {
                self.updatePublisher.send((publish, id))
            }
        }
    }
}


   

