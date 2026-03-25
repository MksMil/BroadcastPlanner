import Combine
import SwiftUI

@MainActor
final class BroadcastListViewModel: ObservableObject {

  // MARK: - Dependencies
  private let broadcastRepository: BroadcastRepositoryProtocol
  private let memberRepository: MemberRepositoryProtocol
  private let router: BroadcastListRouting

  // MARK: - Published
  @Published var isLoading: Bool = false
  @Published var error: String? = nil

  let currentUserId: String
  // MARK: - Computed
  var canCreateBroadcast: Bool {
    memberRepository.accessLevel < 2
  }

  // MARK: - Init
  init(
    broadcastRepository: BroadcastRepositoryProtocol,
    memberRepository: MemberRepositoryProtocol,
    router: BroadcastListRouting
  ) {
    self.broadcastRepository = broadcastRepository
    self.memberRepository = memberRepository
    self.router = router
    self.currentUserId = memberRepository.currentUserId
  }

  // MARK: - Actions

  func openExisting(_ broadcast: Broadcast) {
    router.openBroadcast(broadcast)
  }

  func createAndOpen() async {
    isLoading = true
//    try? await Task.sleep(for: .milliseconds(100))
    guard canCreateBroadcast else { return }
    defer {
      isLoading = false
    }
    do {
      let broadcast = try await broadcastRepository.createBroadcast()
      router.openNewBroadcast(broadcast)
      try? await Task.sleep(for: .milliseconds(400))
    } catch {
      self.error = error.localizedDescription
    }
  }
  
  //delete
  func delete(broadcast: Broadcast) {
    Task {
      await broadcastRepository.removeBroadcast(broadcast.objectID)
      
    }
  }
  
  // MARK: - CoreData predicates update for filter cases
  func predicate(for filter: FilterEventOwnerCases, expired: Bool) -> NSCompoundPredicate {
      let corePredicate: NSPredicate
      switch filter {
      case .notFiltered:
          corePredicate = NSPredicate(format: "id != %@", "")
      case .userOwned:
          corePredicate = NSPredicate(format: "ANY owners.id == %@", currentUserId)
      case .userParticipation:
          corePredicate = NSPredicate(
              format: "SUBQUERY(venuePoints, $point, $point.member.id == %@).@count > 0 OR SUBQUERY(crews, $crew, $crew.member.id == %@).@count > 0",
              currentUserId, currentUserId
          )
      }
      var predicates = [corePredicate]
      if !expired {
          predicates.append(NSPredicate(format: "date > %@", argumentArray: [Date.now]))
      }
      return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
  }

  func title(for filter: FilterEventOwnerCases) -> StatusViewTitleCase {
      switch filter {
        case .notFiltered: return .notFiltered
        case .userOwned: return .userOwned
        case .userParticipation: return .userParticipation
      }
  }
}
