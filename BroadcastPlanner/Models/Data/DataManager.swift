import UIKit
import CoreData

class DataManager {
    
    // MARK: - Properties
    
    static let shared = DataManager(forPreview: true)
//    static let sharedForTest = DataManager(forPreview: true)
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let moc: NSManagedObjectContext
    
    //caches for mapping coredata: [id: Entity]
//    var imageCache: [String: LocalImage] = [:]
//    
//    var usersCache: [String: LocalUser] = [:]
//    var eventCache: [String: LocalEvent] = [:]
//    
//    var locationCache: [String: LocalLocation] = [:]
//    var broadcasterCache: [String: LocalBroadcaster] = [:]
//    var obVanCache: [String: LocalOBVan] = [:]
//    
//    var clubCache: [String: LocalClub] = [:]
//    
//    //environment cache
//    var cameraCache: [String: LocalCamera] = [:]
//    var soundCache: [String: LocalSound] = [:]
//    var lightCache: [String: LocalLight] = [:]
//    var hardwareCache: [String: LocalHardware] = [:]
//    
//    //points cache
//    var locationPointsCache: [String: LocalLocationPoint] = [:]
//    var localOBVanUnitCache: [String: OBVanUnit] = [:]
    
    
    // MARK: - Init
    init(forPreview: Bool = false) {
        if forPreview {
            let modelUrl = Bundle.main.url(forResource: "BroadcastPlanner", withExtension: "momd")!
            let mom = NSManagedObjectModel(contentsOf: modelUrl)!
            self.persistentContainer =  NSPersistentContainer(name: "BroadcastPlanner",managedObjectModel: mom)
            let description = NSPersistentStoreDescription()
                   description.type = NSInMemoryStoreType // Используем in-memory хранилище
            self.persistentContainer.persistentStoreDescriptions = [description]
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            self.persistentContainer =  NSPersistentContainer(name: "BroadcastPlanner")
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.loadPersistentStores { _, _ in }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.moc = persistentContainer.viewContext
        
    }
}

// MARK: - User CRUD
// TODO: handle all linked data (images... e.t.c.)
extension DataManager {
    func fetchOrCreateUserWithId(_ id: String) -> LocalUser{
        let request = LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let newUser = try? moc.fetch(request).first{
            return newUser
        } else {
            let newUser = LocalUser(context: moc)
            newUser.id = id
            return newUser
        }
    }
    
    func createOrUpdateLocalUserWithUser(_ user: BPUser) -> LocalUser{
        let localUser = fetchOrCreateUserWithId(user.id)
        updateLocalUser(localUser, with: user)
        saveContext()
        return localUser
    }
    // map
    func updateLocalUser(_ localUser: LocalUser ,with bpUser: BPUser){
        localUser.firstName = bpUser.firstName
        localUser.lastName = bpUser.lastName
        localUser.isOnline = bpUser.isOnline
        localUser.phoneNumber = bpUser.phoneNumber
        localUser.email = bpUser.email
        localUser.homeAddress = bpUser.homeAddress
        localUser.specializations = bpUser.specialization.joined(separator: ",")
        localUser.creationDate = bpUser.creationDate.dateValue()
        localUser.leaveDate = bpUser.leaveDate.dateValue()
        let image = fetchOrCreateImageWithId(bpUser.id)
        localUser.image = image
        image.parentUser = localUser
        
    }
    //just for consistency, no scenario to delete user
    func removeUser(_ user: BPUser){
        let request = LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id)
        if let userToRemove = try? moc.fetch(request).first{
            removeLocalUser(userToRemove)
        } else {
            print("error removing local user with id = \(user.id)")
        }
    }
    
    func removeLocalUser(_ localUser: LocalUser){
        moc.delete(localUser)
        saveContext()
    }
}

// MARK: - Event CRUD
extension DataManager {
    func fetchOrCreateEventWithId(_ id: String) -> LocalEvent {
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let newEvent = try? moc.fetch(request).first{
            return newEvent
        } else {
            let newEvent = LocalEvent(context: moc)
            newEvent.id = id
            return newEvent
        }
    }
    
    func createOrUpdateLocalEventWithEvent(_ event: Event) -> LocalEvent{
        let localEvent = fetchOrCreateEventWithId(event.id)
        localEvent.id = event.id
        updateLocalEvent(localEvent, with: event)
        saveContext()
        return localEvent
    }
    
    func updateLocalEvent(_ localEvent: LocalEvent,with event: Event) {
        localEvent.date = event.date
        let broadcaster = fetchOrCreateBroadcasterWithId(event.broadcasterId)
        localEvent.broadcaster = broadcaster
        broadcaster.addToEvents(localEvent)
        
        let obvan = fetchOrCreateObvanWithId(event.obVanId)
        localEvent.obVan = obvan
        obvan.addToEvents(localEvent)
        
        let location = fetchOrCreateLocationWithId(event.locationID)
        localEvent.location = location
        location.addToEvents(localEvent)
        
        let homeClub = fetchOrCreateClubWithId(event.homeClubId)
        localEvent.homeClub = homeClub
        homeClub.addToHomeEvent(localEvent)
        
        let guestClub = fetchOrCreateClubWithId(event.guestClubId)
        localEvent.guestClub = guestClub
        guestClub.addToGuestEvent(localEvent)
        
        for ownerId in event.ownersIds{
            let user = fetchOrCreateUserWithId(ownerId)
            localEvent.addToOwners(user)
            user.addToOwnedEvents(localEvent)
            
        }
        for user in event.usersIds{
            let user = fetchOrCreateUserWithId(user)
            user.addToParticipateEvents(localEvent)
            localEvent.addToUsers(user)
            
        }
        for locationPoint in event.locationPoints {
            let point = createOrUpdateLocalPointWithLocationPoint(locationPoint)
            localEvent.addToLocationPoints(point)
            point.event = localEvent
            
        }
        for unit in event.obVanUnits{
            let localUnit = createOrUpdateLocalObvanUnitWithObvanUnit(unit)
            localEvent.addToObVanUnits(localUnit)
            localUnit.event = localEvent
        }
    }
    
    func removeEvent(_ event: Event) {
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id)
        if let eventToRemove = try? moc.fetch(request).first{
            removeLocalEvent(eventToRemove)
        } else {
            print("error removing event with id = \(event.id)")
        }
    }
    
    func removeLocalEvent(_ localEvent: LocalEvent){
        moc.delete(localEvent)
        saveContext()
    }
    
}

// MARK: - Image CRUD
extension DataManager {
    
    func fetchOrCreateImageWithId(_ id: String) -> LocalImage {
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let value = try? moc.fetch(request).first {
            return value
        } else {
            let newImage = LocalImage(context: moc)
            newImage.id = id
            return newImage
        }
    }
    
    func createOrUpdateLocalImageWithId(_ id: String,withImage image: UIImage) -> LocalImage{
        let localImage = fetchOrCreateImageWithId(id)
        updateLocalImage(localImage, withImage: image)
        return localImage
    }
    
    func updateLocalImage(_ localImage: LocalImage, withImage image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1){
            localImage.imageData = data
            saveContext()
        }
    }
    
    func removeImageWithId(_ id: String) {
        let request = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let imageToRemove = try? moc.fetch(request).first{
            removeLocalImage(imageToRemove)
        }
    }
    
    func removeLocalImage(_ localImage: LocalImage){
        moc.delete(localImage)
        saveContext()
    }
}

// MARK: - Location CRUD
extension DataManager {
    
    func fetchOrCreateLocationWithId(_ id: String) -> LocalLocation {
        let request = LocalLocation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let location = try? moc.fetch(request).first{
            return location
        } else {
            let newLocation = LocalLocation(context: moc)
            newLocation.id = id
            return newLocation
        }
    }
    
    func createOrUpdateLocalLocationWithLocation(_ location: Location) -> LocalLocation {
        let localLocation = fetchOrCreateLocationWithId( location.id)
        updateLocalLocation(localLocation, withLocation: location)
        saveContext()
        return localLocation
    }
    
    func updateLocalLocation(_ localLocation: LocalLocation,withLocation location: Location) {
        localLocation.title = location.title
        localLocation.address = location.address
        for id in location.imagesIds{
            let image = fetchOrCreateImageWithId(id)
            localLocation.addToImages(image)
            image.parentLocationImage = localLocation
        }
        let backgroundImage = fetchOrCreateImageWithId(location.locationBackground)
        localLocation.background = backgroundImage
        backgroundImage.parentLocationBackground = localLocation
    }
    
    func removeLocation(location: Location) {
        let request = LocalLocation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", location.id)
        if let locationToRemove = try? moc.fetch(request).first{
            removeLocalLocation(locationToRemove)
        }
    }
    
    func removeLocalLocation(_ location: LocalLocation){
        moc.delete(location)
        saveContext()
    }
}

// MARK: - Broadcaster / obVan CRUD
extension DataManager {
    //broadcaster
    func fetchOrCreateBroadcasterWithId(_ id: String) -> LocalBroadcaster {
        let request = LocalBroadcaster.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let localBroadcaster = try? moc.fetch(request).first{
            return localBroadcaster
        } else{
            let newBroadcaster = LocalBroadcaster(context: moc)
            newBroadcaster.id = id
            return newBroadcaster
        }
    }
    
    func createOrUpdateLocalBroadcasterWithBroadcaster(_ broadcaster: Broadcaster) -> LocalBroadcaster{
        let localBroadcaster = fetchOrCreateBroadcasterWithId(broadcaster.id)
        updateLocalBroadcaster(localBroadcaster, withBroadcaster: broadcaster)
        saveContext()
        return localBroadcaster
    }
    
    func updateLocalBroadcaster(_ localBroadcaster: LocalBroadcaster, withBroadcaster broadcaster: Broadcaster) {
        localBroadcaster.title = broadcaster.title
        for obVanId in broadcaster.obVanIds{
            let obVan = fetchOrCreateObvanWithId(obVanId)
            localBroadcaster.addToCars(obVan)
            obVan.broadcaster = localBroadcaster
            
        }
    }
    
    func removeBroadcaster(broadcaster: Broadcaster){
        let request = LocalBroadcaster.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", broadcaster.id)
        if let broadcasterToRemove = try? moc.fetch(request).first{
            removeLocalBroadcaster(broadcasterToRemove)
        }
    }
    
    func removeLocalBroadcaster(_ broadcaster: LocalBroadcaster){
        moc.delete(broadcaster)
        saveContext()
    }
    
    //obVan
    func fetchOrCreateObvanWithId(_ id: String) -> LocalOBVan {
        let request = LocalOBVan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let obvan = try? moc.fetch(request).first {
            return obvan
        } else {
            let newObvan = LocalOBVan(context: moc)
            newObvan.id = id
            return newObvan
        }
    }
    
    func createOrUpdateLocalObvanWithObvan(_ obvan: OBVan) -> LocalOBVan {
        let localObvan = fetchOrCreateObvanWithId(obvan.id)
        updateLocalObvan(localObvan, withObvan: obvan)
        saveContext()
        return localObvan
    }
    
    func updateLocalObvan(_ localObvan: LocalOBVan, withObvan obvan: OBVan) {
        localObvan.name = obvan.name
        let image = fetchOrCreateImageWithId(obvan.imageId)
        localObvan.image = image
        image.parentObVan = localObvan
        
    }
    
    func removeObvan(_ obvan: OBVan) {
        let request = LocalOBVan.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", obvan.id)
        if let obvanToRemove = try? moc.fetch(request).first{
            moc.delete(obvanToRemove)
            saveContext()
        }
    }
    
    func removeLocalObvan(_ obvan: LocalOBVan){
        moc.delete(obvan)
        saveContext()
    }
}

// MARK: - Club CRUD
extension DataManager {
    
    func fetchOrCreateClubWithId(_ id: String) -> LocalClub {
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let club = try? moc.fetch(request).first {
            return club
        } else {
            let newClub = LocalClub(context: moc)
            newClub.id = id
            return newClub
        }
    }
    
    func createOrUpdateLocalClubWithClub(_ club: Club) -> LocalClub{
        let localClub = fetchOrCreateClubWithId(club.id)
        updateLocalClub(localClub, withClub: club)
        saveContext()
        return localClub
    }
    
    func updateLocalClub(_ localClub: LocalClub, withClub club: Club) {
        localClub.title = club.title
        localClub.contacts = club.contacts
        localClub.urlString = club.urlString
        let image = fetchOrCreateImageWithId(club.id)
        localClub.imageLogo = image
        let location = fetchOrCreateLocationWithId(club.homeLocationID)
        localClub.homeLocation = location
        location.homeClub = localClub
        
    }
    
    func removeClub(club: Club) {
        let request = LocalClub.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", club.id)
        if let clubToRemove = try? moc.fetch(request).first{
            removeLocalClub(localClub: clubToRemove)
        }
    }
    
    func removeLocalClub(localClub: LocalClub) {
        moc.delete(localClub)
        saveContext()
    }
}

// MARK: - Environment CRUD
extension DataManager {
    //camera
    func fetchOrCreateCameraWithId(_ id: String) -> LocalCamera {
        let request = LocalCamera.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let localCamera = try? moc.fetch(request).first {
            return localCamera
        } else {
            let newCamera = LocalCamera(context: moc)
            newCamera.id = id
            return newCamera
        }
    }
    
    func createOrUpdateCamera(_ camera: Camera) -> LocalCamera{
        
        let localCamera = fetchOrCreateCameraWithId(camera.id)
        updateLocalCamera(localCamera, withCamera: camera)
        saveContext()
        return localCamera
    }
    func updateLocalCamera(_ localCamera: LocalCamera,withCamera camera: Camera) {
        localCamera.optic = camera.optic.rawValue
    }
    func removeCamera(camera: Camera) {
        let request = LocalCamera.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", camera.id)
        if let cameraToRemove = try? moc.fetch(request).first{
            removeLocalCamera(cameraToRemove)
        }
    }
    
    func removeLocalCamera(_ camera: LocalCamera){
        moc.delete(camera)
        saveContext()
    }
    //sound
    func fetchOrCreateSoundWithId(_ id: String) -> LocalSound {
        let request = LocalSound.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let localSound = try? moc.fetch(request).first {
            return localSound
        } else {
            let newSound = LocalSound(context: moc)
            newSound.id = id
            return newSound
        }
    }
    
    func createOrUpdateSound(_ sound: Sound) -> LocalSound {
        let localSound = fetchOrCreateSoundWithId(sound.id)
        updateLocalSound(localSound, withSound: sound)
        saveContext()
        return localSound
    }
    func updateLocalSound(_ localSound: LocalSound, withSound sound: Sound) {
        localSound.placeType = sound.placeType.rawValue
        localSound.windDefence = sound.windDefence.rawValue
    }
    func removeSound(sound: Sound) {
        let request = LocalSound.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", sound.id)
        if let soundToRemove = try? moc.fetch(request).first{
            removeLocalSound(soundToRemove)
        }
    }
    
    func removeLocalSound(_ sound: LocalSound){
        moc.delete(sound)
        saveContext()
    }
    //light
    
    func fetchOrCreateLightWithId(_ id: String) -> LocalLight {
        let request = LocalLight.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let light = try? moc.fetch(request).first {
            return light
        } else {
            let newLight = LocalLight(context: moc)
            newLight.id = id
            return newLight
        }
    }
    
    func createOrUpdateLocalLightWithLight(_ light: Light) -> LocalLight{
        let localLight = fetchOrCreateLightWithId(light.id)
        updateLocalLight(localLight, withLight: light)
        saveContext()
        return localLight
    }
    
    func updateLocalLight(_ localLight: LocalLight, withLight light: Light){
        localLight.lightType = light.lightType.rawValue
    }
    
    func removeLight(light: Light){
        let request = LocalLight.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", light.id)
        if let lightToRemove = try? moc.fetch(request).first{
            removeLocalLight(lightToRemove)
        }
    }
    
    func removeLocalLight(_ light: LocalLight){
        moc.delete(light)
        saveContext()
    }
    
    //hardware
    func fetchOrCreateHardwareWithId(_ id: String) -> LocalHardware {
        let request = LocalHardware.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let localHardware = try? moc.fetch(request).first {
            return localHardware
        } else {
            let newHardware = LocalHardware(context: moc)
            newHardware.id = id
            return newHardware
        }
    }
    
    func createOrUpdateLocalHardwareWithHardware(_ hardware: Hardware) -> LocalHardware{
        let localHardware = fetchOrCreateHardwareWithId(hardware.id)
        updateLocalHardware(localHardware, withHardware: hardware)
        saveContext()
        return localHardware
    }
    
    func updateLocalHardware(_ localHardware: LocalHardware,withHardware hardware: Hardware){
        localHardware.type = hardware.envType.rawValue
        localHardware.channels = hardware.chanels.joined(separator: ",")
    }
    
    func removeHardware(_ hardware: Hardware){
        let request = LocalHardware.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hardware.id)
        if let hardwareToRemove = try? moc.fetch(request).first{
            removeLocalHardware(hardwareToRemove)
        }
    }
    
    func removeLocalHardware(_ localhardware: LocalHardware){
        moc.delete(localhardware)
        saveContext()
    }
}

// MARK: - Location Points OBVan Units CRUD
extension DataManager {
    //location point
    func fetchOrCreateLocationPointWithId(_ id: String) -> LocalLocationPoint {
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let localPoint = try? moc.fetch(request).first{
            return localPoint
        } else {
            let newPoint = LocalLocationPoint(context: moc)
            newPoint.id = id
            return newPoint
        }
    }
    
    func createOrUpdateLocalPointWithLocationPoint(_ point: LocationPoint) -> LocalLocationPoint{
        let localPoint = fetchOrCreateLocationPointWithId(point.id)
        updateLocalPoint(localPoint, withLocationPoint: point)
        saveContext()
        return localPoint
    }
    func updateLocalPoint(_ localPoint: LocalLocationPoint,withLocationPoint point:LocationPoint){
        localPoint.coordinateX = Float(point.coordinateX)
        localPoint.coordinateY = Float(point.coordinateY)
        localPoint.rotation = Int16(point.rotation)
        localPoint.number = Int16(point.number)
        
        let image = fetchOrCreateImageWithId(point.imageId)
        localPoint.image = image
        image.addToLocationPoint(localPoint)
        
        localPoint.pointDescription = point.description
        localPoint.task = point.task
        
        if let id = point.userId{
            let user = fetchOrCreateUserWithId(id)
            localPoint.addToUser(user)
            user.addToLocationPoints(localPoint)
        }
        for sound in point.sounds{
            let localSound = createOrUpdateSound(sound)
            localPoint.addToSounds(localSound)
            localSound.point = localPoint
        }
        for cam in point.cameras{
            let camera = createOrUpdateCamera(cam)
            localPoint.addToCameras(camera)
            camera.point = localPoint
            
        }
        for light in point.lights{
            let localLight = createOrUpdateLocalLightWithLight(light)
            localPoint.addToLights(localLight)
            localLight.point = localPoint
        }
        
    }
    func removeLocationPoint(_ point: LocationPoint) {
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", point.id)
        if let pointToRemove = try? moc.fetch(request).first{
            removeLocalLocationPoint(pointToRemove)
        }
    }
    
    func removeLocalLocationPoint(_ localPoint: LocalLocationPoint){
        moc.delete(localPoint)
        saveContext()
    }
    
    //Obvan unit
    func fetchOrCreateObvanUnitWithId(_ id: String) -> LocalOBVanUnit {
        let request = LocalOBVanUnit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let value = try? moc.fetch(request).first{
            return value
        } else {
            let newUnit = LocalOBVanUnit(context: moc)
            newUnit.id = id
            return newUnit
        }
    }
    
    func createOrUpdateLocalObvanUnitWithObvanUnit(_ obvanUnit: OBVanUnit) -> LocalOBVanUnit{
        let localUnit = fetchOrCreateObvanUnitWithId(obvanUnit.id)
        updateLocalUnit(localUnit, withUnit: obvanUnit)
        return localUnit
    }
    
    func updateLocalUnit(_ localUnit: LocalOBVanUnit,withUnit unit: OBVanUnit) {
        localUnit.position = unit.position.rawValue
        localUnit.coordinateX = Float(unit.coordinateX)
        localUnit.coordinateY = Float(unit.coordinateY)
        localUnit.rotation = Int16(unit.rotation)
        let user = fetchOrCreateUserWithId(unit.userId)
        localUnit.user = user
        user.addToObVanUnits(localUnit)
        for hardware in unit.hardwares {
            let hardware = fetchOrCreateHardwareWithId(hardware.id)
            localUnit.hardware = hardware
            hardware.obVanUnit = localUnit
        }
        saveContext()
    }
    
    func removeObvanUnit(unit: OBVanUnit){
        let request = LocalOBVanUnit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", unit.id)
        if let unitToRemove = try? moc.fetch(request).first{
            removeLocalObvanUnit(unitToRemove)
        }
    }
    
    func removeLocalObvanUnit(_ unit: LocalOBVanUnit){
        moc.delete(unit)
        saveContext()
    }
}

// MARK: - Save context
extension DataManager{
    func saveContext(){
        if moc.hasChanges {
            do{
                try moc.save()
            } catch {
                print("error save context: \(error.localizedDescription)")
            }
        }
    }
}

#if DEBUG
// MARK: - Mock data
extension DataManager{
    func addMockData(){
        
        
        
    }
}
#endif
