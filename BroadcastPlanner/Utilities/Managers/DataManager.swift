//import Combine
//import CoreData
//import UIKit
//
//enum ContextType { case main, bg }
//
//class DataManager: ObservableObject {
//    // MARK: - Properties
//    //publishing (type of data & array of id's) of changed elements, for views updates if needed (like current member in session)
//    var updatePublisher: PassthroughSubject = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()
//
//    var cancellables: Set<AnyCancellable> = []
//
//    let persistentContainer: NSPersistentContainer
//    
//    var mainContext: NSManagedObjectContext
//    var backgroundContext: NSManagedObjectContext
//    
//    // MARK: - Init
//    init(forPreview: Bool = false,
//         name: String = "BroadcastPlanner") {
//        self.persistentContainer = NSPersistentContainer(name: name)
//        if forPreview {
//            let description = NSPersistentStoreDescription()
//            description.type = NSInMemoryStoreType
//            self.persistentContainer.persistentStoreDescriptions = [description]
//        }
//        persistentContainer.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Failed to load store: \(error)")
//            }
//            print("[CoreData] Store type: \(description.type)")
//        }
//
//        persistentContainer.viewContext.mergePolicy =
//            NSMergeByPropertyObjectTrumpMergePolicy
//        persistentContainer.viewContext.automaticallyMergesChangesFromParent =
//            true
//
//        self.backgroundContext = persistentContainer.newBackgroundContext()
//        self.backgroundContext.mergePolicy =
//            NSMergeByPropertyObjectTrumpMergePolicy
//        self.backgroundContext.automaticallyMergesChangesFromParent = true
//
//        self.mainContext = persistentContainer.viewContext
//    }
//}
//// MARK: - Generics
//extension DataManager {
//    func fetchOrCreateObject<T: NSManagedObject>(
//        ofType type: T.Type,
//        predicate: NSPredicate,
//        in context: NSManagedObjectContext,
//        initializer: (NSManagedObjectContext) -> T
//    ) -> T {
//        let request = T.fetchRequest()
//        request.predicate = predicate
//        if let result = try? context.fetch(request).first as? T {
//            return result
//        } else {
//            return initializer(context)
//        }
//    }
//}
//// MARK: - User CRUD
//extension DataManager {
//    func createOrUpdateLocalUserWithUserDTO(_ user: MemberDTO,
//                                            inContext contextType: ContextType) -> Member {
//        let context = contextFromType(contextType)
//        var localUser: Member!
//        context.performAndWait{
//            localUser = fetchOrCreateObject(ofType: Member.self,
//                                            predicate: NSPredicate(format: "id == %@",
//                                                                   user.id),
//                                            in: context ) { ctx in
//                let newUser = Member(context: ctx)
//                newUser.id = user.id
//                return newUser
//            }
//            updateLocalUser(localUser, withUserDTO: user, inContext: contextType)
//        }
//        return localUser
//    }
//    func updateLocalUser(_ localUser: Member,
//                         withUserDTO userDto: MemberDTO,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait { [weak self] in
//            guard let self else { return }
//            localUser.id = userDto.id
//            localUser.accessLevel = Int16(userDto.accessLevel)
//            localUser.lastUpdated = userDto.lastUpdated
//            localUser.firstName = userDto.firstName
//            localUser.lastName = userDto.lastName
//            localUser.isOnline = userDto.isOnline
//            localUser.phoneNumber = userDto.phoneNumber
//            localUser.email = userDto.email
//            localUser.homeAddress = userDto.homeAddress
//            localUser.specializations = userDto.specialization.joined(
//                separator: ",")
//            localUser.creationDate = userDto.creationDate
//            localUser.leaveDate = userDto.leaveDate
//            let image = self.fetchOrCreateObject(ofType: LocalImage.self,
//                                                 predicate: NSPredicate(format: "id == %@", userDto.id),
//                                                 in: context) { ctx in
//                let newImage = LocalImage(context: ctx)
//                newImage.id = userDto.id
//                return newImage
//            }
//            localUser.image = image
//            image.parentMember = localUser
//        }
//    }
//    func removeUserWithDTO(_ user: MemberDTO,
//                           inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait{
//            let request = Member.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", user.id)
//            if let userToRemove = try? context.fetch(request).first {
//                self.removeLocalUser(userToRemove, inContext: contextType)
//            } else {
//                print("error removing local member with id = \(user.id)")
//            }
//        }
//    }
//    func removeLocalUser(_ localUser: Member,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        if let imageToRemove = localUser.image {
//            self.removeLocalImage(imageToRemove, inContext: contextType)
//        }
//        context.performAndWait { context.delete(localUser) }
//    }
//    

//}
//
//// MARK: - Broadcast CRUD
//extension DataManager {
//    func createOrUpdateLocalEventWithEventDTO(_ event: BroadcastDTO,
//                                              inContext contextType: ContextType)  -> Broadcast {
//        let context = contextFromType(contextType)
//        var localEvent: Broadcast!
//         context.performAndWait{
//            localEvent = fetchOrCreateObject(
//                ofType: Broadcast.self,
//                predicate: NSPredicate(format: "id == %@", event.id),
//                in: context) { ctx in
//                    let newEvent = Broadcast(context: ctx)
//                    newEvent.id = event.id
//                    return newEvent
//                }
//             updateLocalEvent(localEvent,
//                                   withDTO: event,
//                                   inContext: contextType)
//        }
//        return localEvent
//    }
//    func updateLocalEvent( _ localEvent: Broadcast,
//                           withDTO eventDto: BroadcastDTO,
//                           inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localEvent.date = eventDto.date
//            localEvent.id = eventDto.id
//            localEvent.lastUpdated = eventDto.lastUpdated
////            if let obvanId = eventDto.obvanId {
////                let obvan = self.fetchOrCreateObject(
////                    ofType: Obvan.self,
////                    predicate: NSPredicate(format: "id == %@", obvanId),
////                    in: context) { ctx in
////                        let newObvan = Obvan(context: ctx)
////                        newObvan.id = obvanId
////                        return newObvan
////                    }
////                localEvent.obvan = obvan
////                obvan.addToBroadcasts(localEvent)
////            }
//            if let locationID = eventDto.venueID {
//                let location = self.fetchOrCreateObject(
//                    ofType: Venue.self,
//                    predicate: NSPredicate(format: "id == %@", locationID),
//                    in: context
//                ) { ctx in
//                    let newLocation = Venue(context: ctx)
//                    newLocation.id = locationID
//                    return newLocation
//                }
//                localEvent.venue = location
//                location.addToBroadcasts(localEvent)
//            }
//            if let homeClubId = eventDto.homeClubId {
//                let homeClub = self.fetchOrCreateObject(ofType: Club.self,
//                                                        predicate: NSPredicate(format: "id == %@", homeClubId),
//                                                        in: context) { ctx in
//                    let newClub = Club(context: ctx)
//                    newClub.id = homeClubId
//                    return newClub
//                }
//                localEvent.homeClub = homeClub
//                homeClub.addToHomeBroadcasts(localEvent)
//            }
//            if let guestClubId = eventDto.guestClubId {
//                let guestClub = self.fetchOrCreateObject(
//                    ofType: Club.self,
//                    predicate: NSPredicate(format: "id == %@", guestClubId),
//                    in: context) { ctx in
//                        let newClub = Club(context: ctx)
//                        newClub.id = guestClubId
//                        return newClub
//                    }
//                localEvent.guestClub = guestClub
//                guestClub.addToGuestBroadcasts(localEvent)
//            }
//            if let locationPreviewId = eventDto.venuePreviewId {
//                let localImage = self.fetchOrCreateObject(ofType: LocalImage.self,
//                                                          predicate: NSPredicate(
//                                                            format: "id == %@",
//                                                            locationPreviewId
//                                                          ),
//                                                          in: context) { ctx in
//                    let newImage = LocalImage(context: ctx)
//                    newImage.id = locationPreviewId
//                    return newImage
//                }
//                localEvent.venueSchemaPreview = localImage
//                localImage.parentVenuePreview = localEvent
//            }
//            if let obvanPreviewId = eventDto.obvanPreviewId {
//                let localImage = self.fetchOrCreateObject(ofType: LocalImage.self,
//                                                          predicate: NSPredicate(format: "id == %@", obvanPreviewId),
//                                                          in: context) { ctx in
//                    let newImage = LocalImage(context: ctx)
//                    newImage.id = obvanPreviewId
//                    return newImage
//                }
//                localEvent.obvanPreview = localImage
//                localImage.parentObvanPreview = localEvent
//            }
//            for ownerId in eventDto.ownersIds {
//                let user = self.fetchOrCreateObject(ofType: Member.self,
//                                                    predicate: NSPredicate(format: "id == %@", ownerId),
//                                                    in: context) { ctx in
//                    let newUser = Member(context: ctx)
//                    newUser.id = ownerId
//                    return newUser
//                }
//                localEvent.addToOwners(user)
//                user.addToOwnedBroadcasts(localEvent)
//            }
//            
//            for locationPoint in eventDto.venuePoints {
//                let point = self.createOrUpdateLocalPointWithPointDTO(
//                    locationPoint,
//                    inContext: contextType
//                )
//                localEvent.addToVenuePoints(point)
//                point.broadcast = localEvent
//            }
//            for unit in eventDto.crews {
//                let localUnit = self.createOrUpdateLocalUnitWithUnitDTO(unit,
//                                                                        inContext: contextType)
//                localEvent.addToCrews(localUnit)
//                localUnit.broadcast = localEvent
//            }
//        }
//    }
//        @MainActor
//    func removeEventWithDTO(_ event: BroadcastDTO,
//                            inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait{
//            let request = Broadcast.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", event.id)
//            if let eventToRemove = try? context.fetch(request).first {
//                print("broadcast with id: \(event.id) removed")
//                self.removeLocalEvent(eventToRemove,
//                                      inContext: contextType)
//            } else {
//                print("error removing broadcast with id = \(event.id)")
//            }
//        }
//    }
//    
//    func removeLocalEvent(_ localEvent: Broadcast,
//                          inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            for locationPoint in localEvent.viewVenuePoints {
//                self.removeLocalLocationPoint(locationPoint,
//                                              inContext: contextType)
//            }
//            for unit in localEvent.viewCrews {
//                self.removeLocalUnit(unit, inContext: contextType)
//            }
//            if let eventPreview = localEvent.venueSchemaPreview {
//                self.removeLocalImage(eventPreview,
//                                      inContext: contextType)
//            }
//            if let obvanPreview = localEvent.obvanPreview {
//                self.removeLocalImage(obvanPreview,
//                                      inContext: contextType)
//            }
//            context.delete(localEvent)
//        }
//    }
//}
//// MARK: - Image CRUD
//extension DataManager {
//    func fetchImagesByType(_ type: GlobalProperties.ImageType,
//                           inContext contextType: ContextType) -> [LocalImage] {
//        let request = LocalImage.fetchRequest()
//        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
//        let context = contextFromType(contextType)
//        return context.performAndWait {
//            return (try? context.fetch(request)) ?? []
//        }
//    }
//
//    func createOrUpdateLocalImageWithId(_ id: String,
//                                        withImage image: UIImage,
//                                        andType type: GlobalProperties.ImageType,
//                                        inContext contextType: ContextType) -> LocalImage {
//        let context = contextFromType(contextType)
//        var localImage: LocalImage!
//        context.performAndWait {
//            localImage = fetchOrCreateObject(ofType: LocalImage.self,
//                                             predicate: NSPredicate(format: "id == %@", id),
//                                             in: context) { ctx in
//                let newImage = LocalImage(context: ctx)
//                newImage.id = id
//                return newImage
//            }
//            localImage.type = type.rawValue
//            localImage.lastUpdated = .now
//        }
//        ImagesManager.saveResizedImages(image: image,
//                                                id: id,
//                                                type: type)
//        return localImage
//    }
//    func createOrUpdateLocalImageWithImageData(imageDTO: ImageDTO,
//                                               withImage image: UIImage,
//                                               inContext contextType: ContextType) -> LocalImage {
//        let context = contextFromType(contextType)
//        var localImage: LocalImage!
//        let type =
//        GlobalProperties.ImageType.init(rawValue: imageDTO.type) ?? .none
//        context.performAndWait{
//             localImage = fetchOrCreateObject(ofType: LocalImage.self,
//                                                 predicate: NSPredicate(format: "id == %@", imageDTO.id),
//                                                 in: context) { ctx in
//                let newImage = LocalImage(context: ctx)
//                newImage.id = imageDTO.id
//                return newImage
//            }
//            localImage.type = type.rawValue
//            localImage.lastUpdated = imageDTO.lastUpdated
//        }
//        ImagesManager.saveResizedImages(image: image,
//                                        id: imageDTO.id,
//                                        type: type)
//        return localImage
//    }
//
//    func removeImageWithId(_ id: String, inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.perform {
//            let request = LocalImage.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", id)
//            if let imageToRemove = try? context.fetch(request).first {
//                self.removeLocalImage(imageToRemove, inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalImage(_ localImage: LocalImage,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        let idToRemove = localImage.viewId
//        let _ = ImagesManager.removeImageFromDevice(withId: idToRemove)
//        context.performAndWait {
//            context.delete(localImage)
//        }
//    }
//}
//
//// MARK: - Venue CRUD
//extension DataManager {
//    func createOrUpdateLocalLocationWithLocationDTO(_ location: VenueDTO,
//                                                    inContext contextType: ContextType) -> Venue {
//        let context = contextFromType(contextType)
//        var localLocation: Venue!
//        context.performAndWait{
//            localLocation = fetchOrCreateObject(ofType: Venue.self,
//                                                predicate: NSPredicate(format: "id == %@", location.id),
//                                                in: context) { ctx in
//                let newLocation = Venue(context: ctx)
//                newLocation.id = location.id
//                return newLocation
//            }
//             updateLocalLocation(localLocation,
//                                      withDTO: location,
//                                      inContext: contextType)
//        }
//        return localLocation
//    }
//
//    func cleanImagesInLocalLocation(_ localLocation: Venue,
//                                    andBackground isBg: Bool,
//                                    inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//        let imagesToRemove = localLocation.viewLocalImages
//         context.performAndWait {
//            for image in imagesToRemove {
//                localLocation.removeFromImages(image)
//                self.removeLocalImage(image, inContext: contextType)
//            }
//            if isBg {
//                localLocation.broadcastSchema = nil
//            }
//         }
//    }
//    
//    func linkImages(_ images: [LocalImage],
//                    toLocalLocation localLocation: Venue,
//                    inContext contextType: ContextType){
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            images.forEach { image in
//                localLocation.addToImages(image)
//                image.parentVenueImage = localLocation
//            }
//        }
//    }
//    
//    func linkEventTemplate(_ image: LocalImage,
//                           toLocalLocation localLocation: Venue,
//                           inContext contextType: ContextType){
////        let context = contextFromType(contextType)
////        context.performAndWait {
////            localLocation.broadcastSchema = image
////            image.parentVenueSchema = localLocation
////        }
//    }
//
//    func updateLocalLocation(_ localLocation: Venue,
//                             withDTO location: VenueDTO,
//                             inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//        //clean images
//         cleanImagesInLocalLocation(localLocation,
//                                         andBackground: true,
//                                         inContext: contextType)
//        context.performAndWait { [weak self] in
//            guard let self else { return }
//            localLocation.title = location.title
//            localLocation.address = location.address
//            localLocation.lastUpdated = location.lastUpdated
//            for id in location.imagesIds {
//                let image = self.fetchOrCreateObject(ofType: LocalImage.self,
//                                                     predicate: NSPredicate(format: "id == %@", id),
//                                                     in: context) { ctx in
//                    let newImage = LocalImage(context: ctx)
//                    newImage.id = id
//                    return newImage
//                }
//                localLocation.addToImages(image)
//                image.parentVenueImage = localLocation
//            }
////            if let imageId = location.venueSchemaId {
////                let backgroundImage = self.fetchOrCreateObject(ofType: LocalImage.self,
////                                                               predicate: NSPredicate(format: "id == %@", imageId),
////                                                               in: context) { ctx in
////                    let newImage = LocalImage(context: ctx)
////                    newImage.id = imageId
////                    return newImage
////                }
////                localLocation.broadcastSchema = backgroundImage
////                backgroundImage.parentVenueSchema = localLocation
////            }
//        }
//    }
//
//    func updateLocalLocation(_ location: Venue,
//                             withTitle title: String,
//                             address: String,
//                             localImages: [UIImage],
//                             locationBackground: LocalImage?,
//                             inContext contextType: ContextType) {
//        //clean images
//        let context = contextFromType(contextType)
//        cleanImagesInLocalLocation(location,
//                                         andBackground: true,
//                                         inContext: .main)
//        var newLocalImages: [LocalImage] = []
//        context.performAndWait{
//        for image in localImages {
//            let id = UUID().uuidString
//            let newImage = createOrUpdateLocalImageWithImageData(
//                imageDTO: ImageDTO(id: id,
//                                   type: GlobalProperties.ImageType.venue.rawValue, lastUpdated: .now),
//                withImage: image,
//                inContext: .main)
//            newLocalImages.append(newImage)
//        }
//        
//            location.title = title
//            location.address = address
//            for newImage in newLocalImages {
//                location.addToImages(newImage)
//                newImage.parentVenueImage = location
//            }
////            if let locationBackground = locationBackground {
////                location.broadcastSchema = locationBackground
////                locationBackground.parentVenueSchema = location
////            }
//        }
//    }
//
//    func removeLocalLocation(_ location: Venue,
//                             inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            cleanImagesInLocalLocation(location,
//                                       andBackground: false,
//                                       inContext: contextType)
//            context.delete(location)
//        }
//    }
//    
//    func removeLocationWithDTO(_ dto: VenueDTO, inContext contextType: ContextType){
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = Venue.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", dto.id)
//            if let locationToRemove = try? context.fetch(request).first{
//                removeLocalLocation(locationToRemove, inContext: contextType)
//            }
//        }
//    }
//}
//
//// MARK: - obvan CRUD
//extension DataManager {
//    func createOrUpdateLocalObvanWithDTO(_ obvanDTO: ObvanDTO,
//                                         inContext contextType: ContextType) -> Obvan {
//        let context = contextFromType(contextType)
//        var localObvan: Obvan!
//        context.performAndWait{
//            localObvan = fetchOrCreateObject(ofType: Obvan.self,
//                                             predicate: NSPredicate(format: "id == %@", obvanDTO.id),
//                                             in: context) { ctx in
//                let newObvan = Obvan(context: ctx)
//                newObvan.id = obvanDTO.id
//                return newObvan
//            }
//            updateLocalObvan(localObvan,
//                                   withObvan: obvanDTO,
//                                   inContext: contextType)
//        }
//        return localObvan
//    }
//
//    func updateLocalObvan(_ localObvan: Obvan,
//                          withObvan obvan: ObvanDTO,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localObvan.id = obvan.id
//            localObvan.lastUpdated = obvan.lastUpdated
//            localObvan.name = obvan.name
//            localObvan.broadcaster = obvan.broadcaster
//            obvan.obvanTemplateCrewDTOs.forEach { dto in
//                //create coredate entity
//            }
//            let image = fetchOrCreateObject(ofType: LocalImage.self,
//                                            predicate: NSPredicate(format: "id == %@", obvan.imageId),
//                                            in: context) { ctx in
//                let newImage = LocalImage(context: ctx)
//                newImage.id = obvan.imageId
//                return newImage
//            }
//            image.type = GlobalProperties.ImageType.obvan.rawValue
//            localObvan.image = image
////            image.parentObvan = localObvan
//        }
//    }
//    //from local member
//    func removeObvan(_ obvan: Obvan, inContext contextType: ContextType){
//        let context = contextFromType(contextType)
//         context.performAndWait {
//            if let localImage = obvan.image {
//                self.removeLocalImage(localImage, inContext: contextType)
//            }
//            context.delete(obvan)
//        }
//    }
//    //another local version
//    func removeObvanWithId(_ id: String,
//                           inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = Obvan.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", id)
//            if let obvanToRemove = try? context.fetch(request).first {
//                removeObvan(obvanToRemove, inContext: contextType)
//            }
//        }
//    }
//}
//
//// MARK: - Club CRUD
//extension DataManager {
//    func fetchAllLocalClubs(inContext contextType: ContextType) -> [Club] {
//        let context = contextFromType(contextType)
//        return context.performAndWait {
//            let request = Club.fetchRequest()
//            return (try? context.fetch(request)) ?? []
//        }
//    }
//
//    func createOrUpdateLocalClubWithDTO(_ club: ClubDTO,
//                                        inContext contextType: ContextType)  -> Club {
//        let context = contextFromType(contextType)
//        var localClub: Club!
//        context.performAndWait{
//            localClub = fetchOrCreateObject(ofType: Club.self,
//                                            predicate: NSPredicate(format: "id == %@", club.id),
//                                            in: context) { ctx in
//                let newClub = Club(context: ctx)
//                newClub.id = club.id
//                return newClub
//            }
//            updateLocalClub(localClub, withDTO: club, inContext: contextType)
//        }
//        return localClub
//    }
//
//    func updateLocalClub(_ localClub: Club,
//                         withDTO club: ClubDTO,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        let imageId = club.imageLogoID ?? UUID().uuidString
//        context.performAndWait {
//            localClub.title = club.title
//            localClub.lastUpdated = club.lastUpdated
//            localClub.contacts = club.contacts
//            localClub.urlString = club.urlString
//            let image = fetchOrCreateObject(ofType: LocalImage.self,
//                                            predicate: NSPredicate(format: "id == %@", imageId),
//                                            in: context) { ctx in
//                let newImage = LocalImage(context: ctx)
//                newImage.id = imageId
//                return newImage
//            }
//            localClub.imageLogo = image
//            if let locationId = club.homeVenueID {
//                let location = fetchOrCreateObject(ofType: Venue.self,
//                                                   predicate: NSPredicate(format: "id == %@", locationId),
//                                                   in: context) { ctx in
//                    let newLocation = Venue(context: ctx)
//                    newLocation.id = locationId
//                    return newLocation
//                }
//                localClub.homeVenue = location
//                location.addToHomeClub(localClub)
//            }
//        }
//    }
//
//    func updateClubWith(id: String,
//                        title: String,
//                        uiimage: UIImage?,
//                        contacts: String,
//                        urlString: String,
//                        location: Venue?,
//                        inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//        let request = Club.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id)
//            if let club = try? context.fetch(request).first {
//                updateClubWithClub(club: club,
//                                   title: title,
//                                   uiimage: uiimage,
//                                   contacts: contacts,
//                                   urlString: urlString,
//                                   location: location,
//                                   inContext: contextType)
//            }
//        }
//    }
//    func updateClubWithClub(club: Club,
//                            title: String,
//                            uiimage: UIImage?,
//                            contacts: String,
//                            urlString: String,
//                            location: Venue?,
//                            inContext contextType: ContextType)  {
//        let context = contextFromType(contextType)
//         context.performAndWait {
//            club.title = title
//            if let uiimage {
//                if let localImage = club.imageLogo {
//                    localImage.uploadImage(uiimage: uiimage)
//                } else {
//                    let localImage = createOrUpdateLocalImageWithId(UUID().uuidString,
//                                                                         withImage: uiimage,
//                                                                         andType: GlobalProperties.ImageType.club,
//                                                                         inContext: contextType)
//                    localImage.uploadImage(uiimage: uiimage)
//                    club.imageLogo = localImage
//                    localImage.parentClub = club
//                }
//            }
//            club.contacts = contacts
//            club.urlString = urlString
//            if let location {
//                club.homeVenue = location
//                location.addToHomeClub(club)
//            }
//        }
//    }
//
//    func removeClubWithDTO(_ clubDTO: ClubDTO,
//                           inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = Club.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", clubDTO.id)
//            if let clubToRemove = try? context.fetch(request).first {
//                removeLocalClub(localClub: clubToRemove,
//                                inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalClub(localClub: Club,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            if let localImage = localClub.imageLogo {
//               removeLocalImage(localImage, inContext: contextType)
//            }
//            context.delete(localClub)
//        }
//    }
//}
//
//// MARK: - Environment CRUD
//extension DataManager {
//    //camera
//    func createOrUpdateCamera(_ camera: CameraDTO,
//                              inContext contextType: ContextType) -> Camera {
//        let context = contextFromType(contextType)
//        var localCamera: Camera!
//        context.performAndWait {
//            localCamera = fetchOrCreateObject(ofType: Camera.self,
//                                              predicate: NSPredicate(format: "id == %@", camera.id),
//                                              in: context) { ctx in
//                let newCamera = Camera(context: ctx)
//                newCamera.id = camera.id
//                return newCamera
//            }
//            localCamera.optic = camera.optic.rawValue
//        }
//        return localCamera
//    }
//    func linkLocalCamera(_ camera: Camera,
//                         withPoint point: VenuePoint,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            camera.point = point
//            point.addToCameras(camera)
//        }
//    }
//
//    func removeCameraWithDTO(_ cameraDTO: CameraDTO,
//                             inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.perform {
//            let request = Camera.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", cameraDTO.id)
//            if let cameraToRemove = try? context.fetch(request).first {
//                self.removeLocalCamera(cameraToRemove, inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalCamera(_ camera: Camera,
//                           inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait { context.delete(camera) }
//    }
//
//    //sound
//    func createOrUpdateSound(_ sound: SoundDTO,
//                             inContext contextType: ContextType) -> Sound {
//        let context = contextFromType(contextType)
//        var localSound: Sound!
//        context.performAndWait {
//            localSound = fetchOrCreateObject(ofType: Sound.self,
//                                             predicate: NSPredicate(format: "id == %@", sound.id),
//                                             in: context) { ctx in
//                let newSound = Sound(context: ctx)
//                newSound.id = sound.id
//                return newSound
//            }
//            localSound.placeType = sound.placeType.rawValue
//            localSound.windDefence = sound.windDefence.rawValue
//        }
//        return localSound
//    }
//
//    func linkLocalSound(_ sound: Sound,
//                        withPoint point: VenuePoint,
//                        inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            sound.point = point
//            point.addToSounds(sound)
//        }
//    }
//
//    func removeSoundWithDTO(_ sound: SoundDTO,
//                            inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = Sound.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", sound.id)
//            if let soundToRemove = try? context.fetch(request).first {
//                removeLocalSound(soundToRemove, inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalSound(_ sound: Sound,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait { context.delete(sound) }
//    }
//    //light
//    func createOrUpdateLight(_ light: LightDTO,
//                             inContext contextType: ContextType) -> Light {
//        let context = contextFromType(contextType)
//        var localLight: Light!
//        context.performAndWait {
//            localLight = fetchOrCreateObject(ofType: Light.self,
//                                             predicate: NSPredicate(format: "id == %@", light.id),
//                                             in: context) { ctx in
//                let newLight = Light(context: ctx)
//                newLight.id = light.id
//                return newLight
//            }
//            localLight.lightType = light.lightType.rawValue
//        }
//        return localLight
//    }
//
//    func linkLocalLight(_ light: Light,
//                        WithPoint point: VenuePoint,
//                        InContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            light.point = point
//            point.addToLights(light)
//        }
//    }
//
//    func removeLightWithDTO(_ light: LightDTO,
//                            inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = Light.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", light.id)
//            if let lightToRemove = try? context.fetch(request).first {
//                removeLocalLight(lightToRemove, inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalLight(_ light: Light,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait { context.delete(light) }
//    }
//
//    //hardware
//    func createOrUpdateHardwareWithDTO(_ hardwareDTO: HardwareDTO,
//                                       inContext contextType: ContextType) -> Hardware {
//        let context = contextFromType(contextType)
//        var localHardware: Hardware!
//        context.performAndWait {
//            localHardware = fetchOrCreateObject(ofType: Hardware.self,
//                                                predicate: NSPredicate(format: "id == %@", hardwareDTO.id),
//                                                in: context) { ctx in
//                let newHardware = Hardware(context: ctx)
//                newHardware.id = hardwareDTO.id
//                return newHardware
//            }
//            localHardware.type = hardwareDTO.envType.rawValue
//            localHardware.channels = hardwareDTO.chanels.joined(separator: ",")
//        }
//        return localHardware
//    }
//    func linkLocalHardware(_ hardware: Hardware,
//                           withUnit unit: Crew,
//                           inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            hardware.crew = unit
//            unit.hardware = hardware
//        }
//    }
//
//    func removeHardwareWithDTO(_ hardware: HardwareDTO,
//                               inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait{
//            let request = Hardware.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", hardware.id)
//            if let hardwareToRemove = try? context.fetch(request).first {
//                self.removeLocalHardware(hardwareToRemove,
//                                         inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalHardware(_ localhardware: Hardware,
//                             inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait { context.delete(localhardware) }
//    }
//}
//
//// MARK: - Venue Points CRUD
//extension DataManager {
//    //venue venuePoint
//    func createOrUpdateLocalPointWithPointDTO(_ point: VenuePointDTO,
//                                              inContext contextType: ContextType) -> VenuePoint {
//        let context = contextFromType(contextType)
//        var localPoint: VenuePoint!
//        context.performAndWait{
//            localPoint = fetchOrCreateObject(
//                ofType: VenuePoint.self,
//                predicate: NSPredicate(format: "id == %@", point.id),
//                in: context) { ctx in
//                    let newLocationPoint = VenuePoint(context: ctx)
//                    newLocationPoint.id = point.id
//                    return newLocationPoint
//                }
//            updateLocalPoint(localPoint,
//                             withPointDTO: point,
//                             inContext: contextType)
//        }
//        return localPoint
//    }
//
//    func updateLocalPoint(_ localPoint: VenuePoint,
//                          withPointDTO point: VenuePointDTO,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localPoint.coordinateX = Float(point.coordinateX)
//            localPoint.coordinateY = Float(point.coordinateY)
//            localPoint.rotation = Int16(point.rotation)
//            localPoint.scaleFactor = Float(point.scaleFactor)
//            localPoint.number = Int16(point.number)
//            let image = self.fetchOrCreateObject(
//                ofType: LocalImage.self,
//                predicate: NSPredicate(format: "id == %@", point.imageId),
//                in: context) { ctx in
//                let newImage = LocalImage(context: ctx)
//                newImage.id = point.imageId
//                return newImage
//            }
//            localPoint.image = image
//            image.addToParentVenuePoint(localPoint)
//            localPoint.pointDescription = point.description
//            localPoint.task = point.task
//            for user in localPoint.viewMembers {
//                localPoint.removeFromMembers(user)
//            }
//            for id in point.memberIds {
//                let user = fetchOrCreateObject(
//                    ofType: Member.self,
//                    predicate: NSPredicate(format: "id == %@", id),
//                    in: context
//                ) { ctx in
//                    let newUser = Member(context: ctx)
//                    newUser.id = id
//                    return newUser }
//                localPoint.addToMembers(user)
//                user.addToVenuePoints(localPoint)
//            }
//            for cam in localPoint.viewCameras {
//                localPoint.removeFromCameras(cam)
//                removeLocalCamera(cam, inContext: contextType)
//            }
//            for cam in point.cameras {
//                let camera = createOrUpdateCamera(cam, inContext: contextType)
//                localPoint.addToCameras(camera)
//                camera.point = localPoint
//            }
//            for sound in localPoint.viewSounds {
//                localPoint.removeFromSounds(sound)
//                removeLocalSound(sound, inContext: contextType)
//            }
//            for sound in point.sounds {
//                let localSound = createOrUpdateSound(
//                    sound,
//                    inContext: contextType
//                )
//                localPoint.addToSounds(localSound)
//                localSound.point = localPoint
//            }
//            for light in localPoint.viewLights {
//                localPoint.removeFromLights(light)
//                removeLocalLight(light, inContext: contextType)
//            }
//            for light in point.lights {
//                let localLight = createOrUpdateLight(
//                    light,
//                    inContext: contextType
//                )
//                localPoint.addToLights(localLight)
//                localLight.point = localPoint
//            }
//        }
//    }
//
//    func updateLocalPoint(_ localPoint: VenuePoint,
//                          withX x: Double,
//                          y: Double,
//                          rotation: Int,
//                          scaleFactor: Double,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localPoint.coordinateX = Float(x)
//            localPoint.coordinateY = Float(y)
//            localPoint.rotation = Int16(rotation)
//            localPoint.scaleFactor = Float(scaleFactor)
//        }
//    }
//    func updateLocalPoint(_ localPoint: VenuePoint,
//                          withTemplatePoint point: TemplatePoint,
//                          inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localPoint.coordinateX = point.coordinateX
//            localPoint.coordinateY = point.coordinateY
//            localPoint.rotation = point.rotation
//            localPoint.scaleFactor = point.scaleFactor
//            localPoint.number = point.number
//            localPoint.pointDescription = point.pointDescription
//            localPoint.task = point.task
//            for sound in localPoint.viewSounds {
//                localPoint.removeFromSounds(sound)
//                removeLocalSound(sound, inContext: contextType)
//            }
//            for sound in point.soundDTOs {
//                let localSound = createOrUpdateSound(sound,
//                                                     inContext: contextType)
//                localPoint.addToSounds(localSound)
//                localSound.point = localPoint
//            }
//            for cam in localPoint.viewCameras {
//                localPoint.removeFromCameras(cam)
//                removeLocalCamera(cam, inContext: contextType)
//            }
//            for cam in point.cameraDTOs {
//                let camera = createOrUpdateCamera(cam, inContext: contextType)
//                localPoint.addToCameras(camera)
//                camera.point = localPoint
//            }
//            for light in localPoint.viewLights {
//                localPoint.removeFromLights(light)
//                removeLocalLight(light, inContext: contextType)
//            }
//            for light in point.lightDTOs {
//                let localLight = createOrUpdateLight(light,
//                                                     inContext: contextType)
//                localPoint.addToLights(localLight)
//                localLight.point = localPoint
//            }
//        }
//    }
//
//    func removeLocationPoint(_ point: VenuePointDTO,
//                             inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = VenuePoint.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", point.id)
//            if let pointToRemove = try? context.fetch(request).first {
//                self.removeLocalLocationPoint(pointToRemove,
//                                              inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalLocationPoint(_ localPoint: VenuePoint,
//                                  inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            for camera in localPoint.viewCameras {
//                self.removeLocalCamera(camera, inContext: contextType)
//            }
//            for sound in localPoint.viewSounds {
//                self.removeLocalSound(sound, inContext: contextType)
//            }
//            for light in localPoint.viewLights {
//                self.removeLocalLight(light, inContext: contextType)
//            }
//            if let loacImage = localPoint.image {
//                self.removeLocalImage(loacImage, inContext: contextType)
//            }
//            context.delete(localPoint)
//        }
//    }
//}
//// MARK: - Units
//extension DataManager {
//    func createOrUpdateLocalUnitWithUnitDTO(_ obvanUnit: CrewDTO,
//                                            inContext contextType: ContextType) -> Crew {
//        let context = contextFromType(contextType)
//        var localUnit: Crew!
//        context.performAndWait{
//            localUnit = fetchOrCreateObject(
//                ofType: Crew.self,
//                predicate: NSPredicate(format: "id == %@", obvanUnit.id),
//                in: context
//            ) { ctx in
//                let newLocalUnit = Crew(context: ctx)
//                newLocalUnit.id = obvanUnit.id
//                return newLocalUnit
//            }
//            updateLocalUnit(localUnit, withUnit: obvanUnit, inContext: contextType)
//        }
//        return localUnit
//    }
//
//    func createUnitWithUser(_ user: Member,
//                            andPosition position: UserSpecialization,
//                            andHardware hardware: HardwareType?,
//                            inContext contextType: ContextType) -> Crew {
//        let context = contextFromType(contextType)
//        var localUnit: Crew!
//        context.performAndWait{
//            localUnit = Crew(context: context)
//            localUnit.id = UUID().uuidString
//            updateLocalUnit(localUnit,
//                            withPosition: position,
//                            andUser: user,
//                            andHardware: hardware,
//                            inContext: contextType)
//        }
//        return localUnit
//    }
//
//    func updateLocalUnit(_ localUnit: Crew,
//                         withUnit unit: CrewDTO,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localUnit.position = unit.position
//            localUnit.coordinateX = Float(unit.coordinateX)
//            localUnit.coordinateY = Float(unit.coordinateY)
//            localUnit.rotation = Int16(unit.rotation)
//            localUnit.scaleFactor = Float(unit.scaleFactor)
//            localUnit.task = unit.task
//            let user = fetchOrCreateObject(
//                ofType: Member.self,
//                predicate: NSPredicate(format: "id == %@", unit.memberId),
//                in: context
//            ) { ctx in
//                let newUser = Member(context: ctx)
//                newUser.id = unit.memberId
//                return newUser
//            }
//            localUnit.member = user
//            user.addToCrews(localUnit)
//            let hardwareId = unit.hardware?.id ?? UUID().uuidString
//            let hardware = fetchOrCreateObject(
//                ofType: Hardware.self,
//                predicate: NSPredicate(format: "id == %@", hardwareId),
//                in: context
//            ) { ctx in
//                let newHardware = Hardware(context: ctx)
//                newHardware.id = hardwareId
//                return newHardware
//            }
//            localUnit.hardware = hardware
//            hardware.crew = localUnit
//        }
//    }
//
//    func updateLocalUnit(_ localUnit: Crew,
//                         withPosition position: UserSpecialization,
//                         andUser user: Member,
//                         andHardware hardware: HardwareType?,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localUnit.position = position.rawValue
//            localUnit.member = user
//            user.addToCrews(localUnit)
//            if let hardware {
//                let localHardware = fetchOrCreateObject(
//                    ofType: Hardware.self,
//                    predicate: NSPredicate(
//                        format: "id == %@",
//                        UUID().uuidString
//                    ),
//                    in: context
//                ) { ctx in
//                    let newHardware = Hardware(context: ctx)
//                    newHardware.id = UUID().uuidString
//                    return newHardware
//                }
//                localHardware.type = hardware.rawValue
//                localUnit.hardware = localHardware
//                localHardware.crew = localUnit
//            }
//        }
//    }
//
//    func removeLocalUnitUsingUnitDTO(_ unit: CrewDTO,
//                                     inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait{
//            let request = Crew.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", unit.id)
//            if let unitToRemove = try? context.fetch(request).first {
//                removeLocalUnit(unitToRemove, inContext: contextType)
//            }
//        }
//    }
//
//    func removeLocalUnit(_ unit: Crew,
//                         inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            if let hardware = unit.hardware {
//                self.removeLocalHardware(hardware, inContext: contextType)
//            }
//            context.delete(unit)
//        }
//    }
//}
//
//// MARK: - Template / TemplatePoints
//extension DataManager {
//    //template
//    func createOrUpdateLocalTemplateWithTemplateDTO(_ template: TemplateDTO,
//                                                    inConext contextType: ContextType) -> Template {
//        let context = contextFromType(contextType)
//        var localTemplate: Template!
//        context.performAndWait{
//            localTemplate = fetchOrCreateObject(
//                ofType: Template.self,
//                predicate: NSPredicate(format: "id == %@", template.id),
//                in: context
//            ) { ctx in
//                let newTemplate = Template(context: ctx)
//                newTemplate.id = template.id
//                return newTemplate
//            }
//            updateLocalTemplate(localTemplate,
//                                withTemplateDTO: template,
//                                inConext: contextType)
//        }
//        return localTemplate
//    }
//
//    func updateLocalTemplate(_ localtemplate: Template,
//                             withTemplateDTO template: TemplateDTO,
//                             inConext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localtemplate.id = template.id
//            localtemplate.lastUpdated = template.lastUpdated
//            localtemplate.name = template.name
//            localtemplate.removeFromTemplatePoints(
//                localtemplate.templatePoints ?? []
//            )
//            for point in template.templatePointDTOs {
//                let localTemplatePoint =
//                    createOrUpdateTemplatePointWithTemplatePointDTO(point,
//                                                                      inContext: contextType)
//                localtemplate.addToTemplatePoints(localTemplatePoint)
//            }
//        }
//    }
//    func removeLocalTemplate(_ template: Template,
//                             inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            for point in template.templatePoints as? Set<TemplatePoint> ?? [] {
//                removeLocalTemplatePoint(point, inContext: contextType)
//            }
//            context.delete(template)
//        }
//    }
//    func removeTemplateWithDTO(_ dto: TemplateDTO, inContext contextType: ContextType){
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            let request = Template.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", dto.id)
//            if let templateToRemove = try? context.fetch(request).first{
//                removeLocalTemplate(templateToRemove, inContext: contextType)
//            }
//        }
//    }
//
//    //templatePoint
//    func createOrUpdateTemplatePointWithTemplatePointDTO(_ point: TemplatePointDTO,
//                                                           inContext contextType: ContextType) -> TemplatePoint {
//        let context = contextFromType(contextType)
//        var localPoint: TemplatePoint!
//        context.performAndWait{
//            localPoint = fetchOrCreateObject(
//                ofType: TemplatePoint.self,
//                predicate: NSPredicate(format: "id == %@", point.id),
//                in: context
//            ) { ctx in
//                let newTemplatePoint = TemplatePoint(context: ctx)
//                newTemplatePoint.id = point.id
//                return newTemplatePoint
//            }
//            updateLocalTemplatePoint(localPoint,
//                                     withTemplatePoint: point,
//                                     inContext: contextType)
//        }
//        return localPoint
//    }
//    func updateLocalTemplatePoint(_ localPoint: TemplatePoint,
//                                  withTemplatePoint point: TemplatePointDTO,
//                                  inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            localPoint.coordinateX = Float(point.coordinateX)
//            localPoint.coordinateY = Float(point.coordinateY)
//            localPoint.rotation = Int16(point.rotation)
//            localPoint.scaleFactor = Float(point.scaleFactor)
//            localPoint.number = Int16(point.number)
//            localPoint.pointDescription = point.pointDescription
//            localPoint.task = point.task
//            localPoint.cameras = point.cameras.map({ $0.optic.rawValue }).joined(separator: ",")
//            localPoint.sounds = point.sounds.map({ $0.placeType.rawValue }).joined(separator: ",")
//            localPoint.lights = point.lights.map({ $0.lightType.rawValue }).joined(separator: ",")
//        }
//    }
//    func removeLocalTemplatePoint(_ point: TemplatePoint,
//                                  inContext contextType: ContextType) {
//        let context = contextFromType(contextType)
//        context.performAndWait { context.delete(point) }
//    }
//    
//}
//
//// MARK: - map TemplatePoint to LocalLocationPoint
//extension DataManager {
//    // id for venuePoint must be unique for every event
//    func createLocalLocationPointFromTemplatePoint(_ templatePoint: TemplatePoint,
//                                                   inContext contextType: ContextType) -> VenuePoint {
//        let context = contextFromType(contextType)
//        let id = UUID().uuidString
//        var localLocationPoint: VenuePoint!
//        context.performAndWait {
//            localLocationPoint = fetchOrCreateObject(
//                ofType: VenuePoint.self,
//                predicate: NSPredicate(format: "id == %@", id),
//                in: context
//            ) { ctx in
//                let newLocationPoint = VenuePoint(context: ctx)
//                newLocationPoint.id = id
//                return newLocationPoint
//            }
//            localLocationPoint.coordinateX = templatePoint.coordinateX
//            localLocationPoint.coordinateY = templatePoint.coordinateY
//            localLocationPoint.rotation = templatePoint.rotation
//            localLocationPoint.scaleFactor = templatePoint.scaleFactor
//            localLocationPoint.pointDescription = templatePoint.pointDescription
//            localLocationPoint.number = templatePoint.number
//            localLocationPoint.task = templatePoint.task
//            if localLocationPoint.viewCameras.count > 0 {
//                localLocationPoint.viewCameras.forEach {
//                    localLocationPoint.removeFromCameras($0)
//                }
//            }
//            for camera in templatePoint.cameraDTOs {
//                localLocationPoint.addToCameras(
//                    createOrUpdateCamera(camera, inContext: contextType)
//                )
//            }
//            if localLocationPoint.viewSounds.count > 0 {
//                localLocationPoint.viewSounds.forEach {
//                    localLocationPoint.removeFromSounds($0)
//                }
//            }
//            for sound in templatePoint.soundDTOs {
//                localLocationPoint.addToSounds(
//                    createOrUpdateSound(sound, inContext: contextType)
//                )
//            }
//            if localLocationPoint.viewLights.count > 0 {
//                localLocationPoint.viewLights.forEach {
//                    localLocationPoint.removeFromLights($0)
//                }
//            }
//            for light in templatePoint.lightDTOs {
//                localLocationPoint.addToLights(
//                    createOrUpdateLight(light,
//                                        inContext: contextType)
//                )
//            }
//        }
//        return localLocationPoint
//    }
//    
//    func linkPoints(_ points: [VenuePoint], toEvent event: Broadcast, inContext contextType: ContextType){
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            points.forEach { point in
//                event.addToVenuePoints(point)
//                point.broadcast = event
//            }
//        }
//    }
//    
//    func unlinkPoints(_ points:[VenuePoint], inContext contextType: ContextType){
//        let context = contextFromType(contextType)
//        context.performAndWait {
//            points.forEach { point in
//                    point.viewMembers.forEach { user in
//                        user.removeFromVenuePoints(point)
//                        point.removeFromMembers(user)
//                    }
//
//            }
//        }
//    }
//
//    func mapTemplateToLocationPoints(template: Template,
//                                     inContext contextType: ContextType) -> [VenuePoint] {
//        var array = [VenuePoint]()
//        
//        for point in template.viewTemplatePoints {
//            array.append(self.createLocalLocationPointFromTemplatePoint(point,
//                                                                        inContext: contextType)
//            )
//        }
//        return array
//    }
//
//    func createTemplateWithLocalLocationPoints(_ points: [VenuePoint],
//                                               andName name: String,
//                                               inContext contextType: ContextType) -> Template {
//        let context = contextFromType(contextType)
//        var template: Template!
//        context.performAndWait {
//            template = fetchOrCreateObject(
//                ofType: Template.self,
//                predicate: NSPredicate(format: "id == %@", name),
//                in: context
//            ) { ctx in
//                let newTemplate = Template(context: ctx)
//                newTemplate.id = name
//                return newTemplate
//            }
//            template.name = name
//            if !template.viewTemplatePoints.isEmpty {
//                for point in template.viewTemplatePoints {
//                    template.removeFromTemplatePoints(point)
//                    removeLocalTemplatePoint(point, inContext: contextType)
//                }
//            }
//            for point in points {
//                let localTemplatePoint =
//                self.createTemplatePointFromLocalLocationPoint(point,
//                                                               inContext: contextType)
//                
//                template.addToTemplatePoints(localTemplatePoint)
//                localTemplatePoint.parentTemplate = template
//                
//            }
//        }
//        return template
//    }
//
//    func createTemplatePointFromLocalLocationPoint(_ point: VenuePoint,
//                                                   inContext contextType: ContextType) -> TemplatePoint {
//        let context = contextFromType(contextType)
//        var templatePoint: TemplatePoint!
//        context.performAndWait {
//            templatePoint = fetchOrCreateObject(
//                ofType: TemplatePoint.self,
//                predicate: NSPredicate(format: "id == %@", UUID().uuidString),
//                in: context
//            ) { ctx in
//                let newTemplatePoint = TemplatePoint(context: ctx)
//                newTemplatePoint.id = UUID().uuidString
//                return newTemplatePoint
//            }
//            templatePoint.coordinateX = point.coordinateX
//            templatePoint.coordinateY = point.coordinateY
//            templatePoint.number = point.number
//            templatePoint.pointDescription = point.pointDescription
//            templatePoint.task = point.task
//            templatePoint.scaleFactor = point.scaleFactor
//            templatePoint.rotation = point.rotation
//            templatePoint.cameras = point.viewCameras.map({ $0.viewOptic.rawValue }).joined(separator: ",")
//            templatePoint.sounds = point.viewSounds.map({ $0.viewPlaceType.rawValue }).joined(separator: ",")
//            templatePoint.lights = point.viewLights.map({ $0.viewLightType.rawValue }).joined(separator: ",")
//        }
//        return templatePoint
//    }
//}
//
//// MARK: - Save context and publish changes to update ui
//extension DataManager {
//    func saveContextAsync(type contextType: ContextType,
//                     publish: GlobalProperties.PublishChanges,
//                     id: [String]) async {
//        let context = contextFromType(contextType)
//        await context.perform {
//            if context.hasChanges {
//                do {
//                    try context.save()
//                    if publish != .none {
//                        Task {
//                            await MainActor.run {
//                                self.updatePublisher.send((publish, id))
//                            }
//                        }
//                    }
//                } catch {
//                    print("error save context: \(error.localizedDescription)")
//                }
//            } else {
//                print("no changes")
//            }
//        }
//    }
//    
//    func saveContextSync(type contextType: ContextType,
//                     publish: GlobalProperties.PublishChanges,
//                     id: [String]) {
//        let context = contextFromType(contextType)
//       context.performAndWait {
//            if context.hasChanges {
//                do {
//                    try context.save()
//                    if publish != .none {
//                        Task {
//                            await MainActor.run {
//                                self.updatePublisher.send((publish, id))
//                            }
//                        }
//                    }
//                } catch {
//                    print("error save context: \(error.localizedDescription)")
//                }
//            } else {
//                print("no changes")
//            }
//        }
//    }
//}
//
//// MARK: - Context choose
//extension DataManager {
//    func contextFromType(_ contextType: ContextType) -> NSManagedObjectContext {
//        let context: NSManagedObjectContext
//        switch contextType {
//        case .main:
//            context = self.mainContext
//        case .bg:
//            context = self.backgroundContext
//        }
//        return context
//    }
//}
