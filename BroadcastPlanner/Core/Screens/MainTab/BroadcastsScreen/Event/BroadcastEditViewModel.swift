//
//  BroadcastEditViewModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 17.03.2026.
//

import Combine
// BroadcastEditViewModel.swift
import SwiftUI

@MainActor
final class BroadcastEditViewModel: ObservableObject {

  // MARK: - Published

  @Published var homeClub: Club?
  @Published var guestClub: Club?
  @Published var venue: Venue?
  @Published var date: Date
  @Published var owners: [Member]
  @Published var imageWidth: Double = .infinity

  @Published var memberToShow: VenuePoint?
  @Published var isBroadcastRemoveConfirm: Bool = false
  @Published var isRemoveFromOwnersConfirm: Bool = false
  @Published var ownerToRemove: Member?

  @Published var isSaving: Bool = false
  @Published var errorMessage: String?

  // MARK: - Private

  private(set) var broadcast: Broadcast
  private let isNew: Bool
  private let dataManager: DataManager
  private let router: Router

  // MARK: - Init

  init(
    broadcast: Broadcast,
    isNew: Bool,
    dataManager: DataManager,
    router: Router
  ) {
    self.broadcast = broadcast
    self.isNew = isNew
    self.dataManager = dataManager
    self.router = router

    self.homeClub = broadcast.homeClub
    self.guestClub = broadcast.guestClub
    self.venue = broadcast.venue
    self.date = broadcast.viewDate
    self.owners = broadcast.viewOwners
  }

  // MARK: - Club

  func setHomeClub(_ club: Club) {
    homeClub = club
    broadcast.homeClub = club
  }

  func setGuestClub(_ club: Club) {
    guestClub = club
    broadcast.guestClub = club
  }

  // MARK: - Venue

  func setVenue(_ newVenue: Venue) {
    venue = newVenue
    broadcast.venue = newVenue
  }

  // MARK: - Date

  func setDate(_ newDate: Date) {
    date = newDate
    broadcast.date = newDate
  }

  // MARK: - Owners

  func addOwner(_ member: Member) {
    guard !broadcast.viewOwners.contains(member) else { return }
    broadcast.addToOwners(member)
    owners = broadcast.viewOwners
  }

  func confirmRemoveOwner(_ member: Member) {
    ownerToRemove = member
    isRemoveFromOwnersConfirm = true
  }

  func removeOwner() {
    guard
      let member = ownerToRemove,
      broadcast.viewOwners.count > 1
    else { return }
    broadcast.removeFromOwners(member)
    owners = broadcast.viewOwners
    ownerToRemove = nil
  }

  // MARK: - VenuePoint highlight

  func toggleMemberToShow(_ point: VenuePoint) {
    memberToShow = (memberToShow == point) ? nil : point
  }

  // MARK: - ImageWidth (из GeometryReader)

  func updateImageWidth(_ width: Double) {
    guard width > 0, width.isFinite else { return }
    imageWidth = width
  }

  // MARK: - Save
  func save() {
    broadcast.lastUpdated = .now
    isSaving = true
    Task {
      
        // 1. сохраняем mainContext — синхронно, мы уже на MainActor
         dataManager.save()

        // 2. Firebase sync — async, objectID безопасно передаём между потоками
        await dataManager.updateBroadcast(broadcast.objectID)

        isSaving = false
        router.stepBack()
      
    }
  }

  // MARK: - Cancel / Delete

  func cancel() {
    if isNew {
      dataManager.rollBackMoc()
    }
    router.stepBack()
  }

  func confirmDelete() {
    isBroadcastRemoveConfirm = true
  }

  func delete() {
    Task {
      await dataManager.removeBroadcast(broadcast.objectID)
      router.stepBack()
    }
  }
}
