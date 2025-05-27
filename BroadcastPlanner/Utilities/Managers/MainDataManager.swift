import CoreData
import Combine
import UIKit

class MainDataManager: ObservableObject {

    let localDataManager: DataManager
    let globalDataManager: NetworkManager

    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
    var cancellables: Set<AnyCancellable> = []
    
    let currentId: String
    let currentUser: Member

    init(
        localDataManager: DataManager,
        globalDataManager: NetworkManager,
        userId: String
    ) {
        self.localDataManager = localDataManager
        self.globalDataManager = globalDataManager
        self.currentId = userId
        self.currentUser = localDataManager.fetchOrCreateObject(
            ofType: Member.self,
            predicate: NSPredicate(format: "id == %@", userId),
            in: localDataManager.mainContext
        ) { ctx in
            let newUser = Member(context: ctx)
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
    
    func updateWithDTO(_ dto: any CoreDataRepresentable){
        dto.updateOrCreate(in: localDataManager.backgroundContext)
    }
    func removeWithDTO(_ dto: any CoreDataRepresentable){
        
    }
    
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
    
    func updateEvents(dtos: [BroadcastDTO]) {
        print("broadcasts updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Broadcast.fetchRequest()
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
                localDataManager.saveContextSync(type: .bg, publish: .broadcasts, id: dtos.map{$0.id})
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
    
    func updateLocations(dtos: [VenueDTO]) {
        print("venues updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Venue.fetchRequest()
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
                localDataManager.saveContextSync(type: .bg, publish: .venues, id: dtos.map{$0.id})
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
    
    func updateUsers(dtos: [MemberDTO]) {
        print("members updated: \(dtos)")
        localDataManager.backgroundContext.performAndWait {
            let request = Member.fetchRequest()
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
                self.localDataManager.saveContextSync(type: .bg, publish: .members, id: dtos.map{$0.id})
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
                case is MemberDTO:
                    print("isLocalUser")
                    if let dto = value as? MemberDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalUserWithUserDTO(dto, inContext: .bg)
                        } else {
                            localDataManager.removeUserWithDTO(dto, inContext: .bg)
                        }
                        type = .members
                        publishId = dto.id
                    }
                case is BroadcastDTO:
                    print("isEvent")
                    if let dto = value as? BroadcastDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalEventWithEventDTO(dto, inContext: .bg)
                        } else {
                            print("procees with broadcast listener")
                            localDataManager.removeEventWithDTO(dto, inContext: .bg)
                        }
                        type = .broadcasts
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
                case is VenueDTO:
                    print("isLocation")
                    if let dto = value as? VenueDTO{
                        if updated {
                            _ = localDataManager.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .bg)
                        } else {
                            localDataManager.removeLocationWithDTO(dto, inContext: .bg)
                        }
                        type = .venues
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
    //creates new member cloud entity
    @MainActor
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
                    localImage.parentMember = currentUser
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
                    localImage.parentMember = currentUser
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
        -> Broadcast {
        let event = localDataManager.fetchOrCreateObject(
            ofType: Broadcast.self,
            predicate: NSPredicate(format: "id == %@", UUID().uuidString),
            in: localDataManager.mainContext
        ) { ctx in
            let newEvent = Broadcast(context: ctx)
            newEvent.id = UUID().uuidString
            return newEvent
        }
        //link broadcast to member
        localDataManager.contextFromType(type).perform { [weak self] in
            guard let self else { return }
            event.addToOwners(self.currentUser)
            currentUser.addToOwnedEvents(event)
        }
            saveContextSync(type: .main, publish: GlobalProperties.PublishChanges.broadcasts, id: [])
        return event
    }
    @MainActor
    func updateEvent(
        _ event: Broadcast,
        homeClub: Club?,
        guestClub: Club?,
        eventDate: Date,
        location: Venue?) async {
        //coreData save
        await localDataManager.mainContext.perform { [weak self] in
            guard let self else { return }
            event.homeClub = homeClub
            event.guestClub = guestClub
            event.date = eventDate
            event.venue = location
            event.addToOwners(self.currentUser)
        }
        await saveContextAsync(type: .main, publish: .broadcasts, id: [event.viewId])

        //network save
        await globalDataManager.saveData(
            event.dto,
            withId: event.viewId,
            withType: GlobalProperties.Path.broadcasts
        )
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
                        type: GlobalProperties.ImageType.locationPreview
                            .rawValue,
                        lastUpdated: .now
                    ),
                    withImage: image,
                    inContext: .main
                )
            localDataManager.mainContext.performAndWait {
                event.locationPreview = localImage
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
                    point.removeFromUser(userToRemove)
                    userToRemove.removeFromPoints(point)
                    if let event = point.broadcast {
                        event.removeFromUsers(userToRemove)
                        userToRemove.removeFromParticipateEvents(event)
                    } else {
                        print("event in venuePoint error occured")
                    }
                }
            if let user{
                //add new member
                point.addToUser(user)
                user.addToPoints(point)
                if let event = point.broadcast {
                    user.addToParticipateEvents(event)
                    event.addToUsers(user)
                } else {
                    print("event in venuePoint error occured")
                }
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
                point.addToUser(user)
                user.addToPoints(point)
                if let event = point.broadcast {
                    user.addToParticipateEvents(event)
                    event.addToUsers(user)
                } else {
                    print("event in venuePoint error occured")
                }
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
                point.removeFromUser(user)
                user.removeFromPoints(point)
                if let event = point.broadcast {
                    event.removeFromUsers(user)
                    user.removeFromParticipateEvents(event)
                } else {
                    print("event in venuePoint error occured")
                }
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
            event.addToPoints(newPoint)
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
        localDataManager.mainContext.perform {
            if let event = unit.broadcast, let user = unit.member {
                user.removeFromParticipateEvents(event)
                event.removeFromUsers(user)
            }
        }
        localDataManager.removeLocalUnit(unit, inContext: .main)
    }
    func createUnitWithUser(
        _ user: Member,
        andSpecialization specialization: UserSpecialization,
        andHardware hardware: ReplayType?,
        inEvent event: Broadcast
    ) -> Crew {
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
