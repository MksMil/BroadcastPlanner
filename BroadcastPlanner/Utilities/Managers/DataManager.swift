import CoreData
import Combine
import UIKit
import SwiftUI

class DataManager: ObservableObject {

    let persistentContainer: NSPersistentContainer
    let networkManager: NetworkManager
    let imageCacher: ImageCacher
    let mainContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext

    
    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
//    var cancellables: Set<AnyCancellable> = []
    
    @Published var currentId: String = ""
//    {
//        willSet{
//            if !newValue.isEmpty{
//                updatePublisher.send((GlobalProperties.PublishChanges.images, [newValue])) //update profile image in status view
//            }
//        }
//    }
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
        self.mainContext = persistentContainer.viewContext
        mainContext.mergePolicy =
        NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent =
        true
        self.backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy =
        NSMergeByPropertyObjectTrumpMergePolicy
 
        self.imageCacher = ImageCacher()
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
    ///snapshot listener use this to update objects
    func updateWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO){
        backgroundContext.performAndWait {
            let object: DTO.Entity = backgroundContext.fetchOrCreateObject(withID: dto.id)
            object.updateFromDTO(dto, in: backgroundContext)
            if let image = object as? LocalImage {
                if dto.lastUpdated != image.viewLastUpdated{
                    let id = image.viewId
                    let type = image.viewType
                    image.lastUpdated = dto.lastUpdated
                    Task{
                        if let result = await networkManager.loadImage(from: id){
                           await imageCacher.saveImage(uiimage: result, id: id, type: type)
                        }
                    }
                }
            }
            try? backgroundContext.save()
        }
    }
    ///snapshot listener use this to remove objects
    func removeWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO){
        backgroundContext.performAndWait {
            dto.remove(in: backgroundContext)
            try? backgroundContext.save()
        }
    }
    
    /// network manager use this to sync objects at the start app - update/create or remove that not exists in background
    func sync<DTO: CoreDataRepresentable>(with dtos: [DTO]) {
        backgroundContext.performAndWait {
            createOrUpdate(dtos: dtos, in: backgroundContext)
            removeMissing(dtos: dtos,in: backgroundContext)
            try? backgroundContext.save()
        }
    }
       
       ///Create / update objects from DTO's
    func createOrUpdate<DTO: CoreDataRepresentable>(dtos: [DTO],in context: NSManagedObjectContext) {
        context.performAndWait {
            for dto in dtos {
                let object: DTO.Entity = context.fetchOrCreateObject(withID: dto.id)
                object.updateFromDTO(dto, in: context)
                if let image = object as? LocalImage {
                    if dto.lastUpdated != image.viewLastUpdated{
                        let id = image.viewId
                        let type = image.viewType
                        image.lastUpdated = dto.lastUpdated
                        Task{
                            if let result = await networkManager.loadImage(from: id){
                                await imageCacher.saveImage(uiimage: result, id: id, type: type)
                            }
                        }
                    }
                }
            }
        }
    }
    
       /// Удаляет объекты Core Data, которых нет среди DTO.id
    func removeMissing<DTO: CoreDataRepresentable>(dtos: [DTO],in context: NSManagedObjectContext) {
        let ids = dtos.map { $0.id }
        let request = DTO.Entity.fetchRequest()
        request.predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        do {
            if let toDelete = try context.fetch(request) as? [DTO.Entity] {
                let toDeleteIds = toDelete.compactMap{$0.id}
                toDelete.forEach {
                    print($0)
                    context.delete($0)
                }
                try? context.save()
                if DTO.self is ImageDTO.Type{
                    toDeleteIds.forEach { id in
                        Task{
                            await imageCacher.removeImage(id: id)
                        }
                    }
                }
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
    
    //TODO: fix new user reation, local image must be created
    func createUser(id: String) async {
        let userDTO = MemberDTO(id: id)
        await networkManager.saveData(
            userDTO,
            withId: id,
            withType: GlobalProperties.Path.members
        )
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
                if !venuePreview.viewId.isEmpty, let uiimage = await imageCacher.getOrigin(id: venuePreview.viewId){
                    _ = await networkManager.saveImageToGlobalStorage(id: venuePreview.viewId,
                                                                      uiimage: uiimage,
                                                                      type: GlobalProperties.ImageType.venuePreview,
                                                                      lastUpdated: broadcast.viewLastUpdated)
                }
            }
            
            for obvanPreview in broadcast.viewObvanPreviews{
                await networkManager.saveData(obvanPreview.dto,
                                              withId: obvanPreview.viewId,
                                              withType: GlobalProperties.Path.images)
                if !obvanPreview.viewId.isEmpty, let uiimage = await imageCacher.getOrigin(id: obvanPreview.viewId){
                    _ = await networkManager.saveImageToGlobalStorage(id: obvanPreview.viewId,
                                                                      uiimage: uiimage,
                                                                      type: GlobalProperties.ImageType.obvanPreview,
                                                                      lastUpdated: broadcast.viewLastUpdated)
                }
            }
        }
    @MainActor
    func removeBroadcast(_ broadcast: Broadcast) async {
        let id = broadcast.viewId
        if let previewId = broadcast.venueSchemaPreview?.viewId{
            await imageCacher.removeImage(id: id)
            await networkManager.removeDataOfType(
                GlobalProperties.Path.images,
                withId: previewId
            )
            await networkManager.removeImage(localImageId: previewId)
        }
        for previewObvan in broadcast.viewObvanPreviews{
            await imageCacher.removeImage(id: previewObvan.viewId)
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
                ImageDTO(id: broadcast.viewId,
                         type: GlobalProperties.ImageType.venuePreview.rawValue,
                         lastUpdated: .now)
            )
            localImage.lastUpdated = Date.now
            broadcast.venueSchemaPreview = localImage
            localImage.parentVenuePreview = broadcast
            try? saveContext(publish: .images, id:[])
            Task{
                await imageCacher.saveImage(uiimage: image, id: broadcast.viewId, type: GlobalProperties.ImageType.venuePreview)
            }
        }
    }
}
    // MARK: - Points managment
    extension DataManager {
    
        @MainActor
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
        
        @MainActor
        func deleteObject(_ object: NSManagedObject) {
            mainContext.performAndWait {
                mainContext.delete(object)
            }
            
//TODO:            removeLocalLocationPoint(point, inContext: .main)
        }
    }

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
        
        @MainActor
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
    

protocol ImageParent {
    func assignImage(image: LocalImage, ofType: GlobalProperties.ImageType)
}
// MARK: - Image managment
extension DataManager {
    
    func saveNewImage(id: String = UUID().uuidString,uiimage: UIImage?, type: GlobalProperties.ImageType, parent: ImageParent?,lastUpdated: Date = Date.now) async {
        //save to cache
        guard let uiimage, !id.isEmpty else { return }
        await imageCacher.saveImage(uiimage: uiimage, id: id, type: type)
        //make localImage & publish
         mainContext.performAndWait {
            let localImage = LocalImage(context: self.mainContext)
            localImage.id = id
            localImage.type = type.rawValue
            localImage.lastUpdated = lastUpdated
            
            ///linking image and parent
            if let parent {
                parent.assignImage(image: localImage, ofType: type)
            }
            
            try? self.saveContext(publish: GlobalProperties.PublishChanges.images, id: [id])
        }
        //network save
        Task{
            await networkManager.saveImageToGlobalStorage(id: id, uiimage: uiimage, type: type, lastUpdated: lastUpdated)
        }
   }
    
    func updateImageWith(uiimage: UIImage, id: String,type: GlobalProperties.ImageType,lastUpdated: Date) async{
            await imageCacher.saveImage(uiimage: uiimage, id: id, type: type)
           _ = await networkManager.saveImageToGlobalStorage(id: id, uiimage: uiimage, type: type, lastUpdated: lastUpdated)
    }
    
    func getImageWithId(_ id: String, type: GlobalProperties.ImageType, size: ImageSizes) async -> UIImage?{
        if let image = await imageCacher.getImage(id: id, size: size){
            return image
        } else {
            print("try to load image \(id) from  firebase")
            if let newImage = await self.networkManager.loadImage(from: id){
                print("image loaded from firebase")
                await imageCacher.saveImage(uiimage: newImage, id: id, type: type)
                return newImage
            } else {
                print("image not loaded from firebase")
                return nil
            }
        }
    }
    
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
                Task{
                    await imageCacher.saveImage(uiimage: uiimage, id: id, type: GlobalProperties.ImageType.venue)
                }
                let image: LocalImage = mainContext.fetchOrCreateObject(withID: id)
                image.updateValues(type: type.rawValue,
                                   lastUpdated: .now,
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
                let lastUpdated = Date.now
                let image: LocalImage = context.fetchOrCreateObject(withID: id)
                image.updateValues(type: type.rawValue,
                                   lastUpdated: lastUpdated,
                                   in: mainContext)
                try? context.save()
                Task{
                    await imageCacher.saveImage(uiimage: uiimage, id: id,
                                               type: type)
                    _ = await networkManager.saveImageToGlobalStorage(id: id,
                                                                      uiimage: uiimage,
                                                                      type: type,
                                                                      lastUpdated: lastUpdated)
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
    
    func updateImageWithId(_ id: String, type: GlobalProperties.ImageType, andUIImage uiimage: UIImage, lastUpdated: Date){
        Task{
            await networkManager.saveImageToGlobalStorage(id: id, uiimage: uiimage, type: type,lastUpdated: lastUpdated)
        }
    }
    
    @MainActor
    func removeImage(_ image: LocalImage, fromGlobal: Bool = false){
        let id = image.viewId
        mainContext.delete(image)
        try? mainContext.save()
        Task{
           await imageCacher.removeImage(id: id)
        }
        if fromGlobal{
            Task{
                await networkManager.removeImage(localImageId: id)
            }
        }
    }
    @MainActor
    func removeImageWithId(id: String){
        let imageToRemove:LocalImage = mainContext.fetchOrCreateObject(withID: id)
        mainContext.delete(imageToRemove)
        try? mainContext.save()
        Task{
            await imageCacher.removeImage(id: id)
            await networkManager.removeImage(localImageId: id)
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
    
    @MainActor
    func save(){
        try? mainContext.save()
    }
    
    func saveContext(publish: GlobalProperties.PublishChanges,
                     id: [String]) throws {
        mainContext.performAndWait {
            if mainContext.hasChanges {
                try? mainContext.save()
                if publish != .none {
                    print("publishing changes \(publish.rawValue) with id \(id)")
                    self.updatePublisher.send((publish, id))
                }
            }
        }
    }
}



   

