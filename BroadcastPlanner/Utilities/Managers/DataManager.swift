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
    
    var currentId: String = ""{
        willSet{
            if !newValue.isEmpty{
                updatePublisher.send((GlobalProperties.PublishChanges.images, [newValue])) //update profile image in status view
            }
        }
    }
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
// MARK: - Network update and sync
extension DataManager: UpdateDelegateProtocol {
    
    func updateWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO){
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            let object = dto.create(in: backgroundContext)
            if let image = object as? LocalImage {
                if dto.lastUpdated != image.lastUpdated{
                    let id = image.viewId
                    let type = image.viewType
                    Task{
                        let result = await networkManager.loadImage(from: id)
                        switch result {
                            case .success(let uiimage):
                                ImagesManager.saveResizedImages(image: uiimage, id: id, type: type)
                            case .failure(let failure):
                                print("error loading image: \(failure.localizedDescription)")
                        }
                   }
                }
            }
            object.updateFromDTO(dto, in: backgroundContext)
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
            if let image = object as? LocalImage {
                if dto.lastUpdated != image.viewLastUpdated{
                    let id = image.viewId
                    let type = image.viewType
                    Task{
                        let result = await networkManager.loadImage(from: id)
                        switch result {
                            case .success(let uiimage):
                                ImagesManager.saveResizedImages(image: uiimage, id: id, type: type)
                            case .failure(let failure):
                                print("sync image data error: \(failure.localizedDescription)")
                        }
                    }
                }
            }
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
    )  {
        var localImage: LocalImage?
        let currentUserInMainContext = fetchOwner()
        
        if let inputImage {
            if let image = currentUserInMainContext.image{
                image.uploadImage(uiimage: inputImage)
                Task{
                   await networkManager.saveImageToGlobalStorage(id: currentId, uiimage: inputImage, type: GlobalProperties.ImageType.member)
                    }
            } else {
                localImage = self.mainContext.fetchOrCreateObject(withID: self.currentId)
                localImage?.updateValues(type: GlobalProperties.ImageType.member.rawValue,
                                         lastUpdated: Date.now,
                                         uiimage: inputImage,
                                         in: self.mainContext)
                Task{
                    _ = await networkManager.saveImageToGlobalStorage(
                        id: currentId,
                        uiimage: inputImage,
                        type: GlobalProperties.ImageType.member
                    )
                }
            }
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
       //update user data
        Task{
            await networkManager
                .saveData(
                    currentUserInMainContext.dto,
                    withId: currentId,
                    withType: GlobalProperties.Path.members
                )
        }
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
            
            for obvanPreview in broadcast.viewObvanPreviews{
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
        for previewObvan in broadcast.viewObvanPreviews{
            
            await networkManager.removeDataOfType(
                GlobalProperties.Path.images,
                withId: previewObvan.viewId
            )
            await networkManager.removeImage(localImageId: previewObvan.viewId)
        }
        mainContext.delete(broadcast)
        try? saveContext(publish: .broadcasts, id: [])
        await networkManager.removeDataOfType(
            GlobalProperties.Path.broadcasts,
            withId: id
        )
        
    }
    // TODO: Rework mb?
    @MainActor
    func assignSnapshot(_ image: UIImage?,
                        toBroadcast broadcast: Broadcast) {
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
    }
    // MARK: - Points managment
    extension DataManager {
    
        func updateEvent(
            _ event: Broadcast,
            withPoints points: [VenuePoint]
        ) {
            mainContext.perform {
                event.updateValues(venuePoints: points, in: self.mainContext)
            }
    
        }
        
        @MainActor
        func updatePoint(_ point: VenuePoint?, withNumber number: Int, user: Member?, optic: String, placeType: String, windDefence: String, lightType: String){
    
            mainContext.performAndWait {
                guard let point else { return }
                print("point: x - \(point.viewX), y - \(point.viewY) ")
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
                    point.addToMembers(user)
                    user.addToVenuePoints(point)
                }
                for cam in point.viewCameras {
                    point.removeFromCameras(cam)
                }
                if optic != "Empty"{
                    let cameraDTO = CameraDTO(id: UUID().uuidString, optic: optic)
                    let camera: Camera = mainContext.makeObjectFromDTO(cameraDTO)
                    point.addToCameras(camera)
                    camera.point = point
                }
                for sound in point.viewSounds {
                    point.removeFromSounds(sound)
                }
    
                if  placeType != "Empty"{
                    let soundDto = SoundDTO(id: UUID().uuidString,windDefence: windDefence,placeType: placeType)
                    let sound: Sound = mainContext.makeObjectFromDTO(soundDto)
                    point.addToSounds(sound)
                    sound.point = point
                }
    
                    for light in point.viewLights {
                        point.removeFromLights(light)
                    }
                if lightType != "Empty"{
                    let lightDto = LightDTO(id: UUID().uuidString, lightType: lightType)
                    let light: Light = mainContext.makeObjectFromDTO(lightDto)
                    point.addToLights(light)
                    light.point = point
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
            mainContext.performAndWait {
                point.number = Int16(num)
            }
        }
        @MainActor
        func updatePoint(
            _ point: VenuePoint?,
            withDescription desk: String
        ) async {
            guard let point else { return }
            mainContext.performAndWait {
                point.pointDescription = desk
            }
        }
    
        @MainActor
        func updatePoint(
            _ point: VenuePoint?,
            withCamera camera: Camera
        ) async {
            guard let point else { return }
    
            mainContext.performAndWait {
                point.addToCameras(camera)
            }
        }
        @MainActor
        func removeCamera(
            _ camera: Camera,
            fromPoint point: VenuePoint?
        ) async {
            guard let point else { return }
            mainContext.performAndWait {
                point.removeFromCameras(camera)
            }
            //TODO: removeLocalCamera(camera, inContext: .main)
        }
        @MainActor
        func updatePoint(
            _ point: VenuePoint?,
            withSound sound: Sound
        ) async {
            guard let point else { return }
            mainContext.performAndWait {
                point.addToSounds(sound)
            }
        }
        @MainActor
        func removeSound(
            _ sound: Sound,
            fromPoint point: VenuePoint?
        ) async {
            guard let point else { return }
            mainContext.performAndWait {
                point.removeFromSounds(sound)
            }
            //TODO: removeLocalSound(sound, inContext: .main)
        }
        @MainActor
        func updatePoint(
            _ point: VenuePoint?,
            withLight light: Light
        ) async {
            guard let point else { return }
            mainContext.performAndWait {
                point.addToLights(light)
            }
        }
        @MainActor
        func removeLight(
            _ light: Light,
            fromPoint point: VenuePoint?
        ) async {
            guard let point else { return }
            mainContext.performAndWait {
                point.removeFromLights(light)
            }
            //TODO: removeLocalLight(light, inContext: .main)
        }
        @MainActor
        func addUser(
            _ user: Member,
            toPoint point: VenuePoint?
        ) async {
            if let point {
                mainContext.performAndWait {
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
                mainContext.performAndWait {
                    point.removeFromMembers(user)
                    user.removeFromVenuePoints(point)
                }
            }
        }
    
        @MainActor
        func newPointInEvent(
            _ broadcast: Broadcast,
            withNumber number: Int
        ) -> VenuePoint {
            mainContext.performAndWait {
                let id = UUID().uuidString
                let newPoint: VenuePoint = mainContext.fetchOrCreateObject(withID: id)
                newPoint.number = Int16(number)
                broadcast.addToVenuePoints(newPoint)
                newPoint.broadcast = broadcast
                return newPoint
            }
        }
        
        
        func deletePoint(
            _ point: VenuePoint) {
            mainContext.performAndWait {
                mainContext.delete(point)
            }
            
//TODO:            removeLocalLocationPoint(point, inContext: .main)
        }
    }
    // MARK: - Crew managment
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

 
    // MARK: - Template managment
    extension DataManager {
        @MainActor
        func makeLocalPointsFromTemplate(_ template: Template) async
         -> [VenuePoint]
        {
                return await withTaskGroup(of: VenuePoint.self,
                                           returning: [VenuePoint].self) {[unowned self] group in
                    template.viewTemplatePoints.forEach { point in
                        group.addTask {
                            await self.mainContext.perform {
                                let newVenuePoint: VenuePoint = self.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
                                newVenuePoint.fromTemplaPoint(point, context: self.mainContext)
                                return newVenuePoint
                            }
                        }
                    }
                    var result = [VenuePoint]()
                    for await res in group{
                        result.append(res)
                    }
                    
                    return result
                }
        }
        
        func cleanLocalPoints(_ points: [VenuePoint], inEvent event: Broadcast) async {
            await withTaskGroup(of: Void.self) {[unowned self] group in
                points.forEach { point in
                    group.addTask {
                        self.mainContext.perform {
                            self.mainContext.delete(point)
                        }
                    }
                }
            }
        }
    
//        func loadTemplatePoints(_ points:[TemplatePoint],
//                                toBroadcast broadcast: Broadcast) async {
//            await withTaskGroup(of: Void.self) {[unowned self] group in
//                points.forEach { point in
//                    group.addTask {
//                        self.mainContext.perform {
//                            let newVenuePoint: VenuePoint = self.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
//                            newVenuePoint.fromTemplaPoint(point, context: self.mainContext)
//                            broadcast.addToVenuePoints(newVenuePoint)
//                            newVenuePoint.broadcast = broadcast
//                        }
//                    }
//                }
//            }
//        }
    
        @MainActor
        func saveTemplateFromSchema(
            localPoints: [VenuePoint],
            withName name: String
        ) async {
            let template: Template = mainContext.fetchOrCreateObject(withID: name)
            let templatePoints:[TemplatePoint] =  localPoints.map { point in
                let newTemplatePoint: TemplatePoint = mainContext.fetchOrCreateObject(withID: UUID().uuidString)
                newTemplatePoint.fromVenuePoint(point)
                return newTemplatePoint
            }
            
            template.updateValues(name: name,
                                  lastUpdated: .now,
                                  templatePoints: templatePoints,
                                  in: mainContext)

            try? mainContext.save()
            
            await networkManager.saveData(
                template.dto,
                withId: template.viewId,
                withType: .templates
            )
        }
        
    @MainActor
        func removeLocalTemplate(_ template: Template) {
            let id = template.viewId
            mainContext.delete(template)
            //publish?
            try? mainContext.save()
            
            Task{
                await networkManager.removeDataOfType(
                    GlobalProperties.Path.templates,
                    withId: id
                )
            }
        }
    }
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
//}

// MARK: - Venue
extension DataManager{
    @MainActor
    func saveVenue(
        venue: Venue,
        title: String,
        address: String,
        schema: LocalImage?,
        images: [LocalImage] = []
    ){
        let idsToRemove = venue.viewLocalImages.compactMap{ venueImage in
            images.contains{image in
                image == venueImage
            } ? nil:(venueImage.viewId,venueImage.objectID)
        }
        let dataToSave = images.compactMap { image in
            venue.viewLocalImages.contains{ venueImage in
                venueImage == image
            } ? (image.viewId,image.makeUIImage()):nil
        }
        
        mainContext
            .performAndWait {
                //check images in venue
                venue
                    .updateValues(
                        title: title,
                        address: address,
                        lastUpdated: .now,
                        newBroadcastSchema: schema,
                        images: images,
                        in: mainContext
                    )
                
                try? mainContext
                    .save()
            }
        
        let dto = venue.dto
        let id = venue.viewId
        Task{
           await withTaskGroup(of: Void.self){ [unowned self] group in
               group
                   .addTask {
                       await self.networkManager
                           .saveData(
                            dto,
                            withId: id,
                            withType: GlobalProperties.Path.venues
                           )
                   }
               idsToRemove.forEach { id in
                   group.addTask {
                       await self.networkManager.removeImage(localImageId: id.0)
                   }
               }
               dataToSave.forEach { data in
                   if let uiimage = data.1{
                       group.addTask {
                           _ = await self.networkManager.saveImageToGlobalStorage(id: data.0, uiimage: uiimage, type: GlobalProperties.ImageType.venue)
                       }
                   }
               }
            }
        }
        removeImagesInBackground(ids: idsToRemove.map{$0.1})
    }
}
    
// MARK: - Image managment
extension DataManager {
    func removeImagesInBackground(ids:[NSManagedObjectID]){
        Task{
            await withTaskGroup(of: Void.self) { group in
                let context = persistentContainer.newBackgroundContext()
                    ids.forEach { id in
                        group.addTask {
                            context.perform {
                                context.delete(context.object(with: id))
                            }
                        }
                }
                await group.waitForAll()
                await context.perform {
                    try? context.save()
                }
            }
        }
    }
    
    @MainActor
    func createNewLocalImagesWith(uiimages: [UIImage],
                                  andType type: GlobalProperties.ImageType,
                                  linkToLocation location: Venue? = nil) -> [LocalImage] {
        mainContext.performAndWait {
            var result: [LocalImage] = []
            for uiimage in uiimages {
                let id = UUID().uuidString
                let image: LocalImage = mainContext.fetchOrCreateObject(withID: id)
                image.updateValues(type: type.rawValue,
                                   lastUpdated: .now,
                                   uiimage: uiimage,
                                   in: mainContext)
                if let location {
                    location.addToImages(image)
                    image.parentVenueImage = location
                }
                result.append(image)
            }
            return result
        }
    }
    
    
    //broadcast schema saving
    func saveImageInBackground(uiimage: UIImage?,
                               type: GlobalProperties.ImageType){
        if let uiimage{
            let context = persistentContainer.newBackgroundContext()
            context.performAndWait {
                let id = UUID().uuidString
                let image: LocalImage = context.fetchOrCreateObject(withID: id)
                image.updateValues(type: type.rawValue,
                                   lastUpdated: .now,
                                   uiimage: uiimage,
                                   in: mainContext)
                try? context.save()
                Task{
                    await networkManager
                        .saveImageToGlobalStorage(
                            id: id,
                            uiimage: uiimage,
                            type: type
                        )
                }
            }
        }
    }
    
    //remove venue aux
    func removeImages(ids: [String]){
        Task{
            await withTaskGroup(of: Void.self){ [unowned self] group in
                for id in ids{
                    group.addTask {
                        await self.networkManager.removeImage(localImageId: id)
                    }
                }
            }
        }
    }
    
    func updateImageWithId(_ id: String, type: GlobalProperties.ImageType, andUIImage uiimage: UIImage){
        Task{
            await networkManager.saveImageToGlobalStorage(id: id, uiimage: uiimage, type: type)
        }
    }
    
    @MainActor
    func removeImage(_ image: LocalImage, fromGlobal: Bool = false){
        let id = image.viewId
            mainContext.delete(image)
        if fromGlobal{
            Task{
                await networkManager.removeImage(localImageId: id)
            }
        }
    }

}

// MARK: - Remove object with ObjectId
extension DataManager{
    func removeObjectWithId(id: NSManagedObjectID){
        let context = persistentContainer.newBackgroundContext()
        context.performAndWait {
            let obj = context.object(with: id)
            context.delete(obj)
            try?  context.save()
        }
    }
}

// MARK: - Online status managment
extension DataManager {
    func changeOnlineStatus(isOnline: Bool,id: String) async {
        if isOnline {
            await networkManager.goOnline(id: id)
        } else {
            await networkManager.goOffline(id: id)
        }
    }
}

// MARK: - CoreDate Context
extension DataManager {
    
//    @MainActor
    func rollBackMoc() {
        mainContext.performAndWait {
            mainContext.rollback()
        }
    }
    
//    @MainActor
    func saveContext(publish: GlobalProperties.PublishChanges,
                     id: [String]) throws {
        mainContext.performAndWait {
            if mainContext.hasChanges {
                try? mainContext.save()
                if publish != .none {
                    self.updatePublisher.send((publish, id))
                }
            }
        }
    }
}



   

