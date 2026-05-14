import Combine
import SpriteKit
import SwiftUI

struct BroadcastEditView: View {
  let logoSize: Double = 90

  @EnvironmentObject var appState: ApplicationState
  @FetchRequest<Member>(sortDescriptors: []) var members

  @StateObject private var vm: BroadcastEditViewModel

  init(
    broadcast: Broadcast,
    isNew: Bool = false,
    dataManager: DataManager,
    router: Router
  ) {
    self._vm = StateObject(
      wrappedValue: BroadcastEditViewModel(
        broadcast: broadcast,
        isNew: isNew,
        dataManager: dataManager,
        router: router
      )
    )
  }

  var body: some View {
    ZStack {
      MainBackground()
      SwipeBackInterceptor {
        vm.cancel()
      }
      .frame(width: 0, height: 0)
      VStack(alignment: .center, spacing: 5) {
        headerSection
        ownersSection
        venueAndObvansSection
        Spacer()
        saveDeleteGroup
      }
      .transitionWithOpacity()
        
    }
    .navigationBarBackButtonHidden()
    .confirmationDialog(
      "Delete Broadcast",
      isPresented: $vm.isBroadcastRemoveConfirm
    ) {
      Button("Delete", role: .destructive) { vm.delete() }
    }
    .confirmationDialog(
      "Remove owner",
      isPresented: $vm.isRemoveFromOwnersConfirm
    ) {
      Button(
        "Remove \(vm.ownerToRemove?.viewCompactName ?? "") from owners?",
        role: .destructive
      ) {
        vm.removeOwner()
      }
    }
    .alert(
      "Error",
      isPresented: Binding(
        get: { vm.errorMessage != nil },
        set: { if !$0 { vm.errorMessage = nil } }
      )
    ) {
      Button("OK", role: .cancel) { vm.errorMessage = nil }
    } message: {
      Text(vm.errorMessage ?? "")
    }
    .onAppear {
      appState.backAction = vm.cancel
    }
    
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack {
      ZStack {
        LocationSelectionView(
          location: vm.venue,
          offset: logoSize,
          cancelAction: {},
          acceptAction: { vm.setVenue($0) }
        )
        VStack(spacing: 5) {
          HStack(alignment: .top) {
            LogoImageView(
              selectedClub: $vm.homeClub,
              excludedClub: $vm.guestClub,
              logoSize: logoSize,
              cancelAction: {},
              accessAction: { vm.setHomeClub($0) },
              editable: true
            )
            TimeAndDateSelectionView(
              date: vm.date,
              logoSize: logoSize,
              acceptAction: { vm.setDate($0) }
            )
            LogoImageView(
              selectedClub: $vm.guestClub,
              excludedClub: $vm.homeClub,
              logoSize: logoSize,
              cancelAction: {},
              accessAction: { vm.setGuestClub($0) },
              editable: true
            )
          }
          Spacer()
        }
        .padding()
      }
    }
    .frame(height: 250)
  }

  // MARK: - Owners

  private var ownersSection: some View {
    HStack(spacing: 3) {
      Text("Owned by:")
        .font(.system(size: 14))
        .bold()

      Menu {
        ForEach(members) { member in
          Button {
            vm.addOwner(member)
          } label: {
            HStack {
              Text(member.viewCompactName)
              Spacer()
              if vm.owners.contains(member) {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      } label: {
        Image(systemName: "plus")
          .padding(4)
          .background { Circle().stroke(Color.white, lineWidth: 2) }
          .padding(4)
          .frame(width: 30, height: 30)
      }

      ScrollView(.horizontal) {
        HStack(alignment: .center) {
          ForEach(vm.owners) { owner in
            LogoInWhiteRectView(id: owner.viewId)
              .frame(width: 30, height: 30)
              .contextMenu {
                Text(owner.viewCompactName)
                Button {
                } label: {
                  Text("Info")
                }
                Button {
                } label: {
                  Text("Message")
                }
                Button {
                  vm.confirmRemoveOwner(owner)
                } label: {
                  Text("Remove")
                }
              }
          }
        }
        .padding(.leading, 5)
        .frame(height: 40)
      }
    }
    .frame(height: 40)
    .padding(.leading)
  }

  // MARK: - Venue schema + OB vans

  private var venueAndObvansSection: some View {
    HStack(spacing: 5) {
      venueSchemaColumn
      Divider()
        .opacity(vm.broadcast.viewObvans.count > 0 ? 1 : 0)
        .offset(x: -10)
      obvansColumn
    }
    .frame(maxWidth: .infinity)
  }

  private var venueSchemaColumn: some View {
    VStack(alignment: .center) {
      ImageWrapper(
        id: vm.broadcast.viewVenueSchemaPreviewId,
        type: .venuePreview,
        imageSize: .originImages
      )
      .scaledToFit()
      .frame(height: 100)
      .background(
        GeometryReader { geo in
          Color.clear.preference(
            key: ImageWidthPreferenceKey.self,
            value: geo.size.width
          )
        }
      )
      .onPreferenceChange(ImageWidthPreferenceKey.self) { newWidth in
        if let newWidth { vm.updateImageWidth(newWidth) }
      }
      .overlay {
        if let point = vm.memberToShow {
          Circle().stroke(Color.red, lineWidth: 1)
            .frame(width: 15, height: 15)
            .scaleEffect(point.viewScaleFactor)
            .position(
              CGPoint(
                x: vm.imageWidth * point.viewX,
                y: 150 * (1 - point.viewY)
              )
            )
        }
      }
      .onTapGesture {
        vm.routeToEditPoints()
      }

      Divider()
        .opacity(vm.broadcast.viewVenuePoints.count > 0 ? 1 : 0)
        .padding(.horizontal, 5)

      SmartCollection(hSpacing: 5, vSpacing: 5) {
        ForEach(vm.broadcast.viewVenuePoints.sorted { $0.number < $1.number }) {
          point in
          LogoInWhiteRectView(id: point.viewMemberId)
            .frame(width: 30, height: 30)
            .contextMenu {
              Text(point.member?.viewCompactName ?? "empty position")
              Button {
              } label: {
                Text("Info")
              }
              Button {
              } label: {
                Text("Message")
              }
            }
            .onTapGesture { vm.toggleMemberToShow(point) }
            .scaleEffect(point == vm.memberToShow ? 1.05 : 0.95)
            .opacity(point == vm.memberToShow ? 1 : 0.75)
        }
      }
      .padding(.horizontal, 5)

      Spacer()
    }
    .frame(
      maxWidth: vm.broadcast.viewObvans.count > 0
        ? vm.imageWidth + 20 : .infinity
    )
    .layoutPriority(1)
  }

  private var obvansColumn: some View {
    VStack(alignment: .leading) {
      ScrollView {
        ForEach(vm.broadcast.viewObvans.sorted { $0.viewName < $1.viewName }) {
          obvan in
          VStack {
            ImageWrapper(id: obvan.id, type: .obvan, imageSize: .smallImages)
              .scaledToFit()

            SmartCollection(hSpacing: 5, vSpacing: 5) {
              ForEach(vm.broadcast.crewsForObvan(obvan: obvan)) { crew in
                LogoInWhiteRectView(id: crew.member?.id ?? "")
                  .frame(width: 30, height: 30)
                  .contextMenu {
                    Text(
                      "\(crew.viewPosition): \(crew.member?.viewCompactName ?? "")"
                    )
                    Button {
                    } label: {
                      Text("Info")
                    }
                    Button {
                    } label: {
                      Text("Message")
                    }
                  }
              }
            }
            Divider()
          }
        }
      }
      Spacer()
    }
    .offset(x: -10)
  }

  // MARK: - Toolbar
  private var saveDeleteGroup: some View {
      HStack(spacing: 0) {

          // Delete — левая часть, деструктивная, визуально приглушена
          Button(role: .destructive) {
              vm.confirmDelete()
          } label: {
              HStack(spacing: 6) {
                  Image(systemName: "trash")
                      .font(.system(size: 16, weight: .medium))
                  Text("Delete")
                      .font(.system(size: 15, weight: .medium))
              }
              .foregroundStyle(.red.opacity(0.8))
              .frame(maxHeight: .infinity)
              .padding(.horizontal, 24)
          }

          Divider()
              .frame(height: 24)
              .overlay(Color.white.opacity(0.4))

          Spacer()

          // Save — правая часть, акцентная
          if vm.isSaving {
              ProgressView()
                  .padding(.horizontal, 24)
          } else {
              Button {
                  vm.save()
              } label: {
                  HStack(spacing: 6) {
                      Image(systemName: "checkmark")
                          .font(.system(size: 16, weight: .semibold))
                      Text("Save")
                          .font(.system(size: 15, weight: .semibold))
                  }
                  .foregroundStyle(.primary)
                  .frame(maxHeight: .infinity)
                  .padding(.horizontal, 24)
              }
          }
      }
      .frame(height: 50)
      .frame(maxWidth: .infinity)
      .background {
          RoundedRectangle(cornerRadius: 14)
              .fill(.ultraThinMaterial)
              .overlay {
                  RoundedRectangle(cornerRadius: 14)
                      .stroke(Color.white.opacity(0.5), lineWidth: 1)
              }
      }
      .padding(.horizontal, 16)
//      .padding(.bottom, 8)
  }
//  private var saveDeleteGroup: some View {
//    HStack {
//      Button(role: .destructive) {
//        vm.confirmDelete()
//      } label: {
//        Image(systemName: "trash")
//      }
//      Spacer()
//      if vm.isSaving {
//        ProgressView()
//      } else {
//        Button {
//          vm.save()
//        } label: {
//          Image(systemName: "checkmark")
//        }
//      }
//    }
//    .border(Color.white, width: 2)
//  }
}
