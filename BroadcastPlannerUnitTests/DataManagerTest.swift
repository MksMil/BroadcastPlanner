import CoreData
import XCTest

@testable import BroadcastPlanner
@MainActor
final class DataManagerTests: XCTestCase {
    
    var sut: DataManager!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
// MARK: - SetUp / TearDown
    override func setUp() {
        super.setUp()
        sut = DataManager(forPreview: true)
        container = sut.persistentContainer
        context = sut.mainContext
    }
    override func tearDown() {
        context = nil
        sut = nil
        container = nil
        
        super.tearDown()
    }
    // MARK: - CoreData
    // is context available
    func test_CoreDataStack_ShouldSaveAndFetchLocalImage() {
        XCTAssertNotNil(context, "CoreData context not initialized")

        let testImage = LocalImage(context: context)
        testImage.id = "test_image_id"
        testImage.type = "test_type"

        do {
            try context.save()
        } catch {
            XCTFail("Failed to save object in Core Data: \(error)")
        }

        let request: NSFetchRequest<LocalImage> = LocalImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "test_image_id")

        do {
            let results = try context.fetch(request)
            XCTAssertEqual(results.count, 1, "Expected one object LocalImage")
            XCTAssertEqual(results.first?.id, "test_image_id", "Wrong ID")
            XCTAssertEqual(results.first?.type, "test_type", "Wrong Object type")
        } catch {
            XCTFail("Fetch request error: \(error)")
        }
    }
    // MARK: - Generic
    func test_fetchOrCreateObject_returnsExistingObject_whenFound() {
        let id = "id"
        let existing = VenuePoint(context: context)
        existing.id = id
        try? context.save()

        let predicate = NSPredicate(format: "id == %@", id)
        let result = sut.fetchOrCreateObject(
            ofType: VenuePoint.self,
            predicate: predicate,
            in: context,
            initializer: { ctx in
                XCTFail("Initializer should not be called")
                return VenuePoint(context: ctx)
            }
        )
        XCTAssertEqual(result.id, id)
    }
    func test_fetchOrCreateObject_createsNewObject_whenNotFound() {
        let id = UUID().uuidString
        let initId = UUID().uuidString
        let predicate = NSPredicate(format: "id == %@", id)

        let result = sut.fetchOrCreateObject(
            ofType: VenuePoint.self,
            predicate: predicate,
            in: context,
            initializer: { ctx in
                let new = VenuePoint(context: ctx)
                new.id = initId
                return new
            }
        )

        XCTAssertEqual(result.id, initId)

        // Is object in context?
        let fetchRequest: NSFetchRequest<VenuePoint> = VenuePoint.fetchRequest()
        let all = try? context.fetch(fetchRequest)
        XCTAssertTrue(all?.contains(where: { $0.id == initId }) ?? false)
    }
    // MARK: - User
    func test_createOrUpdateLocalUserWithUserDTO_createsUser_andUpdatesUser(){
        let id = UUID().uuidString
        let userDTO = MemberDTO.mock(id: id)
        let resultUser = sut.createOrUpdateLocalUserWithUserDTO(userDTO,
                                            inContext: .main)
        XCTAssertEqual(id, resultUser.viewId)
    }
    func test_createOrUpdateLocalUserWithUserDTO_fetchesUser_andUpdatesUser(){
        let id = UUID().uuidString
        var userDTO = MemberDTO.mock(id: id)
        userDTO.firstName = "firstName"
        userDTO.lastName = "lastName"
        userDTO.isOnline = true
        userDTO.phoneNumber = "123"
        userDTO.email = "email@email"
        userDTO.homeAddress = "address"
        userDTO.specialization = ["1", "2", "3"]
        
        let request: NSFetchRequest<Member> =
            Member.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        var results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 0) // no member founded
        let localUser = Member(context: context)
        localUser.id = id
        results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1) // member founded
        
        let resultUser = sut.createOrUpdateLocalUserWithUserDTO(userDTO,
                                            inContext: .main)//found existing member with DTO.id
        XCTAssertEqual(id, resultUser.viewId)
        XCTAssertEqual(userDTO.firstName, resultUser.viewFirstName)
        XCTAssertEqual(userDTO.lastName, resultUser.viewLastName)
        XCTAssertEqual(userDTO.isOnline, resultUser.isOnline)
        XCTAssertEqual(userDTO.phoneNumber, resultUser.viewPhoneNumber)
        XCTAssertEqual(userDTO.email, resultUser.viewEmail)
        XCTAssertEqual(userDTO.homeAddress, resultUser.viewAddress)
        XCTAssertEqual(userDTO.creationDate, resultUser.viewCreationDate)
        XCTAssertEqual(userDTO.leaveDate, resultUser.viewLeaveDate)
        XCTAssertEqual(resultUser.image?.id ?? "", userDTO.id)
    }
    func test_updateLocalUser_updatesLocalUser(){
        let id = UUID().uuidString
        var userDTO = MemberDTO.mock(id: id)
        userDTO.firstName = "firstName"
        userDTO.lastName = "lastName"
        userDTO.isOnline = true
        userDTO.phoneNumber = "123"
        userDTO.email = "email@email"
        userDTO.homeAddress = "address"
        userDTO.specialization = ["1", "2", "3"]
        let localUser = Member(context: context)
        sut.updateLocalUser(localUser,
                            withUserDTO: userDTO,
                            inContext: .main)
        XCTAssertEqual(userDTO.id, localUser.viewId)
        XCTAssertEqual(userDTO.firstName, localUser.viewFirstName)
        XCTAssertEqual(userDTO.lastName, localUser.viewLastName)
        XCTAssertEqual(userDTO.isOnline, localUser.isOnline)
        XCTAssertEqual(userDTO.phoneNumber, localUser.viewPhoneNumber)
        XCTAssertEqual(userDTO.email, localUser.viewEmail)
        XCTAssertEqual(userDTO.homeAddress, localUser.viewAddress)
        XCTAssertEqual(userDTO.creationDate, localUser.viewCreationDate)
        XCTAssertEqual(userDTO.leaveDate, localUser.viewLeaveDate)
        XCTAssertEqual(localUser.image?.id ?? "", userDTO.id)
        
    }
    func test_removeUserUsingDTO_removesLocalUser(){
        let id = UUID().uuidString
        let userDTO = MemberDTO.mock(id: id)
        
        let _ = sut.createOrUpdateLocalUserWithUserDTO(userDTO,inContext: .main)
        let request: NSFetchRequest<Member> = Member.fetchRequest()
        let results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1)
        
        sut.removeUserWithDTO(userDTO, inContext: .main)
        let newResults = try? container.viewContext.fetch(request)
        XCTAssertEqual(newResults?.count, 0)
    }
    func test_removeLocalUser_removesLocalUser(){
        let localUser = Member(context: context)
        let request: NSFetchRequest<Member> = Member.fetchRequest()
        var results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1)
        sut.removeLocalUser(localUser, inContext: .main)
        results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 0)
    }
    @MainActor func test_fetchUsersAvailableToEvent_fetchesUsersAvailableToEvent(){
        let localEvent = Broadcast(context: context)
        let user1DTO = MemberDTO.mock(id:  UUID().uuidString)
        let user2DTO = MemberDTO.mock(id:  UUID().uuidString)
        let user3DTO = MemberDTO.mock(id:  UUID().uuidString)
        let localUser1 = sut.createOrUpdateLocalUserWithUserDTO(user1DTO,
                                                              inContext: .main)
        let localUser2 = sut.createOrUpdateLocalUserWithUserDTO(user2DTO,
                                                             inContext: .main)
        context.performAndWait { localEvent.addToUsers(localUser1) }
        var result = sut.fetchUsersAvailableToEvent(localEvent)
        XCTAssertEqual(result.count, 1)
        context.performAndWait { localEvent.addToUsers(localUser2) }
        result = sut.fetchUsersAvailableToEvent(localEvent)
        XCTAssertEqual(result.count, 0)
        let _ = sut.createOrUpdateLocalUserWithUserDTO(user3DTO,inContext: .main)
        result = sut.fetchUsersAvailableToEvent(localEvent)
        XCTAssertEqual(result.count, 1)
    }
    // MARK: - Event
    func test_createOrUpdateLocalEventWithEventDTO_createsEvent_andUpdatesEvent()async {
        let id = UUID().uuidString
        let eventDto = BroadcastDTO.mock(id:id)
        let request = Broadcast.fetchRequest()
        var results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        let _ = sut.createOrUpdateLocalEventWithEventDTO(eventDto, inContext: .main)
        results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.viewId, id)
    }
    func test_createOrUpdateLocalEventWithEventDTO_fetchesEvent_andUpdatesEvent(){
        let id = UUID().uuidString
        let eventDto = BroadcastDTO.mock(id:id)
        let localEvent = Broadcast(context: context)
        localEvent.id = id
        
        let request = Broadcast.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.viewId, id)
        XCTAssertEqual(results?.first?.date, nil)
        
        let _ = sut.createOrUpdateLocalEventWithEventDTO(eventDto,
                                                         inContext: .main)
        
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        XCTAssertEqual(newResults?.first?.viewId, id)
        XCTAssertEqual(results?.first?.date, eventDto.date)
    }
    func test_updateLocalEvent_updatesLocalEventWithDTO()async{
        let id = UUID().uuidString
        let eventDto = BroadcastDTO.mock(id:id,
                                     ownersIds: ["1","2"],
                                     usersIds: ["3","4"])
        let localEvent = Broadcast(context: context)
        sut.updateLocalEvent(localEvent, withDTO: eventDto, inContext: .main)
        XCTAssertEqual(localEvent.viewId, eventDto.id)
        XCTAssertEqual(localEvent.date ?? Date.now, eventDto.date)
        XCTAssertEqual(localEvent.obvan?.viewId, eventDto.obvanId)
        XCTAssertEqual(localEvent.venue?.id, eventDto.venueID)
        XCTAssertEqual(localEvent.homeClub?.id, eventDto.homeClubId)
        XCTAssertEqual(localEvent.guestClub?.id, eventDto.guestClubId)
        XCTAssertEqual(localEvent.owners?.count, eventDto.ownersIds.count)
        XCTAssertEqual(localEvent.members?.count, eventDto.membersIds.count)
        XCTAssertEqual(localEvent.venuePoints?.count, eventDto.venuePoints.count)
        XCTAssertEqual(localEvent.crews?.count, eventDto.crews.count)
        XCTAssertEqual(localEvent.venueSchemaPreview?.id, eventDto.venuePreviewId)
        XCTAssertEqual(localEvent.obvanPreview?.id, eventDto.obvanPreviewId)
    }
    @MainActor
    func test_removeEvent_removesLocalEventUsingDTO(){
        let id = UUID().uuidString
        let eventDto = BroadcastDTO.mock(id:id)
        
        let request = Broadcast.fetchRequest()
        var results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)

        let _ =  sut.createOrUpdateLocalEventWithEventDTO(eventDto, inContext: .main)
        results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 1)
        //check if LocalImages for previews, venuePoints and crews are created and existed
        assertEntitiesExistence(ofType: LocalImage.self, withIds: ["locPrevId-\(id)","obvanPrevId-\(id)"], in: context, shouldExist: true)
        var resultPoints = try? context.fetch(VenuePoint.fetchRequest())
        var resultUnits = try? context.fetch(Crew.fetchRequest())
        XCTAssertEqual(resultPoints?.count, 3)
        XCTAssertEqual(resultUnits?.count, 3)
        
         sut.removeEventWithDTO(eventDto, inContext: .main)
        results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        //check if LocalImages for previews, venuePoints and crews are removed
        assertEntitiesExistence(ofType: LocalImage.self, withIds: ["locPrevId-\(id)","obvanPrevId-\(id)"], in: context, shouldExist: false)
        resultPoints = try? context.fetch(VenuePoint.fetchRequest())
        resultUnits = try? context.fetch(Crew.fetchRequest())
        XCTAssertEqual(resultPoints?.count, 0)
        XCTAssertEqual(resultUnits?.count, 0)
    }
    @MainActor
    func test_removeLocalEvent_removesLocalEvent() {
        let id = UUID().uuidString
        let request = Broadcast.fetchRequest()
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        let localEvent = sut.fetchOrCreateObject(ofType: Broadcast.self,
                                                 predicate: NSPredicate(format: "id == %@", id),
                                                 in: context) { ctx in
            let newEvent = Broadcast(context: ctx)
            newEvent.id = id
            return newEvent
        }
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        sut.removeLocalEvent(localEvent, inContext: .main)
        let removeResults = try? context.fetch(request)
        XCTAssertEqual(removeResults?.count, 0)
    }
    // MARK: - Images
    func test_fetchImagesByType_fetchesImagesByType() async {
        let image = UIImage(systemName: "photo")!
        let id = UUID().uuidString
        let type: GlobalProperties.ImageType = .venue

        _ = sut.createOrUpdateLocalImageWithId(
            id,
            withImage: image,
            andType: type,
            inContext: .main
        )

        let images = sut.fetchImagesByType(type, inContext: .main)
        XCTAssertEqual(images.count, 1)
        XCTAssertTrue(images.contains { $0.id == id })
    }
    func test_сreateOrUpdateLocalImageWithIdUIImageAndType_createsLocalImage() {
        let id = UUID().uuidString
        let image = UIImage(systemName: "photo")!
        let type: GlobalProperties.ImageType = .club
        let localImage = sut.createOrUpdateLocalImageWithId(
            id,
            withImage: image,
            andType: type,
            inContext: .main
        )
        XCTAssertEqual(localImage.id, id)
        XCTAssertEqual(localImage.type, type.rawValue)

        let fileExists = ImageSizes.allCases.allSatisfy { size in
            ImagesManager.loadImage(imageSize: size, id: id) != nil
        }
        XCTAssertTrue(fileExists)
    }
    func test_createOrUpdateLocalImageWithImageDTO_createsLocalImage() {
        let image = UIImage(systemName: "photo")!
        let id = UUID().uuidString
        let type: GlobalProperties.ImageType = .venueTemplate
        let dto = ImageDTO(id: id, type: type.rawValue, lastUpdated: .now)
        let localImage = sut.createOrUpdateLocalImageWithImageData(
            imageDTO: dto,
            withImage: image,
            inContext: .main
        )
        XCTAssertEqual(localImage.id, id)
        XCTAssertEqual(localImage.type, type.rawValue)
        let fileExists = ImageSizes.allCases.allSatisfy { size in
            ImagesManager.loadImage(imageSize: size, id: id) != nil
        }
        XCTAssertTrue(fileExists)
    }

    func test_removeImageWithId_removesLocalImageAndLocalData() async {
        let image = UIImage(systemName: "photo")!
        let id = UUID().uuidString
        let type: GlobalProperties.ImageType = .club

        _ = sut.createOrUpdateLocalImageWithId(
            id,
            withImage: image,
            andType: type,
            inContext: .main
        )

        try? await Task.sleep(nanoseconds: 200_000_000) // time to save (0.2s)

        sut.removeImageWithId(id, inContext: .main)

        try? await Task.sleep(nanoseconds: 200_000_000) // time to remove (0.2s)

        let images = sut.fetchImagesByType(type, inContext: .main)
        XCTAssertFalse(images.contains { $0.id == id })

        let filesExist = ImageSizes.allCases.contains {
            ImagesManager.loadImage(imageSize: $0, id: id) != nil
        }
        XCTAssertFalse(filesExist)
    }

    // MARK: - Venue
    func test_createOrUpdateLocalLocationWithLocation_createsNewLocationAndAssignsData() {
        // Given
        let id = UUID().uuidString
        let imageId1 = UUID().uuidString
        let imageId2 = UUID().uuidString
        let backgroundId = UUID().uuidString
        
        let dto = VenueDTO(
            id: id,
            lastUpdated: .now,
            title: "Test Title",
            address: "Test Address",
            imagesIds: [imageId1, imageId2],
            venueSchemaId: backgroundId
        )
        
        // When
        var localLocation =  sut.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .main)
        
        // Then
        XCTAssertEqual(localLocation.id, id)
        XCTAssertEqual(localLocation.title, dto.title)
        XCTAssertEqual(localLocation.lastUpdated, dto.lastUpdated)
        XCTAssertEqual(localLocation.address, dto.address)
        XCTAssertEqual(localLocation.viewImages.count, 2)
        XCTAssertEqual(localLocation.broadcastSchema?.id, backgroundId)
        
        let newDto = VenueDTO(
            id: id,
            lastUpdated: .now,
            title: "Test New Title",
            address: "Test New Address",
            imagesIds: [imageId1],
            venueSchemaId: nil
        )
        localLocation = sut.createOrUpdateLocalLocationWithLocationDTO(newDto, inContext: .main)
        
        XCTAssertEqual(localLocation.id, id)
        XCTAssertEqual(localLocation.title, newDto.title)
        XCTAssertEqual(localLocation.lastUpdated, newDto.lastUpdated)
        XCTAssertEqual(localLocation.address, newDto.address)
        XCTAssertEqual(localLocation.viewImages.count, 1)
        XCTAssertEqual(localLocation.broadcastSchema?.id, nil)
    }
    
    func test_cleanImagesInLocalLocation_shouldRemoveAllImagesAndBackground()  {
        let image1 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .venue,
            inContext: .main
        )

        let image2 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .venue,
            inContext: .main
        )

        let backgroundImage = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .venue,
            inContext: .main
        )
        let location = Venue(context: sut.mainContext)
        location.id = UUID().uuidString
        location.title = "Test Location"
        location.addToImages(image1)
        location.addToImages(image2)
        location.broadcastSchema = backgroundImage

        XCTAssertEqual(location.viewImages.count, 2)
        XCTAssertNotNil(location.broadcastSchema)

        let exist1 = ImagesManager.imageExists(withId: image1.viewId)
        let exist2 = ImagesManager.imageExists(withId: image2.viewId)
        let existBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertTrue(exist1, "image1 should be saved in device")
        XCTAssertTrue(exist2, "image2 should be saved in device")
        
        XCTAssertTrue(existBG, "backgroundImage should be saved from device")

        
        sut.cleanImagesInLocalLocation(location,andBackground: true, inContext: .main)

        XCTAssertEqual(location.viewImages.count, 0)
        XCTAssertNil(location.broadcastSchema)

        let allImages = sut.fetchImagesByType(.venue, inContext: .main)
        XCTAssertEqual(allImages.count, 1) //bg exists
        let removed1 = ImagesManager.imageExists(withId: image1.viewId)
        let removed2 = ImagesManager.imageExists(withId: image2.viewId)
        let removedBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertFalse(removed1, "image1 should be removed from device")
        XCTAssertFalse(removed2, "image2 should be removed from device")
        XCTAssertTrue(removedBG, "backgroundImage should not be removed from device")
    }
    
    func test_updateLocalLocationWithData_updatesLocalLocation()  {
        let images = [UIImage.testImage]
        let title = "title"
        let address = "address"
        let background = sut.createOrUpdateLocalImageWithId("bgId", withImage: UIImage.testImage, andType: .venue, inContext: .main)
        let dto = VenueDTO.mock(id: "venue")
        let location =  sut.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .main)
        
         sut.updateLocalLocation(location, withTitle: title, address: address, localImages: images, locationBackground: background, inContext: .main)
        
        XCTAssertEqual(location.viewImages.count, 1)
        XCTAssertEqual(location.title, title)
        XCTAssertEqual(location.address, address)
        XCTAssertNotNil(location.broadcastSchema)
        //twice
        let newTitle = "newTitle"
        let newAddress = "newAddress"
        let newImages = [UIImage.testImage,UIImage.testImage,UIImage.testImage]
         sut.updateLocalLocation(location, withTitle: newTitle, address: newAddress, localImages: newImages, locationBackground: nil, inContext: .main)
        XCTAssertEqual(location.viewImages.count, 3)
        XCTAssertEqual(location.title, newTitle)
        XCTAssertEqual(location.address, newAddress)
        XCTAssertNil(location.broadcastSchema)
    }
    func test_removeLocalLocation_removesImagesAndLocation()async{
        let image1 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .venue,
            inContext: .main
        )

        let image2 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .venue,
            inContext: .main
        )

        let backgroundImage = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .venue,
            inContext: .main
        )
        let location = Venue(context: sut.mainContext)
        location.id = UUID().uuidString
        location.title = "Test Location"
        location.addToImages(image1)
        location.addToImages(image2)
        location.broadcastSchema = backgroundImage

        XCTAssertEqual(location.viewImages.count, 2)
        XCTAssertNotNil(location.broadcastSchema)

        let exist1 = ImagesManager.imageExists(withId: image1.viewId)
        let exist2 = ImagesManager.imageExists(withId: image2.viewId)
        let existBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertTrue(exist1, "image1 should be saved in device")
        XCTAssertTrue(exist2, "image2 should be saved in device")
        
        XCTAssertTrue(existBG, "backgroundImage should be saved from device")

        
        sut.removeLocalLocation(location, inContext: .main)
        sut.saveContextSync(type: .main, publish: .venues, id: [])
        let request = Venue.fetchRequest()
        let result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 0)
        XCTAssertEqual(location.viewImages.count, 0)
        XCTAssertNil(location.broadcastSchema)

        let allImages = sut.fetchImagesByType(.venue, inContext: .main)
        XCTAssertEqual(allImages.count, 1) //bg exists
        let removed1 = ImagesManager.imageExists(withId: image1.viewId)
        let removed2 = ImagesManager.imageExists(withId: image2.viewId)
        let removedBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertFalse(removed1, "image1 should be removed from device")
        XCTAssertFalse(removed2, "image2 should be removed from device")
        XCTAssertTrue(removedBG, "backgroundImage should not be removed from device")
        
    }

    // MARK: - obvan
    func test_createOrUpdateLocalObvanWithDTO_createsAndUpdatesObvan() async {
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        _ = sut.createOrUpdateLocalObvanWithDTO(dto, inContext: .main)
        //except that obvan created
        let request = Obvan.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, id)
            XCTAssertEqual(result.first?.name, "obvanName-\(id)")
            XCTAssertEqual(result.first?.image?.id, "obvanImgId-\(id)")
            XCTAssertEqual(result.first?.broadcaster, "broadcasterName-\(id)")
        } else {
            XCTFail("Obvan Entity must be created")
        }
    }
    
    func test_updateLocalObvanWithDTO_updatesObvan(){
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        let obvan = Obvan(context: context)
        sut.updateLocalObvan(obvan,
                             withObvan: dto,
                             inContext: .main)
        //except that obvan created and updated
        let request = Obvan.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, id)
            XCTAssertEqual(result.first?.name, "obvanName-\(id)")
            XCTAssertEqual(result.first?.image?.id, "obvanImgId-\(id)")
            XCTAssertEqual(result.first?.broadcaster, "broadcasterName-\(id)")
        } else {
            XCTFail("Obvan Entity must be created")
        }
    }
    
    func test_removeObvan_removesObvan() {
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        let obvan = sut.createOrUpdateLocalObvanWithDTO(dto, inContext: .main)
        //except that obvan created
        let request = Obvan.fetchRequest()
        let imageRequest = LocalImage.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, id)
            XCTAssertEqual(result.first?.name, "obvanName-\(id)")

            
            XCTAssertEqual(result.first?.broadcaster, "broadcasterName-\(id)")
        } else {
            XCTFail("Obvan Entity must be created")
        }
        if let result = try? context.fetch(imageRequest){
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, "obvanImgId-\(id)")
            XCTAssertEqual(result.first?.type, GlobalProperties.ImageType.obvan.rawValue)
        }
        
         sut.removeObvan(obvan, inContext: .main)
         sut.saveContextSync(type: .main, publish: .obvans, id: [])
        
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 0)
        } else {
            XCTFail("Obvan Entity must be created")
        }
        
        if let result = try? context.fetch(imageRequest){
            XCTAssertEqual(result.count, 0)
        }
    }
    
    func test_removeObvanWithId_removesObvan(){
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        let _ =  sut.createOrUpdateLocalObvanWithDTO(dto, inContext: .main)
        //except that obvan created
        let request = Obvan.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, id)
            XCTAssertEqual(result.first?.name, "obvanName-\(id)")
            XCTAssertEqual(result.first?.broadcaster, "broadcasterName-\(id)")
        } else {
            XCTFail("Obvan Entity must be created")
        }
        
         sut.removeObvanWithId(id, inContext: .main)
         sut.saveContextSync(type: .main, publish: .obvans, id: [])
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 0)
        } else {
            XCTFail("Obvan Entity must be created")
        }
    }
    // MARK: - Clubs
    func test_fetchAllLocalClubs_fetchesAllClubs(){
        let dtos = [ClubDTO.mock(id: "1"),
                    ClubDTO.mock(id: "2"),
                    ClubDTO.mock(id: "3"),
                    ClubDTO.mock(id: "4")]
        for dto in dtos{
           _ =  sut.createOrUpdateLocalClubWithDTO(dto, inContext: .main)
        }
        var result = sut.fetchAllLocalClubs(inContext: .main)
        XCTAssertEqual(result.count, dtos.count)
        sut.removeClubWithDTO(dtos[0], inContext: .main)
         sut.saveContextSync(type: .main, publish: .clubs, id: [])
        result = sut.fetchAllLocalClubs(inContext: .main)
        XCTAssertEqual(result.count, dtos.count - 1)
    }
    
    func test_createOrUpdateLocalClubWithDTO_createsAndUpdatesNewClub(){
        let id = "clubId"
        let dto = ClubDTO.mock(id: id)
        
        _ =  sut.createOrUpdateLocalClubWithDTO(dto, inContext: .main)
        
        let request = Club.fetchRequest()
        let result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.title, dto.title)
        XCTAssertEqual(result?.first?.contacts, dto.contacts)
        XCTAssertEqual(result?.first?.urlString, dto.urlString)
        XCTAssertEqual(result?.first?.imageLogo?.id, dto.imageLogoID)
        XCTAssertEqual(result?.first?.homeVenue?.id, dto.homeVenueID)
        
    }
    func test_createOrUpdateLocalClubWithDTO_fetchAndUpdateExistingClub(){
        let id = "clubId"
        let dto = ClubDTO.mock(id: id)
        let club = Club(context: context)
        club.id = id
        
        let request = Club.fetchRequest()
        var result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertNil(result?.first?.title)
        XCTAssertNil(result?.first?.contacts)
        XCTAssertNil(result?.first?.urlString)
        XCTAssertNil(result?.first?.imageLogo?.id)
        XCTAssertNil(result?.first?.homeVenue?.id)
        
        _ =  sut.createOrUpdateLocalClubWithDTO(dto, inContext: .main)
        
        
        result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.title, dto.title)
        XCTAssertEqual(result?.first?.contacts, dto.contacts)
        XCTAssertEqual(result?.first?.urlString, dto.urlString)
        XCTAssertEqual(result?.first?.imageLogo?.id, dto.imageLogoID)
        XCTAssertEqual(result?.first?.homeVenue?.id, dto.homeVenueID)
    }
 
    func test_updateLocalClubWithIdAndData_updatesClub(){
        let id = "clubId"
        let club = Club(context: context)
        club.id = id
        let request = Club.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertNil(result?.first?.title)
        XCTAssertNil(result?.first?.contacts)
        XCTAssertNil(result?.first?.urlString)
        XCTAssertNil(result?.first?.imageLogo?.id)
        XCTAssertNil(result?.first?.homeVenue?.id)
        
        let title = "title"
        let image = UIImage.testImage
        let contacts = "contacts"
        let urlString = "urlString"
        let locationId = "loctionId"
        let location =  sut.createOrUpdateLocalLocationWithLocationDTO(VenueDTO.mock(id: locationId), inContext: .main)

         sut.updateClubWith(id: id, title: title, uiimage: image, contacts: contacts, urlString: urlString, location: location, inContext: .main)
        result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.title, title)
        XCTAssertEqual(result?.first?.contacts, contacts)
        XCTAssertEqual(result?.first?.urlString, urlString)
        XCTAssertEqual(result?.first?.homeVenue, location)
        XCTAssertNotNil(result?.first?.imageLogo)
        
        guard let imageId = result?.first?.imageLogo?.id else { return }
        let imageRequest = LocalImage.fetchRequest()
        imageRequest.predicate = NSPredicate(format: "id == %@",imageId)
        if let localImage = try? context.fetch(imageRequest).first{
            XCTAssertEqual(localImage.type, GlobalProperties.ImageType.club.rawValue)
            XCTAssertEqual(localImage.parentClub, result?.first)
            let exist = ImagesManager.imageExists(withId: localImage.viewId)
            XCTAssertTrue(exist)
        }
    }
    func test_updateLocalClubWithData_updatesClub(){
        let id = "clubId"
        let club = Club(context: context)
        club.id = id
        let request = Club.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertNil(result?.first?.title)
        XCTAssertNil(result?.first?.contacts)
        XCTAssertNil(result?.first?.urlString)
        XCTAssertNil(result?.first?.imageLogo?.id)
        XCTAssertNil(result?.first?.homeVenue?.id)
        
        let title = "title"
        let image = UIImage.testImage
        let contacts = "contacts"
        let urlString = "urlString"
        let locationId = "loctionId"
        let location =  sut.createOrUpdateLocalLocationWithLocationDTO(VenueDTO.mock(id: locationId), inContext: .main)

         sut.updateClubWithClub(club:club, title: title, uiimage: image, contacts: contacts, urlString: urlString, location: location, inContext: .main)
        result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.title, title)
        XCTAssertEqual(result?.first?.contacts, contacts)
        XCTAssertEqual(result?.first?.urlString, urlString)
        XCTAssertEqual(result?.first?.homeVenue, location)
        XCTAssertNotNil(result?.first?.imageLogo)
        
        guard let imageId = result?.first?.imageLogo?.id else { return }
        let imageRequest = LocalImage.fetchRequest()
        imageRequest.predicate = NSPredicate(format: "id == %@",imageId)
        if let localImage = try? context.fetch(imageRequest).first{
            XCTAssertEqual(localImage.type, GlobalProperties.ImageType.club.rawValue)
            XCTAssertEqual(localImage.parentClub, result?.first)
            let exist = ImagesManager.imageExists(withId: localImage.viewId)
            XCTAssertTrue(exist)
        }
    }
    func test_removeClubWithDTO_removesClub(){
        let id = "clubId"
        let dto = ClubDTO.mock(id: id)
        let club = Club(context: context)
        club.id = id
        let title = "title"
        let image = UIImage.testImage
        let contacts = "contacts"
        let urlString = "urlString"
        let locationId = "loctionId"
        let location =  sut.createOrUpdateLocalLocationWithLocationDTO(VenueDTO.mock(id: locationId), inContext: .main)

         sut.updateClubWithClub(club:club, title: title, uiimage: image, contacts: contacts, urlString: urlString, location: location, inContext: .main)
        let imageId = club.imageLogo?.id
        
        sut.removeClubWithDTO(dto, inContext: .main)
         sut.saveContextSync(type: .main, publish: .clubs, id: [])
        //club , localImage
        let request = Club.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertTrue(result.isEmpty)
        } else {
            XCTFail("wrong request in club remove test")
        }
        if let imageId{
            let imageRequest = LocalImage.fetchRequest()
            imageRequest.predicate = NSPredicate(format: "id == %@",imageId)
            if let localImage = try? context.fetch(imageRequest){
                XCTAssertTrue(localImage.isEmpty)
                let exist = ImagesManager.imageExists(withId: imageId)
                XCTAssertFalse(exist)
            }
        } else {
            XCTFail("something wrong with imageLogo in removeClubTest")
        }
        
        
    }
    func test_removeLocalClub_removesClub(){
        let id = "clubId"
        let club = Club(context: context)
        club.id = id
        let title = "title"
        let image = UIImage.testImage
        let contacts = "contacts"
        let urlString = "urlString"
        let locationId = "loctionId"
        let location =  sut.createOrUpdateLocalLocationWithLocationDTO(VenueDTO.mock(id: locationId), inContext: .main)

         sut.updateClubWithClub(club:club, title: title, uiimage: image, contacts: contacts, urlString: urlString, location: location, inContext: .main)
        let imageId = club.imageLogo?.id
        sut.removeLocalClub(localClub: club, inContext: .main)
         sut.saveContextSync(type: .main, publish: .clubs, id: [])
        let request = Club.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertTrue(result.isEmpty)
        } else {
            XCTFail("wrong request in club remove test")
        }
        if let imageId{
            let imageRequest = LocalImage.fetchRequest()
            imageRequest.predicate = NSPredicate(format: "id == %@",imageId)
            if let localImage = try? context.fetch(imageRequest){
                XCTAssertTrue(localImage.isEmpty)
                let exist = ImagesManager.imageExists(withId: imageId)
                XCTAssertFalse(exist)
            }
        } else {
            XCTFail("something wrong with imageLogo in removeClubTest")
        }
    }
    
    // MARK: - Environment
    // MARK: Camera
    func test_createOrUpdateCamera_createAndUpdates(){
        let id = "camId"
        let dto = CameraDTO.mock(id: id)
        _ = sut.createOrUpdateCamera(dto, inContext: .main)
        let fetchRequest = Camera.fetchRequest()
        let result = try? context.fetch(fetchRequest)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.optic, dto.optic.rawValue)
    }
    func test_linkLocalCameraWithPoint_links(){
        let id = "camId"
        let dto = CameraDTO.mock(id: id)
        let camera = sut.createOrUpdateCamera(dto, inContext: .main)
        let point = VenuePoint(context: context)
        
        sut.linkLocalCamera(camera, withPoint: point, inContext: .main)
        XCTAssertEqual(camera.point, point)
        XCTAssertTrue(point.viewCameras.contains(camera))
    }
    func test_removeCameraWithDTO_removesCamera()async{
        let id = "camId"
        let dto = CameraDTO.mock(id: id)
        _ = sut.createOrUpdateCamera(dto, inContext: .main)
        let fetchRequest = Camera.fetchRequest()
        var result = try? context.fetch(fetchRequest)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.optic, dto.optic.rawValue)
        
        sut.removeCameraWithDTO(dto, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .cameras, id: [])
        result = try? context.fetch(fetchRequest)
        XCTAssertEqual(result?.count, 0)
    }
    
    func test_removeLocalCamera_removesCamera()async{
        let camera = Camera(context: context)
        let fetchRequest = Camera.fetchRequest()
        var result = try? context.fetch(fetchRequest)
        XCTAssertEqual(result?.count, 1)
        
        sut.removeLocalCamera(camera, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .cameras, id: [])
        result = try? context.fetch(fetchRequest)
        XCTAssertEqual(result?.count, 0)
    }
    // MARK: Sound
    
    func test_createOrUpdateSound_createsSound(){
        let id = "soundId"
        let dto = SoundDTO.mock(id: id)
        
        _ = sut.createOrUpdateSound(dto, inContext: .main)
        let request = Sound.fetchRequest()
        let result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.placeType, dto.placeType.rawValue)
        XCTAssertEqual(result?.first?.windDefence, dto.windDefence.rawValue)
    }
    
    func test_linkLocalSound_links(){
        let sound = Sound(context: context)
        let point = VenuePoint(context: context)
        sut.linkLocalSound(sound, withPoint: point, inContext: .main)
        XCTAssertEqual(sound.point, point)
        XCTAssertTrue(point.viewSounds.contains(sound))
    }
    
    func test_removeSoundWithDTO_removesSound()async{
        let id = "soundId"
        let dto = SoundDTO.mock(id: id)
        _ = sut.createOrUpdateSound(dto, inContext: .main)
        let request = Sound.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        sut.removeSoundWithDTO(dto, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .sounds, id: [])
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
        
    }
    func test_removeLocalSound_removesSound()async{
        let sound = Sound(context: context)
        let request = Sound.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        sut.removeLocalSound(sound, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .sounds, id: [])
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
    }
    
    // MARK: Light
    func test_createOrUpdateLight_createsLight(){
        let id = "lightId"
        let dto = LightDTO.mock(id: id)
        _ = sut.createOrUpdateLight(dto, inContext: .main)
        let request = Light.fetchRequest()
        let result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.lightType, dto.lightType.rawValue)
        
    }
    
    func test_linkLocalLight_lonks(){
        let light = Light(context: context)
        let point = VenuePoint(context: context)
        sut.linkLocalLight(light, WithPoint: point, InContext: .main)
        XCTAssertEqual(light.point, point)
        XCTAssertTrue(point.viewLights.contains(light))
    }
    
    func test_removeLightWithDTO_removesLight() async {
        let id = "lightId"
        let dto = LightDTO.mock(id: id)
        _ = sut.createOrUpdateLight(dto, inContext: .main)
        let request = Light.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        
        sut.removeLightWithDTO(dto, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .lights, id: [])
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
    }
    func test_removeLocalLight_removesLight()async{
        let light = Light(context: context)
        let request = Light.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        
        sut.removeLocalLight(light, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .lights, id: [])
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
    }
    // MARK: Hardware
    func test_createOrUpdateHardwareWithDTO_createsHardware(){
        let id = "hardwareId"
        let dto = HardwareDTO.mock(id: id)
        _ = sut.createOrUpdateHardwareWithDTO(dto, inContext: .main)
        let request = Hardware.fetchRequest()
        let result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.type, dto.envType.rawValue)
        XCTAssertEqual(result?.first?.channels, dto.chanels.joined(separator: ","))
    }
    
    func test_linkLocalHardware_links(){
        let hardware = Hardware(context: context)
        let unit = Crew(context: context)
        sut.linkLocalHardware(hardware, withUnit: unit, inContext: .main)
        XCTAssertEqual(hardware.crew, unit)
        XCTAssertEqual(unit.hardware, hardware)
    }
    func test_removeHardwareWithDTO_removesHardware() async {
        let id = "hardwareId"
        let dto = HardwareDTO.mock(id: id)
        _ = sut.createOrUpdateHardwareWithDTO(dto, inContext: .main)
        let request = Hardware.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        
        sut.removeHardwareWithDTO(dto, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .hardwares, id: [])
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
    }
    func test_removeLocalHardware_removesHardware() async {
        let hardware = Hardware(context: context)
        let request = Hardware.fetchRequest()
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        
        sut.removeLocalHardware(hardware, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .hardwares, id: [])
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
    }
    
    // MARK: - LocationPoints
    func test_createOrUpdateLocalPointWithPointDTO_createsAndUpdatesPoint()async{
        let id = "pointDtoId"
        let pointDto = VenuePointDTO.mock(id: id)
        
        let request = VenuePoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
        
        let _ = sut.createOrUpdateLocalPointWithPointDTO(pointDto, inContext: .main)
        
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.coordinateX, Float(pointDto.coordinateX))
        XCTAssertEqual(result?.first?.coordinateY, Float(pointDto.coordinateY))
        XCTAssertEqual(result?.first?.rotation, Int16(pointDto.rotation))
        XCTAssertEqual(result?.first?.scaleFactor, Float(pointDto.scaleFactor))
        XCTAssertEqual(result?.first?.image?.id, pointDto.imageId)
        XCTAssertEqual(result?.first?.members?.count, pointDto.memberIds.count)
        XCTAssertEqual(result?.first?.cameras?.count, pointDto.cameras.count)
        XCTAssertEqual(result?.first?.sounds?.count, pointDto.sounds.count)
        XCTAssertEqual(result?.first?.lights?.count, pointDto.lights.count)
        
        //twice
        let _ = sut.createOrUpdateLocalPointWithPointDTO(pointDto, inContext: .main)
        
        result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.coordinateX, Float(pointDto.coordinateX))
        XCTAssertEqual(result?.first?.coordinateY, Float(pointDto.coordinateY))
        XCTAssertEqual(result?.first?.rotation, Int16(pointDto.rotation))
        XCTAssertEqual(result?.first?.scaleFactor, Float(pointDto.scaleFactor))
        XCTAssertEqual(result?.first?.image?.id, pointDto.imageId)
        XCTAssertEqual(result?.first?.members?.count, pointDto.memberIds.count)
        XCTAssertEqual(result?.first?.cameras?.count, pointDto.cameras.count)
        XCTAssertEqual(result?.first?.sounds?.count, pointDto.sounds.count)
        XCTAssertEqual(result?.first?.lights?.count, pointDto.lights.count)
  }
    func test_updateLocalPoint_withSimpleData_updatesLocalPoint(){
        let x = 20.0
        let y = 30.0
        let rot = 90
        let scale = 2.0
        
        let point = VenuePoint(context: context)
        sut.updateLocalPoint(point,
                             withX: x,
                             y: y,
                             rotation: rot,
                             scaleFactor: scale,
                             inContext: .main)
        
        XCTAssertEqual(point.coordinateX, Float(x))
        XCTAssertEqual(point.coordinateY, Float(y))
        XCTAssertEqual(point.rotation, Int16(rot))
        XCTAssertEqual(point.scaleFactor, Float(scale))
        
    }
    func test_updateLocalPoint_withDTO_updatesPoint() {
        let id = "pointDtoId"
        let pointDto = VenuePointDTO.mock(id: id)
        
       let point = VenuePoint(context: context)
        
         sut.updateLocalPoint(point,
                             withPointDTO: pointDto,
                             inContext: .main)
        
//        XCTAssertEqual(venuePoint.id, id)
        XCTAssertEqual(point.coordinateX, Float(pointDto.coordinateX))
        XCTAssertEqual(point.coordinateY, Float(pointDto.coordinateY))
        XCTAssertEqual(point.rotation, Int16(pointDto.rotation))
        XCTAssertEqual(point.scaleFactor, Float(pointDto.scaleFactor))
        XCTAssertEqual(point.image?.id, pointDto.imageId)
        XCTAssertEqual(point.members?.count, pointDto.memberIds.count)
        XCTAssertEqual(point.cameras?.count, pointDto.cameras.count)
        XCTAssertEqual(point.sounds?.count, pointDto.sounds.count)
        XCTAssertEqual(point.lights?.count, pointDto.lights.count)
    }
    func test_updateLocalPoint_withTemplatePoint_updatesPoint(){
        let templatePoint = sut.createOrUpdateTemplatePointWithTemplatePointDTO(TemplatePointDTO.mock(id: "id"), inContext: .main)
        
        let localPoint = VenuePoint(context: context)
        
        sut.updateLocalPoint(localPoint,
                             withTemplatePoint: templatePoint,
                             inContext: .main)
        
        XCTAssertEqual(localPoint.coordinateX, templatePoint.coordinateX)
        XCTAssertEqual(localPoint.coordinateY, templatePoint.coordinateY)
        XCTAssertEqual(localPoint.rotation, templatePoint.rotation)
        XCTAssertEqual(localPoint.scaleFactor, templatePoint.scaleFactor)
        XCTAssertEqual(localPoint.number, templatePoint.number)
        XCTAssertEqual(localPoint.cameras?.count, templatePoint.cameraDTOs.count)
        XCTAssertEqual(localPoint.sounds?.count, templatePoint.soundDTOs.count)
        XCTAssertEqual(localPoint.lights?.count, templatePoint.lightDTOs.count)
        XCTAssertEqual(localPoint.task, templatePoint.task)
        XCTAssertEqual(localPoint.pointDescription, templatePoint.pointDescription)
        
        //updated twice
        sut.updateLocalPoint(localPoint,
                             withTemplatePoint: templatePoint,
                             inContext: .main)
        
        XCTAssertEqual(localPoint.coordinateX, templatePoint.coordinateX)
        XCTAssertEqual(localPoint.coordinateY, templatePoint.coordinateY)
        XCTAssertEqual(localPoint.rotation, templatePoint.rotation)
        XCTAssertEqual(localPoint.scaleFactor, templatePoint.scaleFactor)
        XCTAssertEqual(localPoint.number, templatePoint.number)
        XCTAssertEqual(localPoint.cameras?.count, templatePoint.cameraDTOs.count)
        XCTAssertEqual(localPoint.sounds?.count, templatePoint.soundDTOs.count)
        XCTAssertEqual(localPoint.lights?.count, templatePoint.lightDTOs.count)
        XCTAssertEqual(localPoint.task, templatePoint.task)
        XCTAssertEqual(localPoint.pointDescription, templatePoint.pointDescription)

    }
    func test_removeLocationPoint_withDTO_removesPoint() async {
        let dto = VenuePointDTO.mock(id: "id")
        let locationPoint = sut.createOrUpdateLocalPointWithPointDTO(dto, inContext: .main)
        let camIds = locationPoint.viewCameras.map{$0.viewId}
        let soundIds = locationPoint.viewSounds.map{$0.viewId}
        let lightIds = locationPoint.viewLights.map{$0.viewId}
        let imageId = locationPoint.viewImageId

        assertEntitiesExistence(ofType: Camera.self, withIds: camIds, in: context, shouldExist: true)
        assertEntitiesExistence(ofType: Sound.self, withIds: soundIds, in: context, shouldExist: true)
        assertEntitiesExistence(ofType: Light.self, withIds: lightIds, in: context, shouldExist: true)
        assertEntitiesExistence(ofType: LocalImage.self, withIds: [imageId], in: context, shouldExist: true)

        sut.removeLocationPoint(dto, inContext: .main)
        try? context.save()
        
        let request = VenuePoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dto.id)
        let result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
        
        assertEntitiesExistence(ofType: Camera.self, withIds: camIds, in: context, shouldExist: false)
        assertEntitiesExistence(ofType: Sound.self, withIds: soundIds, in: context, shouldExist: false)
        assertEntitiesExistence(ofType: Light.self, withIds: lightIds, in: context, shouldExist: false)
        assertEntitiesExistence(ofType: LocalImage.self, withIds: [imageId], in: context, shouldExist: false)
    }
    // MARK: - Units
    @MainActor
    func test_createOrUpdateLocalObvanUnitWithObvanUnit_createsAndUpdatesUnit(){
        let id = "unitId"
        let dto = CrewDTO.mock(id: id)
        
        let request = Crew.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        var result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
        
        _ = sut.createOrUpdateLocalUnitWithUnitDTO(dto, inContext: .main)
        
        result = try? context.fetch(request)
    
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, id)
        XCTAssertEqual(result?.first?.coordinateX, Float(dto.coordinateX))
        XCTAssertEqual(result?.first?.coordinateY, Float(dto.coordinateY))
        XCTAssertEqual(result?.first?.rotation, Int16(dto.rotation))
        XCTAssertEqual(result?.first?.scaleFactor, Float(dto.scaleFactor))
        XCTAssertEqual(result?.first?.task, dto.task)
        XCTAssertEqual(result?.first?.member?.id, dto.memberId)
        XCTAssertEqual(result?.first?.hardware?.id, dto.hardware?.id)
        
    }
    
    func test_createUnitWithUser_createsUnitWithUser(){
        let userId = "userId"
        let userDto = MemberDTO.mock(id: userId)
        let localUser = sut.createOrUpdateLocalUserWithUserDTO(userDto, inContext: .main)
        let localHardwareType = HardwareType.evs
        let position = UserSpecialization.director
        
        let localUnit = sut.createUnitWithUser(localUser,
                                   andPosition: position,
                                   andHardware: localHardwareType,
                                   inContext: .main)
        let result = try? context.fetch(Crew.fetchRequest())
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(localUnit.member, localUser)
        XCTAssertEqual(localUnit.hardware?.type, localHardwareType.rawValue)
        XCTAssertEqual(localUnit.position, position.rawValue)
    }
    
    @MainActor
    func test_removeLocalUnit_removesLocalUnitAndHardware() async{
        let id  = "unitId"
        let hardwareId = "hardwareId-\(id)"
        let dto = CrewDTO.mock(id: id)
        let _ = sut.createOrUpdateLocalUnitWithUnitDTO(dto, inContext: .main)
        
        assertEntitiesExistence(ofType: Crew.self,
                                withIds: [id],
                                in: context,
                                shouldExist: true)
        
        assertEntitiesExistence(ofType: Hardware.self,
                                withIds: [hardwareId],
                                in: context,
                                shouldExist: true)
        
        sut.removeLocalUnitUsingUnitDTO(dto, inContext: .main)
        await sut.saveContextAsync(type: .main, publish: .none, id: [])
        
        assertEntitiesExistence(ofType: Crew.self,
                                withIds: [id],
                                in: context,
                                shouldExist: false)
        
        assertEntitiesExistence(ofType: Hardware.self,
                                withIds: [hardwareId],
                                in: context,
                                shouldExist: false)
        
    }
    
    // MARK: - Templates
    func test_fetchOrCreateLocalTemplateWithId_CreatesNewTemplate() {
        let id = UUID().uuidString
        let template = sut.fetchOrCreateObject(
            ofType: Template.self,
            predicate: NSPredicate(format: "id == %@", id),
            in: container.viewContext
        ) { ctx in
            let newTemplate = Template(context: ctx)
            newTemplate.id = id
            return newTemplate
        }
        XCTAssertEqual(template.id, id)

        let request: NSFetchRequest<Template> =
            Template.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1)
    }

    func test_createOrUpdateLocalTemplateWithTemplate_CreatesTemplateAndPoints()
    {
        let dto = TemplateDTO.mock(id: "template1")
        _ = sut.createOrUpdateLocalTemplateWithTemplateDTO(
            dto,
            inConext: .main
        )

        let request: NSFetchRequest<Template> =
            Template.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "template1")
        let template = try? container.viewContext.fetch(request).first

        XCTAssertNotNil(template)
        XCTAssertEqual(template?.name, dto.name)
        XCTAssertEqual(template?.templatePoints?.count, 1)
    }

    func test_updateLocalTemplate_UpdatesExistingData() {
        let dto = TemplateDTO.mock(id: "template2")
        _ = sut.createOrUpdateLocalTemplateWithTemplateDTO(
            dto,
            inConext: .main
        )

        let updatedDTO = TemplateDTO(
            id: "template2",
            lastUpdated: .now,
            name: "UpdatedName",
            templatePoints: dto.templatePointDTOs
        )
        _ = sut.createOrUpdateLocalTemplateWithTemplateDTO(
            updatedDTO,
            inConext: .main
        )

        let request: NSFetchRequest<Template> =
            Template.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "template2")
        let template = try? container.viewContext.fetch(request).first

        XCTAssertEqual(template?.name, "UpdatedName")
    }

    func test_removeLocalTemplate_DeletesTemplateAndPoints() {
        let dto = TemplateDTO.mock(id: "template3")
        _ = sut.createOrUpdateLocalTemplateWithTemplateDTO(
            dto,
            inConext: .main
        )
        let fetchRequest: NSFetchRequest<Template> =
            Template.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "template3")
        guard
            let template = try? container.viewContext.fetch(fetchRequest).first
        else {
            XCTFail("Template not found before delete")
            return
        }

        sut.removeLocalTemplate(template, inContext: .main)

        let deleted = try? context.fetch(fetchRequest)
        XCTAssertEqual(deleted?.count, 0)
    }

    func test_createLocalLocationPointFromTemplatePoint_CopiesAllFields() {
        let dto = TemplateDTO.mock(id: "template4")
        _ = sut.createOrUpdateLocalTemplateWithTemplateDTO(
            dto,
            inConext: .main
        )

        let fetchRequest: NSFetchRequest<TemplatePoint> =
            TemplatePoint.fetchRequest()
        let points = try? container.viewContext.fetch(fetchRequest)
        guard let templatePoint = points?.first else {
            XCTFail("No template venuePoint created")
            return
        }

        let locationPoint =
            sut.createLocalLocationPointFromTemplatePoint(
                templatePoint,
                inContext: .main
            )

        XCTAssertEqual(locationPoint.coordinateX, templatePoint.coordinateX)
        XCTAssertEqual(locationPoint.coordinateY, templatePoint.coordinateY)
        XCTAssertEqual(locationPoint.task, templatePoint.task)
    }
    
    func test_mapTemplateToLocationPoints_createsArrayOfLocalLocationPoints() async{
        let id = "temolateId"
        let dto = TemplateDTO.mock(id: id)
        var template = sut.createOrUpdateLocalTemplateWithTemplateDTO(dto, inConext: .main)
        
        XCTAssertEqual(template.id, id)
        XCTAssertEqual(template.name, dto.name)
        XCTAssertEqual(template.templatePoints?.count, dto.templatePointDTOs.count)
        (0..<dto.templatePointDTOs.count).forEach { index in
            XCTAssertEqual(template.viewTemplatePoints[index].cameraDTOs.count, dto.templatePointDTOs[index].cameras.count)
            XCTAssertEqual(template.viewTemplatePoints[index].soundDTOs.count, dto.templatePointDTOs[index].sounds.count)
            XCTAssertEqual(template.viewTemplatePoints[index].lightDTOs.count, dto.templatePointDTOs[index].lights.count)
        }
        
        var result =  sut.mapTemplateToLocationPoints(template: template, inContext: .main)
        
        XCTAssertLessThanOrEqual(template.viewTemplatePoints.count,result.count)
        
        (0..<result.count).forEach { index in
            
            XCTAssertEqual(template.viewTemplatePoints[index].pointDescription, result[index].pointDescription)
            XCTAssertEqual(template.viewTemplatePoints[index].coordinateX, result[index].coordinateX)
            XCTAssertEqual(template.viewTemplatePoints[index].coordinateY, result[index].coordinateY)
            XCTAssertEqual(template.viewTemplatePoints[index].rotation, result[index].rotation)
            XCTAssertEqual(template.viewTemplatePoints[index].scaleFactor, result[index].scaleFactor)
            XCTAssertEqual(template.viewTemplatePoints[index].task, result[index].task)
            XCTAssertEqual(template.viewTemplatePoints[index].number, result[index].number)
            XCTAssertEqual(template.viewTemplatePoints[index].cameraDTOs.count, result[index].cameras?.count)
            XCTAssertEqual(template.viewTemplatePoints[index].soundDTOs.count, result[index].sounds?.count)
            XCTAssertEqual(template.viewTemplatePoints[index].lightDTOs.count, result[index].lights?.count)
        }
        
        //twice
        template = sut.createOrUpdateLocalTemplateWithTemplateDTO(dto, inConext: .main)

        result =  sut.mapTemplateToLocationPoints(template: template, inContext: .main)
        
        XCTAssertLessThanOrEqual(template.viewTemplatePoints.count,result.count)
        
        (0..<result.count).forEach { index in
            
            XCTAssertEqual(template.viewTemplatePoints[index].pointDescription, result[index].pointDescription)
            XCTAssertEqual(template.viewTemplatePoints[index].coordinateX, result[index].coordinateX)
            XCTAssertEqual(template.viewTemplatePoints[index].coordinateY, result[index].coordinateY)
            XCTAssertEqual(template.viewTemplatePoints[index].rotation, result[index].rotation)
            XCTAssertEqual(template.viewTemplatePoints[index].scaleFactor, result[index].scaleFactor)
            XCTAssertEqual(template.viewTemplatePoints[index].task, result[index].task)
            XCTAssertEqual(template.viewTemplatePoints[index].number, result[index].number)
            XCTAssertEqual(template.viewTemplatePoints[index].cameraDTOs.count, result[index].cameras?.count)
            XCTAssertEqual(template.viewTemplatePoints[index].soundDTOs.count, result[index].sounds?.count)
            XCTAssertEqual(template.viewTemplatePoints[index].lightDTOs.count, result[index].lights?.count)
        }
    }
    
    func test_localPointCreatedWithCameras()  {
        let dto = VenuePointDTO.mock(id: "123")
        let point = sut.createOrUpdateLocalPointWithPointDTO(dto, inContext: .main)

        XCTAssertEqual(point.cameras?.count, 2, "Expected 2 cameras")
        XCTAssertEqual(point.viewSounds.count, 2, "Expected 2 sounds")
        XCTAssertEqual(point.viewLights.count, 1, "Expected 1 light")
    }

    func test_createTemplateWithLocalLocationPoints_createsLocalTemplate(){
        let dtos = [VenuePointDTO.mock(id: "1"),
                    VenuePointDTO.mock(id: "2"),
                    VenuePointDTO.mock(id: "3"),
                    VenuePointDTO.mock(id: "4"),
                    VenuePointDTO.mock(id: "5")]
        
        let points = dtos.map{sut.createOrUpdateLocalPointWithPointDTO($0, inContext: .main)}

        let name = "name"
        var template = sut.createTemplateWithLocalLocationPoints(points,
                                                  andName: name, inContext: .main)
        XCTAssertEqual(template.id, name)
        XCTAssertEqual(template.name, name)
        XCTAssertEqual(template.templatePoints?.count, points.count)

        
        for point in points {
            guard let viewPoint = template.viewTemplatePoints.first(where: { $0.pointDescription == point.pointDescription }) else {
                XCTFail("Missing view venuePoint with id \(point.id ?? "nil")")
                continue
            }

            XCTAssertEqual(viewPoint.pointDescription, point.pointDescription)
            XCTAssertEqual(viewPoint.coordinateX, point.coordinateX)
            XCTAssertEqual(viewPoint.coordinateY, point.coordinateY)
            XCTAssertEqual(viewPoint.rotation, point.rotation)
            XCTAssertEqual(viewPoint.scaleFactor, point.scaleFactor)
            XCTAssertEqual(viewPoint.task, point.task)
            XCTAssertEqual(viewPoint.number, point.number)

            XCTAssertEqual(viewPoint.cameraDTOs.count, point.cameras?.count ?? 0)
            XCTAssertEqual(viewPoint.soundDTOs.count, point.viewSounds.count)
            XCTAssertEqual(viewPoint.lightDTOs.count, point.viewLights.count)
        }
        
        //twice
        template = sut.createTemplateWithLocalLocationPoints(points,
                                                  andName: name, inContext: .main)
        XCTAssertEqual(template.id, name)
        XCTAssertEqual(template.name, name)
        XCTAssertEqual(template.templatePoints?.count, points.count)

        
        for point in points {
            guard let viewPoint = template.viewTemplatePoints.first(where: { $0.pointDescription == point.pointDescription }) else {
                XCTFail("Missing view venuePoint with id \(point.id ?? "nil")")
                continue
            }

            XCTAssertEqual(viewPoint.pointDescription, point.pointDescription)
            XCTAssertEqual(viewPoint.coordinateX, point.coordinateX)
            XCTAssertEqual(viewPoint.coordinateY, point.coordinateY)
            XCTAssertEqual(viewPoint.rotation, point.rotation)
            XCTAssertEqual(viewPoint.scaleFactor, point.scaleFactor)
            XCTAssertEqual(viewPoint.task, point.task)
            XCTAssertEqual(viewPoint.number, point.number)

            XCTAssertEqual(viewPoint.cameraDTOs.count, point.cameras?.count ?? 0)
            XCTAssertEqual(viewPoint.soundDTOs.count, point.viewSounds.count)
            XCTAssertEqual(viewPoint.lightDTOs.count, point.viewLights.count)
        }

    }
    func test_createOrUpdateLocalPointWithPointDTO_createsAndUpdatesPoint1() async throws {
        // given
        let pointId = UUID().uuidString
        let imageId = UUID().uuidString
        let userId = UUID().uuidString
        let cameraId = UUID().uuidString
        let soundId = UUID().uuidString
        let lightId = UUID().uuidString

        let dto = VenuePointDTO(
            id: pointId,
            memberId: [userId],
            coordinateX: 10,
            coordinateY: 20,
            rotation: 45,
            scale: 2.0,
            imageId: imageId,
            number: 5,
            description: "Initial Description",
            task: "Initial Task",
            cameras: [CameraDTO(id: cameraId)],
            sounds: [SoundDTO(id: soundId)],
            lights: [LightDTO(id: lightId)]
        )

        // when
        let point = sut.createOrUpdateLocalPointWithPointDTO(dto, inContext: .main)

        // then
        XCTAssertEqual(point.id, pointId)
        XCTAssertEqual(point.coordinateX, 10)
        XCTAssertEqual(point.coordinateY, 20)
        XCTAssertEqual(point.rotation, 45)
        XCTAssertEqual(point.scaleFactor, 2.0)
        XCTAssertEqual(point.number, 5)
        XCTAssertEqual(point.pointDescription, "Initial Description")
        XCTAssertEqual(point.task, "Initial Task")
        XCTAssertEqual(point.image?.id, imageId)
        XCTAssertEqual(point.viewMembers.first?.id, userId)
        XCTAssertEqual(point.viewCameras.first?.id, cameraId)
        XCTAssertEqual(point.viewSounds.first?.id, soundId)
        XCTAssertEqual(point.viewLights.first?.id, lightId)

        // when — update
        let updatedDTO = VenuePointDTO(
            id: pointId, // same id
            memberId: [userId],
            coordinateX: 99,
            coordinateY: 88,
            rotation: 180,
            scale: 0.5,
            imageId: imageId, number: 3,
            description: "Updated Description",
            task: "Updated Task",
            cameras: [],
            sounds: [],
            lights: []
        )

        let updatedPoint = sut.createOrUpdateLocalPointWithPointDTO(updatedDTO, inContext: .main)

        // then — same object, but updated
        XCTAssertTrue(updatedPoint === point)
        XCTAssertEqual(updatedPoint.coordinateX, 99)
        XCTAssertEqual(updatedPoint.coordinateY, 88)
        XCTAssertEqual(updatedPoint.rotation, 180)
        XCTAssertEqual(updatedPoint.scaleFactor, 0.5)
        XCTAssertEqual(updatedPoint.number, 3)
        XCTAssertEqual(updatedPoint.pointDescription, "Updated Description")
        XCTAssertEqual(updatedPoint.task, "Updated Task")
        XCTAssertEqual(updatedPoint.viewCameras.count, 0)
        XCTAssertEqual(updatedPoint.viewSounds.count, 0)
        XCTAssertEqual(updatedPoint.viewLights.count, 0)
    }

    
    func test_updateLocalPoint_withPointDTO_updatesAllFields() async throws {
        // given
        let pointId = UUID().uuidString
        let imageId = UUID().uuidString
        let userId = UUID().uuidString
        let cameraId = UUID().uuidString
        let soundId = UUID().uuidString
        let lightId = UUID().uuidString

        let dto = VenuePointDTO(
            id: pointId,
            memberId: [userId], coordinateX: 123.45,
            coordinateY: 67.89,
            rotation: 90,
            scale: 1.5,
            imageId: imageId, number: 1,
            description: "Test Point",
            task: "Shoot",
            cameras: [CameraDTO(id: cameraId)],
            sounds: [SoundDTO(id: soundId)],
            lights: [LightDTO(id: lightId)]
        )

        let point = VenuePoint(context: context)
        point.id = pointId

        // when
        sut.updateLocalPoint(point, withPointDTO: dto, inContext: .main)

        // then
        XCTAssertEqual(point.coordinateX, Float(dto.coordinateX))
        XCTAssertEqual(point.coordinateY, Float(dto.coordinateY))
        XCTAssertEqual(point.rotation, Int16(dto.rotation))
        XCTAssertEqual(point.scaleFactor, Float(dto.scale))
        XCTAssertEqual(point.number, Int16(dto.number))
        XCTAssertEqual(point.pointDescription, dto.description)
        XCTAssertEqual(point.task, dto.task)
        XCTAssertEqual(point.image?.id, dto.imageId)
        XCTAssertEqual(point.viewMembers.count, 1)
        XCTAssertEqual(point.viewMembers.first?.id, userId)
        XCTAssertEqual(point.viewCameras.count, 1)
        XCTAssertEqual(point.viewCameras.first?.id, cameraId)
        XCTAssertEqual(point.viewSounds.count, 1)
        XCTAssertEqual(point.viewSounds.first?.id, soundId)
        XCTAssertEqual(point.viewLights.count, 1)
        XCTAssertEqual(point.viewLights.first?.id, lightId)
    }

    func test_createOrUpdateLocalTemplatePointWithTemplatePoint_populatesAllFieldsCorrectly() {
        // Given
        let id = UUID().uuidString
        let dto = TemplatePointDTO.mock(id: id)

        // When
        let point = sut.createOrUpdateTemplatePointWithTemplatePointDTO(dto, inContext: .main)

        // Then
        XCTAssertEqual(point.id, dto.id)
        XCTAssertEqual(point.coordinateX, Float(dto.coordinateX))
        XCTAssertEqual(point.coordinateY, Float(dto.coordinateY))
        XCTAssertEqual(point.rotation, Int16(dto.rotation))
        XCTAssertEqual(point.scaleFactor, Float(dto.scaleFactor))
        XCTAssertEqual(point.number, Int16(dto.number))
        XCTAssertEqual(point.pointDescription, dto.pointDescription)
        XCTAssertEqual(point.task, dto.task)

        let expectedCameras = dto.cameras.map { $0.optic.rawValue }.joined(separator: ",")
        XCTAssertEqual(point.cameras, expectedCameras)

        let expectedSounds = dto.sounds.map { $0.placeType.rawValue }.joined(separator: ",")
        XCTAssertEqual(point.sounds, expectedSounds)

        let expectedLights = dto.lights.map { $0.lightType.rawValue }.joined(separator: ",")
        XCTAssertEqual(point.lights, expectedLights)
    }
    func test_createOrUpdateLocalTemplatePointWithTemplatePoint_updatesExistingObject() {
        let id = "tpId"
        
        // Create initial
        let initial = TemplatePointDTO.mock(id: id)
        _ = sut.createOrUpdateTemplatePointWithTemplatePointDTO(initial, inContext: .main)
        
        // Update DTO
        var updated = TemplatePointDTO.mock(id: id)
        updated.coordinateX = 999.0
        updated.number = 777
        updated.cameras = [CameraDTO(id: "updatedCam", optic: .x22)]

        let point = sut.createOrUpdateTemplatePointWithTemplatePointDTO(updated, inContext: .main)

        XCTAssertEqual(point.coordinateX, Float(999.0))
        XCTAssertEqual(point.number, Int16(777))
        XCTAssertEqual(point.cameras, "x22")
    }

    func test_createOrUpdateLocalTemplatePointWithTemplatePoint_handlesEmptyArrays() {
        let dto = TemplatePointDTO(
            id: UUID().uuidString,
            coordinateX: 0,
            coordinateY: 0,
            rotation: 0,
            scaleFactor: 1.0,
            cameras: [],
            sounds: [],
            lights: [],
            number: 0,
            pointDescription: "",
            task: ""
        )

        let point = sut.createOrUpdateTemplatePointWithTemplatePointDTO(dto, inContext: .main)

        XCTAssertEqual(point.cameras, "")
        XCTAssertEqual(point.sounds, "")
        XCTAssertEqual(point.lights, "")
    }

    func testAddCamerasToPoint() async {
            // Создадим мок PointDTO с камерами
            let pointDTO = VenuePointDTO.mock(id: "testPoint")
            
            // Обновим LocalLocationPoint
        let localPoint = sut.createOrUpdateLocalPointWithPointDTO(pointDTO, inContext: .main)
            
            // Проверяем, что у LocalLocationPoint есть камеры
            XCTAssertEqual(localPoint.viewCameras.count, 2, "Ожидается 2 камеры у LocalLocationPoint")
            
            // Проверим, что камера с правильными ID добавлена
            let cameraIds = localPoint.viewCameras.map { $0.id }
            XCTAssertTrue(cameraIds.contains("cam1-testPoint"), "Не найдена камера с ID 'cam1'")
            XCTAssertTrue(cameraIds.contains("cam2-testPoint"), "Не найдена камера с ID 'cam2'")
        }
        
        func testNoCamerasIfPointNotUpdated() async {
            // Создадим точку без камер
            let pointDTO = VenuePointDTO(id: "testPointWithoutCameras", memberId: [], coordinateX: 0, coordinateY: 0, rotation: 0, scale: 1, imageId: "", number: 0, description: "", task: "", cameras: [], sounds: [], lights: [])
            
            // Обновим LocalLocationPoint
            let localPoint = sut.createOrUpdateLocalPointWithPointDTO(pointDTO, inContext: .main)
            
            // Проверяем, что у точки нет камер
            XCTAssertEqual(localPoint.viewCameras.count, 0, "Не должно быть камер у LocalLocationPoint")
        }
    // MARK: - Helper
    func assertEntitiesExistence<T: NSManagedObject>(
        ofType type: T.Type,
        withIds ids: [String],
        in context: NSManagedObjectContext,
        shouldExist: Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for id in ids {
            let request = T.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)

            do {
                guard let result = try context.fetch(request) as? [T] else {
                    XCTFail("Fetch result could not be cast to [\(T.self)]", file: file, line: line)
                    continue
                }

                if shouldExist {
                    XCTAssertGreaterThan(result.count, 0, "\(T.self) with id \(id) was expected to exist but was not found", file: file, line: line)
                } else {
                    XCTAssertEqual(result.count, 0, "\(T.self) with id \(id) was expected to be absent but was found", file: file, line: line)
                }
            } catch {
                XCTFail("Failed to fetch \(T.self) with id \(id): \(error.localizedDescription)", file: file, line: line)
            }
        }
    }
}

// MARK: - Extensions
extension UIImage {
    static var testImage: UIImage {
        UIImage(systemName: "photo")!
    }
}

extension MemberDTO {
    static func mock(id: String = UUID().uuidString) -> MemberDTO{
        MemberDTO(id: id)
    }
}

extension BroadcastDTO{
    static func mock(id: String = UUID().uuidString, ownersIds:[String] = [], usersIds: [String] = [])->BroadcastDTO{
        var eventDTO = BroadcastDTO(id: id,
                                date: Date(),
                                lastUpdated: .now,
                                obvanId: "obvanId-\(id)",
                                venuePoints: [VenuePointDTO.mock(id: "1-\(id)"),VenuePointDTO.mock(id: "2-\(id)"),VenuePointDTO.mock(id: "3-\(id)")],
                                crews: [CrewDTO.mock(id: "1-\(id)"),CrewDTO.mock(id: "2"),CrewDTO.mock(id: "3-\(id)")],
                                venueID: "locationId-\(id)",
                                homeClubId: "homeClubId-\(id)",
                                guestClubId: "guestClubId-\(id)",
                                venuePreviewId: "locPrevId-\(id)",
                                obvanPreviewId: "obvanPrevId-\(id)")
        eventDTO.ownersIds = ownersIds
        eventDTO.membersIds = usersIds
        return eventDTO
    }
}

extension VenueDTO{
    static func mock(id: String)->VenueDTO{
        VenueDTO(id: id,
                    lastUpdated: .now,
                    title: "title-\(id)",
                    address: "address-\(id)",
                    imagesIds: ["img1-\(id)","img2-\(id)"],
                    venueSchemaId: "bg-\(id)")
    }
}

extension ClubDTO{
    static func mock(id: String) -> ClubDTO{
        ClubDTO(id: id,
                title: "Title-\(id)",
                contacts: "contacts-\(id)",
                urlString: "URL address-\(id)",
                imageLogoID: "logoId-\(id)",
                homeLocationID: "locationId-\(id)",
                lastUpdated: .now)
    }
}

extension ObvanDTO{
    static func mock(id: String) -> ObvanDTO{
        ObvanDTO(id: id,
                 lastUpdated: .now,
                 name: "obvanName-\(id)",
                 imageId: "obvanImgId-\(id)",
                 broadcaster: "broadcasterName-\(id)")
    }
}


extension ImageDTO{
    static func mock(id: String) -> ImageDTO{
        ImageDTO(id: id,
                 type: GlobalProperties.ImageType.venue.rawValue, lastUpdated: .now)
    }
}

extension VenuePointDTO{
    static func mock(id: String) -> VenuePointDTO{
        VenuePointDTO(id: id,
                 memberId: [],
                 coordinateX: 100,
                 coordinateY: 100,
                 rotation: 45,
                 scale: 1,
                 imageId: "imageId-\(id)",
                 number: 7,
                 description: "description-\(id)",
                 task: "work hard-\(id)",
                 cameras: [CameraDTO.mock(id: "cam1-\(id)"),CameraDTO.mock(id: "cam2-\(id)")],
                 sounds: [SoundDTO.mock(id: "sound1-\(id)"),SoundDTO.mock(id: "sound2-\(id)")],
                 lights: [LightDTO.mock(id: "light1-\(id)")])
    }
}

extension CrewDTO{
    static func mock(id: String) -> CrewDTO{
        CrewDTO(id: id,
                position: UserSpecialization.replayOperator,
                coordinateX: 100,
                coordinateY: 100,
                rotation: 45,
                scale: 2,
                task: "work hard-\(id)",
                userId: "userId-\(id)",
                hardware: HardwareDTO.mock(id: "hardwareId-\(id)"))
    }
}

extension TemplateDTO {
    static func mock(id: String = UUID().uuidString) -> TemplateDTO {
        TemplateDTO(
            id: id,
            lastUpdated: .now,
            name: "MockTemplate-\(id)",
            templatePoints: [TemplatePointDTO.mock(id: "tpId-\(id)")]
        )
    }
}

extension TemplatePointDTO{
    static func mock(id:String) ->TemplatePointDTO{
        TemplatePointDTO(
            id: id,
            coordinateX: 10.0,
            coordinateY: 20.0,
            rotation: 90,
            scaleFactor: 1.0,
            cameras: [CameraDTO.mock(id: "cam1-\(id)"),CameraDTO.mock(id: "cam2-\(id)")],
            sounds: [SoundDTO.mock(id: "sound1-\(id)"),SoundDTO.mock(id: "sound2-\(id)")],
            lights: [LightDTO.mock(id: "light1-\(id)")],
            number: 1,
            pointDescription: "Mock Description-\(id)",
            task: "Mock Task-\(id)")
    }
}

extension CameraDTO {
    static func mock(id: String) -> CameraDTO{
        CameraDTO(id: id, optic: OpticType.x22)
    }
}

extension SoundDTO{
    static func mock(id: String) ->SoundDTO{
        SoundDTO(id: id,
                 windDefence: WindDefence.dog,
                 placeType: PlaceType.low)
    }
}

extension LightDTO{
    static func mock(id: String) -> LightDTO{
        LightDTO(id: id,
                 lightType: LightType.light)
    }
}

extension HardwareDTO{
    static func mock(id: String) -> HardwareDTO{
        HardwareDTO(id: id,
                    envType: HardwareType.evs,
                    chanels: ["one","two","three"])
    }
    
}
