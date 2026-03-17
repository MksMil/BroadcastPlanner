import XCTest
import CoreData
@testable import BroadcastPlanner
// MockBroadcastRepository.swift
final class MockBroadcastRepository: BroadcastRepositoryProtocol {
  func updateBroadcast(_ broadcastObjectID: NSManagedObjectID) async {}
  
  func removeBroadcast(_ broadcastObjectID: NSManagedObjectID) async {}
  
  func assignSnapshot(_ image: UIImage?, toBroadcastObjectID: NSManagedObjectID) {}
  
  func makeLocalPointsFromTemplate(_ templateObjectID: NSManagedObjectID) async -> [BroadcastPlanner.VenuePoint] {[]}
  
  func saveTemplateFromSchema(localPointIDs: [NSManagedObjectID], withName name: String) async {}
  
  func updatePoint(_ pointObjectID: NSManagedObjectID, number: Int, userObjectID: NSManagedObjectID?, optic: String, placeType: String, windDefence: String, lightType: String) {}
  
    var currentUserObjectID: NSManagedObjectID?
    var broadcastToReturn: Broadcast?
    var shouldThrow: Bool = false

    func createBroadcast() async throws -> Broadcast {
        if shouldThrow { throw NSError(domain: "test", code: 0) }
        return broadcastToReturn!
    }
    // остальные методы — пустые реализации
}

// MockRouter.swift
final class MockRouter: BroadcastListRouting {
    var openedBroadcast: Broadcast?
    var openedNewBroadcast: Broadcast?

    func openBroadcast(_ broadcast: Broadcast) {
        openedBroadcast = broadcast
    }
    func openNewBroadcast(_ broadcast: Broadcast) {
        openedNewBroadcast = broadcast
    }
}
// MockMemberRepository.swift
final class MockMemberRepository: MemberRepositoryProtocol {
    var currentUserId: String = ""
    var currentUserObjectID: NSManagedObjectID? = nil
    var accessLevel: Int = 2  // по умолчанию — нет доступа

    func setMember(id: String) async {}
    func fetchOwner() -> Member? { nil }
    func fetchUsersAvailableForEvent(_ eventObjectID: NSManagedObjectID) -> [Member] { [] }
    func clearCurrentUser() {}
}

// тест на canCreateBroadcast
@MainActor func testCanCreateBroadcast_whenAccessLevelIsLow() {
    let members = MockMemberRepository()
    members.accessLevel = 1  // есть доступ

    let vm = BroadcastListViewModel(
        broadcastRepository: MockBroadcastRepository(),
        memberRepository: members,
        router: MockRouter()
    )

    XCTAssertTrue(vm.canCreateBroadcast)
}

@MainActor
func testCannotCreateBroadcast_whenAccessLevelIsHigh() {
    let members = MockMemberRepository()
    members.accessLevel = 2  // нет доступа

    let vm = BroadcastListViewModel(
        broadcastRepository: MockBroadcastRepository(),
        memberRepository: members,
        router: MockRouter()
    )

    XCTAssertFalse(vm.canCreateBroadcast)
}

@MainActor
func testCreateAndOpen_blockedWhenNoAccess() async {
    let members = MockMemberRepository()
    members.accessLevel = 2
    let router = MockRouter()

    let vm = BroadcastListViewModel(
        broadcastRepository: MockBroadcastRepository(),
        memberRepository: members,
        router: router
    )

    await vm.createAndOpen()

    XCTAssertNil(router.openedNewBroadcast) // навигации не было
}

// BroadcastListViewModelTests.swift
@MainActor
func testCreateAndOpen_success() async {
  let repo =  MockBroadcastRepository()
  let mem =  MockMemberRepository()
  let router =  MockRouter()
//    repo.broadcastToReturn = // мок Broadcast
    
  let vm = BroadcastListViewModel(
      broadcastRepository: MockBroadcastRepository(),
      memberRepository: mem,
      router: router
  )
    await vm.createAndOpen()

    XCTAssertNotNil(router.openedNewBroadcast)
    XCTAssertFalse(vm.isLoading)
    XCTAssertNil(vm.error)
}

@MainActor
func testCreateAndOpen_failure() async {
  let repo =  MockBroadcastRepository()
  let mem =  MockMemberRepository()
  let router =  MockRouter()
//    repo.broadcastToReturn = // мок Broadcast
  repo.shouldThrow = true
    
  let vm = BroadcastListViewModel(
      broadcastRepository: MockBroadcastRepository(),
      memberRepository: mem,
      router: router
  )
    await vm.createAndOpen()

    await vm.createAndOpen()

    XCTAssertNil(router.openedNewBroadcast)
    XCTAssertNotNil(vm.error)
}





