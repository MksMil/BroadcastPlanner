import CoreData
import XCTest

@testable import BroadcastPlanner

final class DataManagerTests: XCTestCase {

    var sut: DataManager!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        sut = DataManager(forPreview: true)
        container = sut.persistentContainer
        context = container.viewContext
    }

    override func tearDown() {
        context = nil
        sut = nil
        container = nil
        
        super.tearDown()
    }
    // MARK: - Generic
    func test_fetchOrCreateObject_returnsExistingObject_whenFound() {
        // Given
        let id = UUID().uuidString
        let existing = LocalLocationPoint(context: context)
        existing.id = id
        try? context.save()

        let predicate = NSPredicate(format: "id == %@", id)

        // When
        let result = sut.fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: predicate,
            in: context,
            initializer: {
                XCTFail("Initializer should not be called")
                return LocalLocationPoint(context: context)
            }
        )

        // Then
        XCTAssertEqual(result.id, id)
    }
    func test_fetchOrCreateObject_createsNewObject_whenNotFound() {
        let id = UUID().uuidString
        let predicate = NSPredicate(format: "id == %@", id)

        let result = sut.fetchOrCreateObject(
            ofType: LocalLocationPoint.self,
            predicate: predicate,
            in: context,
            initializer: {
                let new = LocalLocationPoint(context: context)
                new.id = id
                return new
            }
        )

        XCTAssertEqual(result.id, id)

        // Is object in context?
        let fetchRequest: NSFetchRequest<LocalLocationPoint> = LocalLocationPoint.fetchRequest()
        let all = try? context.fetch(fetchRequest)
        XCTAssertTrue(all?.contains(where: { $0.id == id }) ?? false)
    }
    // MARK: - User
    func test_createOrUpdateLocalUserWithUser_createsUser_andUpdatesUser(){
        let id = UUID().uuidString
        let userDTO = UserDTO.mock(id: id)
        
        let resultUser = sut.createOrUpdateLocalUserWithUser(userDTO,
                                            inContext: .main)
        XCTAssertEqual(id, resultUser.userId)
    }
    func test_createOrUpdateLocalUserWithUser_fetchesUser_andUpdatesUser(){
        let id = UUID().uuidString
        let userDTO = UserDTO.mock(id: id)
        
        let request: NSFetchRequest<LocalUser> =
            LocalUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 0)
        
        let resultUser = sut.createOrUpdateLocalUserWithUser(userDTO,
                                            inContext: .main)
        XCTAssertEqual(id, resultUser.userId)
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
                            with: userDTO,
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
        
        let _ = sut.createOrUpdateLocalUserWithUser(userDTO,
                                                            inContext: .main)
        let request: NSFetchRequest<LocalUser> = LocalUser.fetchRequest()
        let results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 1)
        
        sut.removeUser(userDTO, inContext: .main)
        let newResults = try? container.viewContext.fetch(request)
        XCTAssertEqual(newResults?.count, 0)
    }
    
    func test_removeLocalUser_removesLocalUser(){
        let localUser = LocalUser(context: context)
        
        sut.removeLocalUser(localUser,
                            inContext: .main)

        let request: NSFetchRequest<LocalUser> = LocalUser.fetchRequest()
        let results = try? container.viewContext.fetch(request)
        XCTAssertEqual(results?.count, 0)
    }
    
    func test_fetchUsersAvailableToEvent_fetchesUsersAvailableToEvent(){
        
    }
    
    // MARK: - Event
    func test_createOrUpdateLocalEventWithEvent_createsEvent_andUpdatesEvent(){
        let id = UUID().uuidString
        let eventDto = EventDTO.mock(id:id)
        
        let request = LocalEvent.fetchRequest()
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)

        let _ = sut.createOrUpdateLocalEventWithEvent(eventDto, inContext: .main)
        
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        XCTAssertEqual(newResults?.first?.viewId, id)
    }
    func test_createOrUpdateLocalEventWithEvent_fetchesEvent_andUpdatesEvent(){
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
        
        let _ = sut.createOrUpdateLocalEventWithEvent(eventDto, inContext: .main)
        
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        XCTAssertEqual(newResults?.first?.viewId, id)
        XCTAssertEqual(results?.first?.date ?? Date(), eventDto.date)
    }
    
    func test_updateLocalEvent_updatesLocalEventWithDTO(){
        let id = UUID().uuidString
        let eventDto = EventDTO.mock(id:id)
        
        let localEvent = LocalEvent(context: context)
        
        sut.updateLocalEvent(localEvent, with: eventDto, inContext: .main)
        
        XCTAssertEqual(localEvent.viewId, id)
    }
    
//    @MainActor
    func test_removeEvent_removesLocalEventUsingDTO(){
        let id = UUID().uuidString
        let eventDto = EventDTO.mock(id:id)
        
        let request = LocalEvent.fetchRequest()
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)

        let _ = sut.createOrUpdateLocalEventWithEvent(eventDto, inContext: .main)
        let newResults = try? context.fetch(request)
        XCTAssertEqual(newResults?.count, 1)
        
        sut.removeEvent(eventDto, inContext: .main)
        let removeResults = try? context.fetch(request)
        XCTAssertEqual(removeResults?.count, 0)
    }
//    @MainActor
    func test_removeLocalEvent_removesLocalEvent(){
        let id = UUID().uuidString
        let request = LocalEvent.fetchRequest()
        let results = try? context.fetch(request)
        XCTAssertEqual(results?.count, 0)
        let localEvent = sut.fetchOrCreateObject(ofType: LocalEvent.self,
                                                 predicate: NSPredicate(format: "id == %@", id),
                                                 in: context) {
                                       let newEvent = LocalEvent(context: context)
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
    func test_(){
        
    }
    
    // MARK: - Templates
    func test_fetchOrCreateLocalTemplateWithId_CreatesNewTemplate() {
        let id = UUID().uuidString
        let template = sut.fetchOrCreateObject(
            ofType: LocalTemplate.self,
            predicate: NSPredicate(format: "id == %@", id),
            in: container.viewContext
        ) {
            let newTemplate = LocalTemplate(context: container.viewContext)
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
        sut.createOrUpdateLocalTemplateWithTemplate(
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
        sut.createOrUpdateLocalTemplateWithTemplate(
            dto,
            inConext: .main
        )

        let updatedDTO = TemplateDTO(
            id: "template2",
            name: "UpdatedName",
            templatePoints: dto.templatePoints
        )
        sut.createOrUpdateLocalTemplateWithTemplate(
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
        sut.createOrUpdateLocalTemplateWithTemplate(
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

        let deleted = try? container.viewContext.fetch(fetchRequest)
        XCTAssertEqual(deleted?.count, 0)
    }

    func test_createLocalLocationPointFromTemplatePoint_CopiesAllFields() {
        let dto = TemplateDTO.mock(id: "template4")
        sut.createOrUpdateLocalTemplateWithTemplate(
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

}

extension TemplateDTO {
    static func mock(id: String = UUID().uuidString) -> TemplateDTO {
        let point = TemplatePointDTO(
            id: UUID().uuidString,
            coordinateX: 10.0,
            coordinateY: 20.0,
            rotation: 90,
            scaleFactor: 1.0,
            cameras: [],
            sounds: [],
            lights: [],
            number: 1,
            pointDescription: "Mock Description",
            task: "Mock Task"
        )
        
        return TemplateDTO(
            id: id,
            name: "MockTemplate",
            templatePoints: [point]
        )
    }
}

extension UserDTO {
    static func mock(id: String = UUID().uuidString) -> UserDTO{
         UserDTO(id: id)
    }
}

extension EventDTO{
    static func mock(id: String = UUID().uuidString, ownersIds:[String] = [], usersIds: [String] = [])->EventDTO{
        var eventDTO = EventDTO(id: id, date: Date(), obVanId: "obvanId", locationPoints: [], obvanUnits: [], locationID: "locationId", homeClubId: "homeClubId", guestClubId: "guestClubId", locationPreviewId: "locPrevId", obvanPreviewId: "obvanPrevId")
        eventDTO.ownersIds = ownersIds
        eventDTO.usersIds = usersIds
        return eventDTO
    }
}
