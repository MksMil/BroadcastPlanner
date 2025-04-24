import CoreData
import XCTest

@testable import BroadcastPlanner

final class DataManagerTests: XCTestCase {
    
    var sut: DataManager!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
// MARK: - SetUp / TearDown
    override func setUp() {
        super.setUp()
        sut = DataManager(forPreview: true)
        container = sut.persistentContainer
        context = sut.moc
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
        let existing = LocalLocationPoint(context: context)
        existing.id = id
        try? context.save()

        let predicate = NSPredicate(format: "id == %@", id)
        let result = sut.fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: predicate,
            in: context,
            initializer: { ctx in
                XCTFail("Initializer should not be called")
                return LocalLocationPoint(context: ctx)
            }
        )
        XCTAssertEqual(result.id, id)
    }
    func test_fetchOrCreateObject_createsNewObject_whenNotFound() {
        let id = UUID().uuidString
        let initId = UUID().uuidString
        let predicate = NSPredicate(format: "id == %@", id)

        let result = sut.fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: predicate,
            in: context,
            initializer: { ctx in
                let new = LocalLocationPoint(context: ctx)
                new.id = initId
                return new
            }
        )

        XCTAssertEqual(result.id, initId)

        // Is object in context?
        let fetchRequest: NSFetchRequest<LocalLocationPoint> = LocalLocationPoint.fetchRequest()
        let all = try? context.fetch(fetchRequest)
        XCTAssertTrue(all?.contains(where: { $0.id == initId }) ?? false)
    }
    // MARK: - User
    func test_createOrUpdateLocalUserWithUserDTO_createsUser_andUpdatesUser(){
        let id = UUID().uuidString
        let userDTO = UserDTO.mock(id: id)
        let resultUser = sut.createOrUpdateLocalUserWithUserDTO(userDTO,
                                            inContext: .main)
        XCTAssertEqual(id, resultUser.userId)
    }
    func test_createOrUpdateLocalUserWithUserDTO_fetchesUser_andUpdatesUser(){
        let id = UUID().uuidString
        var userDTO = UserDTO.mock(id: id)
        userDTO.firstName = "firstName"
        userDTO.lastName = "lastName"
        userDTO.isOnline = true
        userDTO.phoneNumber = "123"
        userDTO.email = "email@email"
        userDTO.homeAddress = "address"
        userDTO.specialization = ["1", "2", "3"]
        
        let request: NSFetchRequest<LocalUser> =
            LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        var results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 0) // no user founded
        let localUser = LocalUser(context: context)
        localUser.id = id
        results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1) // user founded
        
        let resultUser = sut.createOrUpdateLocalUserWithUserDTO(userDTO,
                                            inContext: .main)//found existing user with DTO.id
        XCTAssertEqual(id, resultUser.userId)
        XCTAssertEqual(userDTO.firstName, resultUser.userFirstName)
        XCTAssertEqual(userDTO.lastName, resultUser.userLastName)
        XCTAssertEqual(userDTO.isOnline, resultUser.isOnline)
        XCTAssertEqual(userDTO.phoneNumber, resultUser.userPhoneNumber)
        XCTAssertEqual(userDTO.email, resultUser.userEmail)
        XCTAssertEqual(userDTO.homeAddress, resultUser.userAddress)
        XCTAssertEqual(userDTO.creationDateConverted, resultUser.userCreationDate)
        XCTAssertEqual(userDTO.leaveDateConverted, resultUser.userLeaveDate)
        XCTAssertEqual(resultUser.image?.id ?? "", userDTO.id)
    }
    func test_updateLocalUser_updatesLocalUser(){
        let id = UUID().uuidString
        var userDTO = UserDTO.mock(id: id)
        userDTO.firstName = "firstName"
        userDTO.lastName = "lastName"
        userDTO.isOnline = true
        userDTO.phoneNumber = "123"
        userDTO.email = "email@email"
        userDTO.homeAddress = "address"
        userDTO.specialization = ["1", "2", "3"]
        let localUser = LocalUser(context: context)
        sut.updateLocalUser(localUser,
                            withUserDTO: userDTO,
                            inContext: .main)
        XCTAssertEqual(userDTO.id, localUser.userId)
        XCTAssertEqual(userDTO.firstName, localUser.userFirstName)
        XCTAssertEqual(userDTO.lastName, localUser.userLastName)
        XCTAssertEqual(userDTO.isOnline, localUser.isOnline)
        XCTAssertEqual(userDTO.phoneNumber, localUser.userPhoneNumber)
        XCTAssertEqual(userDTO.email, localUser.userEmail)
        XCTAssertEqual(userDTO.homeAddress, localUser.userAddress)
        XCTAssertEqual(userDTO.creationDateConverted, localUser.userCreationDate)
        XCTAssertEqual(userDTO.leaveDateConverted, localUser.userLeaveDate)
        XCTAssertEqual(localUser.image?.id ?? "", userDTO.id)
        
    }
    func test_removeUserUsingDTO_removesLocalUser(){
        let id = UUID().uuidString
        let userDTO = UserDTO.mock(id: id)
        
        let _ = sut.createOrUpdateLocalUserWithUserDTO(userDTO,inContext: .main)
        let request: NSFetchRequest<LocalUser> = LocalUser.fetchRequest()
        let results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1)
        
        sut.removeUserWithDTO(userDTO, inContext: .main)
        let newResults = try? container.viewContext.fetch(request)
        XCTAssertEqual(newResults?.count, 0)
    }
    func test_removeLocalUser_removesLocalUser(){
        let localUser = LocalUser(context: context)
        let request: NSFetchRequest<LocalUser> = LocalUser.fetchRequest()
        var results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1)
        sut.removeLocalUser(localUser, inContext: .main)
        results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 0)
    }
    func test_fetchUsersAvailableToEvent_fetchesUsersAvailableToEvent(){
        let localEvent = LocalEvent(context: context)
        let user1DTO = UserDTO.mock(id:  UUID().uuidString)
        let user2DTO = UserDTO.mock(id:  UUID().uuidString)
        let user3DTO = UserDTO.mock(id:  UUID().uuidString)
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
        let eventDto = EventDTO.mock(id:id)
        let request = LocalEvent.fetchRequest()
        var results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        let _ = await sut.createOrUpdateLocalEventWithEventDTO(eventDto, inContext: .main)
        results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.viewId, id)
    }
    func test_createOrUpdateLocalEventWithEventDTO_fetchesEvent_andUpdatesEvent()async{
        let id = UUID().uuidString
        let eventDto = EventDTO.mock(id:id)
        let localEvent = LocalEvent(context: context)
        localEvent.id = id
        
        let request = LocalEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.viewId, id)
        XCTAssertEqual(results?.first?.date, nil)
        
        let _ = await sut.createOrUpdateLocalEventWithEventDTO(eventDto, inContext: .main)
        
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        XCTAssertEqual(newResults?.first?.viewId, id)
        XCTAssertEqual(results?.first?.date ?? Date(), eventDto.date)
    }
    func test_updateLocalEvent_updatesLocalEventWithDTO()async{
        let id = UUID().uuidString
        let eventDto = EventDTO.mock(id:id,
                                     ownersIds: ["1","2"],
                                     usersIds: ["3","4"])
        let localEvent = LocalEvent(context: context)
        await sut.updateLocalEvent(localEvent, withDTO: eventDto, inContext: .main)
        XCTAssertEqual(localEvent.viewId, eventDto.id)
        XCTAssertEqual(localEvent.date ?? Date.now, eventDto.date)
        XCTAssertEqual(localEvent.obvan?.viewId, eventDto.obVanId)
        XCTAssertEqual(localEvent.location?.id, eventDto.locationID)
        XCTAssertEqual(localEvent.homeClub?.id, eventDto.homeClubId)
        XCTAssertEqual(localEvent.guestClub?.id, eventDto.guestClubId)
        XCTAssertEqual(localEvent.owners?.count, eventDto.ownersIds.count)
        XCTAssertEqual(localEvent.users?.count, eventDto.usersIds.count)
        XCTAssertEqual(localEvent.points?.count, eventDto.locationPoints.count)
        XCTAssertEqual(localEvent.units?.count, eventDto.obVanUnits.count)
        XCTAssertEqual(localEvent.locationPreview?.id, eventDto.locationPreviewId)
        XCTAssertEqual(localEvent.obvanPreview?.id, eventDto.obvanPreviewId)
    }
    @MainActor
    func test_removeEvent_removesLocalEventUsingDTO() async{
        let id = UUID().uuidString
        let eventDto = EventDTO.mock(id:id)
        
        let request = LocalEvent.fetchRequest()
        var results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)

        let _ = await sut.createOrUpdateLocalEventWithEventDTO(eventDto, inContext: .main)
        results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 1)
        //check if LocalImages for previews, points and units are created and existed
        assertEntitiesExistence(ofType: LocalImage.self, withIds: ["locPrevId-\(id)","obvanPrevId-\(id)"], in: context, shouldExist: true)
        var resultPoints = try? context.fetch(LocalLocationPoint.fetchRequest())
        var resultUnits = try? context.fetch(LocalUnit.fetchRequest())
        XCTAssertEqual(resultPoints?.count, 3)
        XCTAssertEqual(resultUnits?.count, 3)
        
        await sut.removeEventWithDTO(eventDto, inContext: .main)
        results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        //check if LocalImages for previews, points and units are removed
        assertEntitiesExistence(ofType: LocalImage.self, withIds: ["locPrevId-\(id)","obvanPrevId-\(id)"], in: context, shouldExist: false)
        resultPoints = try? context.fetch(LocalLocationPoint.fetchRequest())
        resultUnits = try? context.fetch(LocalUnit.fetchRequest())
        XCTAssertEqual(resultPoints?.count, 0)
        XCTAssertEqual(resultUnits?.count, 0)
    }
    @MainActor
    func test_removeLocalEvent_removesLocalEvent() async {
        let id = UUID().uuidString
        let request = LocalEvent.fetchRequest()
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        let localEvent = sut.fetchOrCreateObject(ofType: LocalEvent.self,
                                                 predicate: NSPredicate(format: "id == %@", id),
                                                 in: context) { ctx in
            let newEvent = LocalEvent(context: ctx)
            newEvent.id = id
            return newEvent
        }
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        await sut.removeLocalEvent(localEvent, inContext: .main)
        let removeResults = try? context.fetch(request)
        XCTAssertEqual(removeResults?.count, 0)
    }
    // MARK: - Images
    func test_fetchImagesByType_fetchesImagesByType() async {
        let image = UIImage(systemName: "photo")!
        let id = UUID().uuidString
        let type: GlobalProperties.ImageType = .location

        _ = sut.createOrUpdateLocalImageWithId(
            id,
            withImage: image,
            andType: type,
            inContext: .main
        )

        let images = await sut.fetchImagesByType(type, inContext: .main)
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
    func test_createOrUpdateLocalImageWithImageDTO_createsLocalImage() async {
        let image = UIImage(systemName: "photo")!
        let id = UUID().uuidString
        let type: GlobalProperties.ImageType = .eventTemplate
        let dto = ImageDTO(id: id, type: type.rawValue)
        let localImage = await sut.createOrUpdateLocalImageWithImageData(
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

        let images = await sut.fetchImagesByType(type, inContext: .main)
        XCTAssertFalse(images.contains { $0.id == id })

        let filesExist = ImageSizes.allCases.contains {
            ImagesManager.loadImage(imageSize: $0, id: id) != nil
        }
        XCTAssertFalse(filesExist)
    }

    // MARK: - Location
    func test_createOrUpdateLocalLocationWithLocation_createsNewLocationAndAssignsData() async {
        // Given
        let id = UUID().uuidString
        let imageId1 = UUID().uuidString
        let imageId2 = UUID().uuidString
        let backgroundId = UUID().uuidString
        
        let dto = LocationDTO(
            id: id,
            title: "Test Title",
            address: "Test Address",
            imagesIds: [imageId1, imageId2],
            locationBackgroundId: backgroundId
        )
        
        // When
        var localLocation = await sut.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .main)
        
        // Then
        XCTAssertEqual(localLocation.id, id)
        XCTAssertEqual(localLocation.title, dto.title)
        XCTAssertEqual(localLocation.address, dto.address)
        XCTAssertEqual(localLocation.viewLocalImages.count, 2)
        XCTAssertEqual(localLocation.background?.id, backgroundId)
        
        let newDto = LocationDTO(
            id: id,
            title: "Test New Title",
            address: "Test New Address",
            imagesIds: [imageId1],
            locationBackgroundId: nil
        )
        localLocation = await sut.createOrUpdateLocalLocationWithLocationDTO(newDto, inContext: .main)
        
        XCTAssertEqual(localLocation.id, id)
        XCTAssertEqual(localLocation.title, newDto.title)
        XCTAssertEqual(localLocation.address, newDto.address)
        XCTAssertEqual(localLocation.viewLocalImages.count, 1)
        XCTAssertEqual(localLocation.background?.id, nil)
    }
    
    func test_cleanImagesInLocalLocation_shouldRemoveAllImagesAndBackground() async {
        let image1 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .location,
            inContext: .main
        )

        let image2 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .location,
            inContext: .main
        )

        let backgroundImage = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .location,
            inContext: .main
        )
        let location = LocalLocation(context: sut.moc)
        location.id = UUID().uuidString
        location.title = "Test Location"
        location.addToImages(image1)
        location.addToImages(image2)
        location.background = backgroundImage

        XCTAssertEqual(location.viewLocalImages.count, 2)
        XCTAssertNotNil(location.background)

        let exist1 = ImagesManager.imageExists(withId: image1.viewId)
        let exist2 = ImagesManager.imageExists(withId: image2.viewId)
        let existBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertTrue(exist1, "image1 should be saved in device")
        XCTAssertTrue(exist2, "image2 should be saved in device")
        
        XCTAssertTrue(existBG, "backgroundImage should be saved from device")

        
        await sut.cleanImagesInLocalLocation(location,andBackground: true, inContext: .main)

        XCTAssertEqual(location.viewLocalImages.count, 0)
        XCTAssertNil(location.background)

        let allImages = await sut.fetchImagesByType(.location, inContext: .main)
        XCTAssertEqual(allImages.count, 1) //bg exists
        let removed1 = ImagesManager.imageExists(withId: image1.viewId)
        let removed2 = ImagesManager.imageExists(withId: image2.viewId)
        let removedBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertFalse(removed1, "image1 should be removed from device")
        XCTAssertFalse(removed2, "image2 should be removed from device")
        XCTAssertTrue(removedBG, "backgroundImage should not be removed from device")
    }
    
    func test_updateLocalLocationWithData_updatesLocalLocation() async {
        let images = [UIImage.testImage]
        let title = "title"
        let address = "address"
        let background = sut.createOrUpdateLocalImageWithId("bgId", withImage: UIImage.testImage, andType: .location, inContext: .main)
        let dto = LocationDTO.mock(id: "location")
        let location = await sut.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .main)
        
        await sut.updateLocalLocation(location, withTitle: title, address: address, localImages: images, locationBackground: background)
        
        XCTAssertEqual(location.viewLocalImages.count, 1)
        XCTAssertEqual(location.title, title)
        XCTAssertEqual(location.address, address)
        XCTAssertNotNil(location.background)
        //twice
        let newTitle = "newTitle"
        let newAddress = "newAddress"
        let newImages = [UIImage.testImage,UIImage.testImage,UIImage.testImage]
        await sut.updateLocalLocation(location, withTitle: newTitle, address: newAddress, localImages: newImages, locationBackground: nil)
        XCTAssertEqual(location.viewLocalImages.count, 3)
        XCTAssertEqual(location.title, newTitle)
        XCTAssertEqual(location.address, newAddress)
        XCTAssertNil(location.background)
    }
    func test_removeLocalLocation_removesImagesAndLocation()async{
        let image1 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .location,
            inContext: .main
        )

        let image2 = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .location,
            inContext: .main
        )

        let backgroundImage = sut.createOrUpdateLocalImageWithId(
            UUID().uuidString,
            withImage: .testImage,
            andType: .location,
            inContext: .main
        )
        let location = LocalLocation(context: sut.moc)
        location.id = UUID().uuidString
        location.title = "Test Location"
        location.addToImages(image1)
        location.addToImages(image2)
        location.background = backgroundImage

        XCTAssertEqual(location.viewLocalImages.count, 2)
        XCTAssertNotNil(location.background)

        let exist1 = ImagesManager.imageExists(withId: image1.viewId)
        let exist2 = ImagesManager.imageExists(withId: image2.viewId)
        let existBG = ImagesManager.imageExists(withId: backgroundImage.viewId)

        XCTAssertTrue(exist1, "image1 should be saved in device")
        XCTAssertTrue(exist2, "image2 should be saved in device")
        
        XCTAssertTrue(existBG, "backgroundImage should be saved from device")

        
        await sut.removeLocalLocation(location, inContext: .main)
        await sut.saveContext(type: .main, publish: .locations, id: [])
        let request = LocalLocation.fetchRequest()
        let result = try? context.fetch(request)
        
        XCTAssertEqual(result?.count, 0)
        XCTAssertEqual(location.viewLocalImages.count, 0)
        XCTAssertNil(location.background)

        let allImages = await sut.fetchImagesByType(.location, inContext: .main)
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
        
        let obvan = await sut.createOrUpdateLocalObvanWithDTO(dto, inContext: .main)
        //except that obvan created
        let request = LocalObvan.fetchRequest()
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
    
    func test_updateLocalObvanWithDTO_updatesObvan()async{
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        let obvan = LocalObvan(context: context)
        await sut.updateLocalObvan(obvan,
                             withObvan: dto,
                             inContext: .main)
        //except that obvan created and updated
        let request = LocalObvan.fetchRequest()
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
    
    func test_removeObvan_removesObvan() async{
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        let obvan = await sut.createOrUpdateLocalObvanWithDTO(dto, inContext: .main)
        //except that obvan created
        let request = LocalObvan.fetchRequest()
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
        
        await sut.removeObvan(obvan, inContext: .main)
        await sut.saveContext(type: .main, publish: .obvans, id: [])
        
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 0)
        } else {
            XCTFail("Obvan Entity must be created")
        }
        
        if let result = try? context.fetch(imageRequest){
            XCTAssertEqual(result.count, 0)
        }
    }
    
    func test_removeObvanWithId_removesObvan()async{
        let id = "obvanId"
        let dto = ObvanDTO.mock(id: id)
        
        let _ = await sut.createOrUpdateLocalObvanWithDTO(dto, inContext: .main)
        //except that obvan created
        let request = LocalObvan.fetchRequest()
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, id)
            XCTAssertEqual(result.first?.name, "obvanName-\(id)")
            XCTAssertEqual(result.first?.broadcaster, "broadcasterName-\(id)")
        } else {
            XCTFail("Obvan Entity must be created")
        }
        
        await sut.removeObvanWithId(id, inContext: .main)
        await sut.saveContext(type: .main, publish: .obvans, id: [])
        if let result = try? context.fetch(request){
            XCTAssertEqual(result.count, 0)
        } else {
            XCTFail("Obvan Entity must be created")
        }
    }
    
    
    // MARK: - LocationPoints
    func test_createOrUpdateLocalPointWithPointDTO_createsAndUpdatesPoint()async{
        let id = "pointDtoId"
        let pointDto = PointDTO.mock(id: id)
        
        let request = LocalLocationPoint.fetchRequest()
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
        XCTAssertEqual(result?.first?.scaleFactor, Float(pointDto.scale))
        XCTAssertEqual(result?.first?.image?.id, pointDto.imageId)
        XCTAssertEqual(result?.first?.user?.count, pointDto.userId.count)
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
        XCTAssertEqual(result?.first?.scaleFactor, Float(pointDto.scale))
        XCTAssertEqual(result?.first?.image?.id, pointDto.imageId)
        XCTAssertEqual(result?.first?.user?.count, pointDto.userId.count)
        XCTAssertEqual(result?.first?.cameras?.count, pointDto.cameras.count)
        XCTAssertEqual(result?.first?.sounds?.count, pointDto.sounds.count)
        XCTAssertEqual(result?.first?.lights?.count, pointDto.lights.count)
  }
    func test_updateLocalPoint_withSimpleData_updatesLocalPoint(){
        let x = 20.0
        let y = 30.0
        let rot = 90
        let scale = 2.0
        
        let point = LocalLocationPoint(context: context)
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
        let pointDto = PointDTO.mock(id: id)
        
       let point = LocalLocationPoint(context: context)
        
         sut.updateLocalPoint(point,
                             withPointDTO: pointDto,
                             inContext: .main)
        
//        XCTAssertEqual(point.id, id)
        XCTAssertEqual(point.coordinateX, Float(pointDto.coordinateX))
        XCTAssertEqual(point.coordinateY, Float(pointDto.coordinateY))
        XCTAssertEqual(point.rotation, Int16(pointDto.rotation))
        XCTAssertEqual(point.scaleFactor, Float(pointDto.scale))
        XCTAssertEqual(point.image?.id, pointDto.imageId)
        XCTAssertEqual(point.user?.count, pointDto.userId.count)
        XCTAssertEqual(point.cameras?.count, pointDto.cameras.count)
        XCTAssertEqual(point.sounds?.count, pointDto.sounds.count)
        XCTAssertEqual(point.lights?.count, pointDto.lights.count)
    }
    func test_updateLocalPoint_withTemplatePoint_updatesPoint(){
        let templatePoint = sut.createOrUpdateLocalTemplatePointWithTemplatePoint(TemplatePointDTO.mock(id: "id"), inContext: .main)
        
        let localPoint = LocalLocationPoint(context: context)
        
        sut.updateLocalPoint(localPoint,
                             withTemplatePoint: templatePoint,
                             inContext: .main)
        
        XCTAssertEqual(localPoint.coordinateX, templatePoint.coordinateX)
        XCTAssertEqual(localPoint.coordinateY, templatePoint.coordinateY)
        XCTAssertEqual(localPoint.rotation, templatePoint.rotation)
        XCTAssertEqual(localPoint.scaleFactor, templatePoint.scaleFactor)
        XCTAssertEqual(localPoint.number, templatePoint.number)
        XCTAssertEqual(localPoint.cameras?.count, templatePoint.viewCameras.count)
        XCTAssertEqual(localPoint.sounds?.count, templatePoint.viewSounds.count)
        XCTAssertEqual(localPoint.lights?.count, templatePoint.viewLights.count)
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
        XCTAssertEqual(localPoint.cameras?.count, templatePoint.viewCameras.count)
        XCTAssertEqual(localPoint.sounds?.count, templatePoint.viewSounds.count)
        XCTAssertEqual(localPoint.lights?.count, templatePoint.viewLights.count)
        XCTAssertEqual(localPoint.task, templatePoint.task)
        XCTAssertEqual(localPoint.pointDescription, templatePoint.pointDescription)

    }
    func test_removeLocationPoint_withDTO_removesPoint() async {
        let dto = PointDTO.mock(id: "id")
        let locationPoint = sut.createOrUpdateLocalPointWithPointDTO(dto, inContext: .main)
        let camIds = locationPoint.viewLocalCameras.map{$0.viewId}
        let soundIds = locationPoint.viewLocalSounds.map{$0.viewId}
        let lightIds = locationPoint.viewLocalLights.map{$0.viewId}
        let imageId = locationPoint.viewImageId

        assertEntitiesExistence(ofType: LocalCamera.self, withIds: camIds, in: context, shouldExist: true)
        assertEntitiesExistence(ofType: LocalSound.self, withIds: soundIds, in: context, shouldExist: true)
        assertEntitiesExistence(ofType: LocalLight.self, withIds: lightIds, in: context, shouldExist: true)
        assertEntitiesExistence(ofType: LocalImage.self, withIds: [imageId], in: context, shouldExist: true)

        sut.removeLocationPoint(dto, inContext: .main)
        try? context.save()
        
        let request = LocalLocationPoint.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dto.id)
        let result = try? context.fetch(request)
        XCTAssertEqual(result?.count, 0)
        
        assertEntitiesExistence(ofType: LocalCamera.self, withIds: camIds, in: context, shouldExist: false)
        assertEntitiesExistence(ofType: LocalSound.self, withIds: soundIds, in: context, shouldExist: false)
        assertEntitiesExistence(ofType: LocalLight.self, withIds: lightIds, in: context, shouldExist: false)
        assertEntitiesExistence(ofType: LocalImage.self, withIds: [imageId], in: context, shouldExist: false)
    }
    // MARK: - Units
    func test_createOrUpdateLocalObvanUnitWithObvanUnit_createsAndUpdatesUnit(){
        let id = "unitId"
        let dto = UnitDTO.mock(id: id)
        
        let request = LocalUnit.fetchRequest()
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
        XCTAssertEqual(result?.first?.scaleFactor, Float(dto.scale))
        XCTAssertEqual(result?.first?.task, dto.task)
        XCTAssertEqual(result?.first?.user?.id, dto.userId)
        XCTAssertEqual(result?.first?.hardware?.id, dto.hardware?.id)
        
    }
    
    func test_createUnitWithUser_createsUnitWithUser(){
        let userId = "userId"
        let userDto = UserDTO.mock(id: userId)
        let localUser = sut.createOrUpdateLocalUserWithUserDTO(userDto, inContext: .main)
        let localHardwareType = ReplayType.evs
        let position = UserSpecialization.director
        
        let localUnit = sut.createUnitWithUser(localUser,
                                   andPosition: position,
                                   andHardware: localHardwareType,
                                   inContext: .main)
        let result = try? context.fetch(LocalUnit.fetchRequest())
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(localUnit.user, localUser)
        XCTAssertEqual(localUnit.hardware?.type, localHardwareType.rawValue)
        XCTAssertEqual(localUnit.position, position.rawValue)
    }
    
    @MainActor
    func test_removeLocalUnit_removesLocalUnitAndHardware() async{
        let id  = "unitId"
        let hardwareId = "hardwareId-\(id)"
        let dto = UnitDTO.mock(id: id)
        let _ = sut.createOrUpdateLocalUnitWithUnitDTO(dto, inContext: .main)
        
        assertEntitiesExistence(ofType: LocalUnit.self,
                                withIds: [id],
                                in: context,
                                shouldExist: true)
        
        assertEntitiesExistence(ofType: LocalHardware.self,
                                withIds: [hardwareId],
                                in: context,
                                shouldExist: true)
        
        sut.removeLocalUnitUsingUnitDTO(dto, inContext: .main)
        await sut.saveContext(type: .main, publish: .none, id: [])
        
        assertEntitiesExistence(ofType: LocalUnit.self,
                                withIds: [id],
                                in: context,
                                shouldExist: false)
        
        assertEntitiesExistence(ofType: LocalHardware.self,
                                withIds: [hardwareId],
                                in: context,
                                shouldExist: false)
        
    }
    
    // MARK: - Templates
    func test_fetchOrCreateLocalTemplateWithId_CreatesNewTemplate() {
        let id = UUID().uuidString
        let template = sut.fetchOrCreateObject(
            ofType: LocalTemplate.self,
            predicate: NSPredicate(format: "id == %@", id),
            in: container.viewContext
        ) { ctx in
            let newTemplate = LocalTemplate(context: ctx)
            newTemplate.id = id
            return newTemplate
        }
        XCTAssertEqual(template.id, id)

        let request: NSFetchRequest<LocalTemplate> =
            LocalTemplate.fetchRequest()
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

        let request: NSFetchRequest<LocalTemplate> =
            LocalTemplate.fetchRequest()
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
            name: "UpdatedName",
            templatePoints: dto.templatePoints
        )
        _ = sut.createOrUpdateLocalTemplateWithTemplateDTO(
            updatedDTO,
            inConext: .main
        )

        let request: NSFetchRequest<LocalTemplate> =
            LocalTemplate.fetchRequest()
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
        let fetchRequest: NSFetchRequest<LocalTemplate> =
            LocalTemplate.fetchRequest()
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

        let fetchRequest: NSFetchRequest<LocalTemplatePoint> =
            LocalTemplatePoint.fetchRequest()
        let points = try? container.viewContext.fetch(fetchRequest)
        guard let templatePoint = points?.first else {
            XCTFail("No template point created")
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
        XCTAssertEqual(template.templatePoints?.count, dto.templatePoints.count)
        (0..<dto.templatePoints.count).forEach { index in
            XCTAssertEqual(template.viewPoints[index].viewCameras.count, dto.templatePoints[index].cameras.count)
            XCTAssertEqual(template.viewPoints[index].viewSounds.count, dto.templatePoints[index].sounds.count)
            XCTAssertEqual(template.viewPoints[index].viewLights.count, dto.templatePoints[index].lights.count)
        }
        
        var result =  sut.mapTemplateToLocationPoints(template: template, inContext: .main)
        
        XCTAssertLessThanOrEqual(template.viewPoints.count,result.count)
        
        (0..<result.count).forEach { index in
            
            XCTAssertEqual(template.viewPoints[index].pointDescription, result[index].pointDescription)
            XCTAssertEqual(template.viewPoints[index].coordinateX, result[index].coordinateX)
            XCTAssertEqual(template.viewPoints[index].coordinateY, result[index].coordinateY)
            XCTAssertEqual(template.viewPoints[index].rotation, result[index].rotation)
            XCTAssertEqual(template.viewPoints[index].scaleFactor, result[index].scaleFactor)
            XCTAssertEqual(template.viewPoints[index].task, result[index].task)
            XCTAssertEqual(template.viewPoints[index].number, result[index].number)
            XCTAssertEqual(template.viewPoints[index].viewCameras.count, result[index].cameras?.count)
            XCTAssertEqual(template.viewPoints[index].viewSounds.count, result[index].sounds?.count)
            XCTAssertEqual(template.viewPoints[index].viewLights.count, result[index].lights?.count)
        }
        
        //twice
        template = sut.createOrUpdateLocalTemplateWithTemplateDTO(dto, inConext: .main)

        result =  sut.mapTemplateToLocationPoints(template: template, inContext: .main)
        
        XCTAssertLessThanOrEqual(template.viewPoints.count,result.count)
        
        (0..<result.count).forEach { index in
            
            XCTAssertEqual(template.viewPoints[index].pointDescription, result[index].pointDescription)
            XCTAssertEqual(template.viewPoints[index].coordinateX, result[index].coordinateX)
            XCTAssertEqual(template.viewPoints[index].coordinateY, result[index].coordinateY)
            XCTAssertEqual(template.viewPoints[index].rotation, result[index].rotation)
            XCTAssertEqual(template.viewPoints[index].scaleFactor, result[index].scaleFactor)
            XCTAssertEqual(template.viewPoints[index].task, result[index].task)
            XCTAssertEqual(template.viewPoints[index].number, result[index].number)
            XCTAssertEqual(template.viewPoints[index].viewCameras.count, result[index].cameras?.count)
            XCTAssertEqual(template.viewPoints[index].viewSounds.count, result[index].sounds?.count)
            XCTAssertEqual(template.viewPoints[index].viewLights.count, result[index].lights?.count)
        }
    }
    
    func test_localPointCreatedWithCameras() async {
        let dto = PointDTO.mock(id: "123")
        let point = sut.createOrUpdateLocalPointWithPointDTO(dto, inContext: .main)

        XCTAssertEqual(point.cameras?.count, 2, "Expected 2 cameras")
        XCTAssertEqual(point.viewLocalSounds.count, 2, "Expected 2 sounds")
        XCTAssertEqual(point.viewLocalLights.count, 1, "Expected 1 light")
    }

    func test_createTemplateWithLocalLocationPoints_createsLocalTemplate()async{
        let dtos = [PointDTO.mock(id: "1"),
                    PointDTO.mock(id: "2"),
                    PointDTO.mock(id: "3"),
                    PointDTO.mock(id: "4"),
                    PointDTO.mock(id: "5")]
        
        let points = dtos.map{sut.createOrUpdateLocalPointWithPointDTO($0, inContext: .main)}

        let name = "name"
        var template = await sut.createTemplateWithLocalLocationPoints(points,
                                                  andName: name, inContext: .main)
        XCTAssertEqual(template.id, name)
        XCTAssertEqual(template.name, name)
        XCTAssertEqual(template.templatePoints?.count, points.count)

        
        for point in points {
            guard let viewPoint = template.viewPoints.first(where: { $0.pointDescription == point.pointDescription }) else {
                XCTFail("Missing view point with id \(point.id ?? "nil")")
                continue
            }

            XCTAssertEqual(viewPoint.pointDescription, point.pointDescription)
            XCTAssertEqual(viewPoint.coordinateX, point.coordinateX)
            XCTAssertEqual(viewPoint.coordinateY, point.coordinateY)
            XCTAssertEqual(viewPoint.rotation, point.rotation)
            XCTAssertEqual(viewPoint.scaleFactor, point.scaleFactor)
            XCTAssertEqual(viewPoint.task, point.task)
            XCTAssertEqual(viewPoint.number, point.number)

            XCTAssertEqual(viewPoint.viewCameras.count, point.cameras?.count ?? 0)
            XCTAssertEqual(viewPoint.viewSounds.count, point.viewLocalSounds.count)
            XCTAssertEqual(viewPoint.viewLights.count, point.viewLocalLights.count)
        }
        
        //twice
        template = await sut.createTemplateWithLocalLocationPoints(points,
                                                  andName: name, inContext: .main)
        XCTAssertEqual(template.id, name)
        XCTAssertEqual(template.name, name)
        XCTAssertEqual(template.templatePoints?.count, points.count)

        
        for point in points {
            guard let viewPoint = template.viewPoints.first(where: { $0.pointDescription == point.pointDescription }) else {
                XCTFail("Missing view point with id \(point.id ?? "nil")")
                continue
            }

            XCTAssertEqual(viewPoint.pointDescription, point.pointDescription)
            XCTAssertEqual(viewPoint.coordinateX, point.coordinateX)
            XCTAssertEqual(viewPoint.coordinateY, point.coordinateY)
            XCTAssertEqual(viewPoint.rotation, point.rotation)
            XCTAssertEqual(viewPoint.scaleFactor, point.scaleFactor)
            XCTAssertEqual(viewPoint.task, point.task)
            XCTAssertEqual(viewPoint.number, point.number)

            XCTAssertEqual(viewPoint.viewCameras.count, point.cameras?.count ?? 0)
            XCTAssertEqual(viewPoint.viewSounds.count, point.viewLocalSounds.count)
            XCTAssertEqual(viewPoint.viewLights.count, point.viewLocalLights.count)
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

        let dto = PointDTO(
            id: pointId,
            userId: [userId],
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
        XCTAssertEqual(point.viewUsers.first?.id, userId)
        XCTAssertEqual(point.viewLocalCameras.first?.id, cameraId)
        XCTAssertEqual(point.viewLocalSounds.first?.id, soundId)
        XCTAssertEqual(point.viewLocalLights.first?.id, lightId)

        // when — update
        let updatedDTO = PointDTO(
            id: pointId, // same id
            userId: [userId],
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
        XCTAssertEqual(updatedPoint.viewLocalCameras.count, 0)
        XCTAssertEqual(updatedPoint.viewLocalSounds.count, 0)
        XCTAssertEqual(updatedPoint.viewLocalLights.count, 0)
    }

    
    func test_updateLocalPoint_withPointDTO_updatesAllFields() async throws {
        // given
        let pointId = UUID().uuidString
        let imageId = UUID().uuidString
        let userId = UUID().uuidString
        let cameraId = UUID().uuidString
        let soundId = UUID().uuidString
        let lightId = UUID().uuidString

        let dto = PointDTO(
            id: pointId,
            userId: [userId], coordinateX: 123.45,
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

        let point = LocalLocationPoint(context: context)
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
        XCTAssertEqual(point.viewUsers.count, 1)
        XCTAssertEqual(point.viewUsers.first?.id, userId)
        XCTAssertEqual(point.viewLocalCameras.count, 1)
        XCTAssertEqual(point.viewLocalCameras.first?.id, cameraId)
        XCTAssertEqual(point.viewLocalSounds.count, 1)
        XCTAssertEqual(point.viewLocalSounds.first?.id, soundId)
        XCTAssertEqual(point.viewLocalLights.count, 1)
        XCTAssertEqual(point.viewLocalLights.first?.id, lightId)
    }

    func test_createOrUpdateLocalTemplatePointWithTemplatePoint_populatesAllFieldsCorrectly() {
        // Given
        let id = UUID().uuidString
        let dto = TemplatePointDTO.mock(id: id)

        // When
        let point = sut.createOrUpdateLocalTemplatePointWithTemplatePoint(dto, inContext: .main)

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
        _ = sut.createOrUpdateLocalTemplatePointWithTemplatePoint(initial, inContext: .main)
        
        // Update DTO
        var updated = TemplatePointDTO.mock(id: id)
        updated.coordinateX = 999.0
        updated.number = 777
        updated.cameras = [CameraDTO(id: "updatedCam", optic: .x22)]

        let point = sut.createOrUpdateLocalTemplatePointWithTemplatePoint(updated, inContext: .main)

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

        let point = sut.createOrUpdateLocalTemplatePointWithTemplatePoint(dto, inContext: .main)

        XCTAssertEqual(point.cameras, "")
        XCTAssertEqual(point.sounds, "")
        XCTAssertEqual(point.lights, "")
    }

    func testAddCamerasToPoint() async {
            // Создадим мок PointDTO с камерами
            let pointDTO = PointDTO.mock(id: "testPoint")
            
            // Обновим LocalLocationPoint
        let localPoint = sut.createOrUpdateLocalPointWithPointDTO(pointDTO, inContext: .main)
            
            // Проверяем, что у LocalLocationPoint есть камеры
            XCTAssertEqual(localPoint.viewLocalCameras.count, 2, "Ожидается 2 камеры у LocalLocationPoint")
            
            // Проверим, что камера с правильными ID добавлена
            let cameraIds = localPoint.viewLocalCameras.map { $0.id }
            XCTAssertTrue(cameraIds.contains("cam1-testPoint"), "Не найдена камера с ID 'cam1'")
            XCTAssertTrue(cameraIds.contains("cam2-testPoint"), "Не найдена камера с ID 'cam2'")
        }
        
        func testNoCamerasIfPointNotUpdated() async {
            // Создадим точку без камер
            let pointDTO = PointDTO(id: "testPointWithoutCameras", userId: [], coordinateX: 0, coordinateY: 0, rotation: 0, scale: 1, imageId: "", number: 0, description: "", task: "", cameras: [], sounds: [], lights: [])
            
            // Обновим LocalLocationPoint
            let localPoint = sut.createOrUpdateLocalPointWithPointDTO(pointDTO, inContext: .main)
            
            // Проверяем, что у точки нет камер
            XCTAssertEqual(localPoint.viewLocalCameras.count, 0, "Не должно быть камер у LocalLocationPoint")
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

extension UserDTO {
    static func mock(id: String = UUID().uuidString) -> UserDTO{
        UserDTO(id: id)
    }
}

extension EventDTO{
    static func mock(id: String = UUID().uuidString, ownersIds:[String] = [], usersIds: [String] = [])->EventDTO{
        var eventDTO = EventDTO(id: id,
                                date: Date(),
                                obVanId: "obvanId-\(id)",
                                locationPoints: [PointDTO.mock(id: "1-\(id)"),PointDTO.mock(id: "2-\(id)"),PointDTO.mock(id: "3-\(id)")],
                                obvanUnits: [UnitDTO.mock(id: "1-\(id)"),UnitDTO.mock(id: "2"),UnitDTO.mock(id: "3-\(id)")],
                                locationID: "locationId-\(id)",
                                homeClubId: "homeClubId-\(id)",
                                guestClubId: "guestClubId-\(id)",
                                locationPreviewId: "locPrevId-\(id)",
                                obvanPreviewId: "obvanPrevId-\(id)")
        eventDTO.ownersIds = ownersIds
        eventDTO.usersIds = usersIds
        return eventDTO
    }
}

extension LocationDTO{
    static func mock(id: String)->LocationDTO{
        LocationDTO(id: id,
                    title: "title-\(id)",
                    address: "address-\(id)",
                    imagesIds: ["img1-\(id)","img2-\(id)"],
                    locationBackgroundId: "bg-\(id)")
    }
}

extension ClubDTO{
    static func mock(id: String) -> ClubDTO{
        ClubDTO(id: id,
                title: "Title-\(id)",
                contacts: "contacts-\(id)",
                urlString: "URL address-\(id)",
                imageLogoID: "logoId-\(id)",
                homeLocationID: "locationId-\(id)")
    }
}

extension ObvanDTO{
    static func mock(id: String) -> ObvanDTO{
        ObvanDTO(id: id,
                 name: "obvanName-\(id)",
                 imageId: "obvanImgId-\(id)",
                 broadcaster: "broadcasterName-\(id)")
    }
}


extension ImageDTO{
    static func mock(id: String) -> ImageDTO{
        ImageDTO(id: id,
                 type: GlobalProperties.ImageType.location.rawValue)
    }
}

extension PointDTO{
    static func mock(id: String) -> PointDTO{
        PointDTO(id: id,
                 userId: [],
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

extension UnitDTO{
    static func mock(id: String) -> UnitDTO{
        UnitDTO(id: id,
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
                    envType: ReplayType.evs,
                    chanels: ["one","two","three"])
    }
    
}
