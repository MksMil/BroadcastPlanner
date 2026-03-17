//import Combine
//import SpriteKit
//import SwiftUI
//
//struct BroadcastEditView: View {
//    let logoSize: Double = 90
//        
//    @EnvironmentObject var appState: ApplicationState
//    @EnvironmentObject var router: Router
//    @EnvironmentObject var dataManager: DataManager
//    
//    let broadcast: Broadcast
//
//    @State private var isBroadcastRemoveConfirm: Bool = false
//    @FetchRequest<Member>(sortDescriptors: []) var members
//    
//    @State private var isRemoveFromOwners: Bool = false
//    @State private var ownerToRemove: Member?
//    @State private var memberToShow: VenuePoint?
//    
//    @State var homeClub: Club?
//    @State var guestClub: Club?
//    
//    //test
////    @State var testImage = Image(systemName: "photo")
//    
//    
//    @State private var imageWidth: Double = .infinity
//    
//    init(broadcast: Broadcast) {
//        self.broadcast = broadcast
//        self._homeClub = State(initialValue: broadcast.homeClub)
//        self._guestClub = State(initialValue: broadcast.guestClub)
//    }
//    
//    var body: some View {
//        ZStack {
//            MainBackground()
//
//            VStack(alignment: .center, spacing: 5) {
//                
//                //header: time, date, teams, venue
//                VStack{
//                    ZStack{
//                        LocationSelectionView(location: broadcast.venue,
//                                              offset: logoSize) {
//                            
//                        } acceptAction: { newVenue in
//                            broadcast.venue = newVenue
//                        }
//                        VStack(spacing: 5){
//                            //team logos section
//                            HStack(alignment: .top) {
//
//                            //club/venue select/add/edit/remove sheet
//                            
//                                
//                                //home team logo/selection action
//                                LogoImageView(selectedClub: $homeClub,
//                                              excludedClub: $guestClub,
//                                              logoSize: logoSize,
//                                              cancelAction: {},
//                                              accessAction: { club in
//                                    broadcast.homeClub = club
//                                }, editable: true)
//                                //broadcast date section
//                                TimeAndDateSelectionView(date: broadcast.viewDate,
//                                                         logoSize: logoSize) {newDate in
//                                    broadcast.date = newDate
//                                }
//                                //guest team logo/selection action
//                                LogoImageView(selectedClub:$guestClub,
//                                              excludedClub: $homeClub,
//                                              logoSize: logoSize,
//                                              cancelAction: {},
//                                              accessAction: { club in
//                                    broadcast.guestClub = club
//                                },editable: true)
//                            }
//                            Spacer()
//                        }
//                        .padding()
//                    }
//                }
//                .frame(height: 250)
//                
//                HStack(spacing: 3){
//                    Text("Owned by:")
//                        .font(.system(size: 14))
//                        .bold()
//                    Menu {
//                        ForEach(members){ member in
//                            Button{
//                                if !broadcast.viewOwners.contains(member){
//                                    broadcast.addToOwners(member)
//                                }
//                            } label: {
//                                HStack{
//                                    Text("\(member.viewCompactName)")
//                                    Spacer()
//                                    if broadcast.viewOwners.contains(member){
//                                        Image(systemName: "checkmark")
//                                    }
//                                }
//                            }
//                        }
//                    } label: {
//                        Image(systemName: "plus")
//                            .padding(4)
//                            .background(content: {
//                                Circle().stroke(Color.white, lineWidth: 2)
//                            })
//                            .padding(4)
//                            .frame(width: 30, height: 30)
//                    }
//                    ScrollView(.horizontal){
//                        HStack(alignment: .center){
//                            ForEach(broadcast.viewOwners){ owner in
//                                //TODO: menu route
//                                LogoInWhiteRectView(id: owner.viewId)
//                                    .frame(width: 30, height: 30)
//                                    .contextMenu {
//                                        Text("\(owner.viewCompactName)")
//                                        Button{
//                                            
//                                        } label:{
//                                            Text("Info")
//                                        }
//                                        Button{
//                                            
//                                        } label:{
//                                            Text("Message")
//                                        }
//                                        Button{
//                                            ownerToRemove = owner
//                                            isRemoveFromOwners = true
//                                        } label:{
//                                            Text("Remove")
//                                        }
//                                    }
//                            }
//                        }
//                        .padding(.leading,5)
//                        .frame(height: 40)
//                    }
//                    
//                }
//                .frame(height: 40)
//                .padding(.leading)
//                
//                //preview + fsc editStad / editCar  views
//                HStack(spacing: 5) {
//                    VStack(alignment: /*broadcast.viewObvans.count > 0 ? .leading: */.center){
//                            ImageWrapper(id: broadcast.viewVenueSchemaPreviewId,
//                                         type: .venuePreview,
//                                         imageSize: .originImages)
//                            .scaledToFit()
//                            .frame(height: 150)
//                            .background(
//                                GeometryReader { imageGeometry in
//                                    Color.clear
//                                        .preference(
//                                            key: ImageWidthPreferenceKey.self,
//                                            value: imageGeometry.size.width
//                                        )
//                                }
//                            )
//                            .onPreferenceChange(ImageWidthPreferenceKey.self) { newWidth in
//                                if let newWidth, newWidth > 0, newWidth.isFinite{
//                                    print("new imageWidth:\(imageWidth)")
//                                    imageWidth = newWidth
//                                }
//                            }
//                            .overlay {
//                                if let memberToShow{
//                                    Circle().stroke(Color.red, lineWidth: 1)
//                                        .frame(width: 15, height: 15)
//                                        .scaleEffect(memberToShow.viewScaleFactor)
//                                        .position(CGPoint(x: imageWidth * memberToShow.viewX ,
//                                                          y: 150 * (1 - memberToShow.viewY)))
//                                }
//                            }
//                        .onTapGesture {
////                            router.routeTo(path: .stadPointsEdit(broadcast))
//                        }
//                        
//                        Divider()
//                            .opacity(broadcast.viewVenuePoints.count > 0 ? 1 : 0)
//                            .padding(.horizontal,5)
//                        //crews smart list
//                        SmartCollection(hSpacing: 5, vSpacing: 5){
//                            ForEach(broadcast.viewVenuePoints.sorted(by: { first, second in
//                                first.number < second.number
//                            })){ point in
//                                LogoInWhiteRectView(id: point.viewMembers.first?.id ?? "")
//                                    .frame(width: 30, height: 30)
//                                    .contextMenu {
//                                        Text("\(point.viewMembers.first?.viewCompactName ?? "empty position")")
//                                        //TODO: menu route
//                                        Button{
//                                            
//                                        } label:{
//                                            Text("Info")
//                                        }
//                                        Button{
//                                            
//                                        } label:{
//                                            Text("Message")
//                                        }
//                                    }
//                                    .onTapGesture {
//                                        memberToShow = memberToShow == point ? nil: point
//                                        print("\(imageWidth)")
//                                    }
//                                    .scaleEffect(point == memberToShow ? 1.05 : 0.95)
//                                    .opacity(point == memberToShow ? 1 : 0.75)
//                            }
//                        }
//                        .padding(.horizontal,5)
//                        Spacer()
//                    }
//                    .frame(maxWidth: broadcast.viewObvans.count > 0 ? imageWidth + 20: .infinity)
//                    .layoutPriority(1)
//                    Divider()
//                        .opacity(broadcast.viewObvans.count > 0 ? 1 : 0)
//                        .offset(x: -10)
//                    VStack(alignment: .leading){
//                        ScrollView{
//                            ForEach(broadcast.viewObvans.sorted(by: { first, second in
//                                first.viewName < second.viewName
//                            })) { obvan in
//                                VStack{
//                                    ImageWrapper(id: obvan.id, type: .obvan,imageSize: ImageSizes.smallImages)
//                                        .scaledToFit()
//                                        .onTapGesture {
////                                            router.routeTo(path: .stadPointsEdit(broadcast))
//                                        }
//                                    SmartCollection(hSpacing: 5, vSpacing: 5){
//                                        ForEach(broadcast.crewsForObvan(obvan: obvan)){ crew in
//                                            LogoInWhiteRectView(id: crew.member?.id ?? "")
//                                                .frame(width: 30, height: 30)
//                                                .contextMenu {
//                                                    Text("\(crew.viewPosition): \(crew.member?.viewCompactName ?? "")")
//                                                    //TODO: menu route
//                                                    Button{
//                                                        
//                                                    } label:{
//                                                        Text("Info")
//                                                    }
//                                                    Button{
//                                                        
//                                                    } label:{
//                                                        Text("Message")
//                                                    }
//                                                }
//                                        }
//                                    }
//                                    Divider()
//                                        .opacity(broadcast.viewObvans.count > 0 ? 1 : 0)
//                                }
//                            }
//                        }
//                        Spacer()
//                    }
//                    .offset(x: -10)
//                }
//                .frame(maxWidth: .infinity)
////                .padding(.horizontal)
//                Spacer()
//            }
//            .transitionWithOpacity()
//        }
//        .navigationBarBackButtonHidden()
//        .confirmationDialog("", isPresented: $isBroadcastRemoveConfirm) {
//            Button("Delete Broadcast", role: .destructive){
////                Task{
////                   await dataManager.removeBroadcast(broadcast)
////                    router.stepBack()
////                }
//            }
//        }
//        .onAppear{
////            appState.primaryAction = {
////                do{
////                   try dataManager.saveAndPublish(publish: .broadcasts, id: [broadcast.viewId])
////                } catch{
////                    print("error save context: \(error.localizedDescription)")
////                    //show error in 'status'
////                    //log error
////                }
//////                Task{
//////                    await dataManager.updateBroadcast(broadcast)
//////                }
//////                router.stepBack()
////            }
////            appState.secondaryAction = {
////                isBroadcastRemoveConfirm = true
////            }
////            appState.stepBackAction = {
////               
////            }
//        }
//        .confirmationDialog("Remove", isPresented: $isRemoveFromOwners) {
//            Button("Remove  \(ownerToRemove?.viewCompactName ?? "") from owners?", role: .destructive) {
//                if let ownerToRemove, broadcast.viewOwners.count > 1 {
//                    broadcast.removeFromOwners(ownerToRemove)
//                    self.ownerToRemove = nil
//                }
//            }
//        }
////        .task{
////            
////                if let id = broadcast.venueSchemaPreview?.viewId,
////                   let uiimage = await dataManager.getImageWithId(id, type: GlobalProperties.ImageType.venuePreview, size: .originImages){
////                    await MainActor.run{
////                        testImage = Image(uiImage: uiimage)
////                    }
////                }
////            
////        }
//    }
//}

// BroadcastEditView.swift
import Combine
import SpriteKit
import SwiftUI

struct BroadcastEditView: View {
    let logoSize: Double = 90

    @EnvironmentObject var appState: ApplicationState
    @FetchRequest<Member>(sortDescriptors: []) var members

    @StateObject private var vm: BroadcastEditViewModel

    init(broadcast: Broadcast, isNew: Bool = false, dataManager: DataManager, router: Router) {
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
              VStack(alignment: .center, spacing: 5) {
                  headerSection
                  ownersSection
                  venueAndObvansSection
                  Spacer()
              }
              .transitionWithOpacity()
          }
          .navigationBarBackButtonHidden()
          .toolbar { toolbarContent }
          .confirmationDialog("Delete Broadcast", isPresented: $vm.isBroadcastRemoveConfirm) {
              Button("Delete", role: .destructive) { vm.delete() }
          }
          .confirmationDialog("Remove owner", isPresented: $vm.isRemoveFromOwnersConfirm) {
              Button("Remove \(vm.ownerToRemove?.viewCompactName ?? "") from owners?", role: .destructive) {
                  vm.removeOwner()
              }
          }
          .alert("Error", isPresented: Binding(
              get: { vm.errorMessage != nil },
              set: { if !$0 { vm.errorMessage = nil } }
          )) {
              Button("OK", role: .cancel) { vm.errorMessage = nil }
          } message: {
              Text(vm.errorMessage ?? "")
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
                                  Button { } label: { Text("Info") }
                                  Button { } label: { Text("Message") }
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
              .frame(height: 150)
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
                          .position(CGPoint(
                              x: vm.imageWidth * point.viewX,
                              y: 150 * (1 - point.viewY)
                          ))
                  }
              }

              Divider()
                  .opacity(vm.broadcast.viewVenuePoints.count > 0 ? 1 : 0)
                  .padding(.horizontal, 5)

              SmartCollection(hSpacing: 5, vSpacing: 5) {
                  ForEach(vm.broadcast.viewVenuePoints.sorted { $0.number < $1.number }) { point in
                      LogoInWhiteRectView(id: point.viewMembers.first?.id ?? "")
                          .frame(width: 30, height: 30)
                          .contextMenu {
                              Text(point.viewMembers.first?.viewCompactName ?? "empty position")
                              Button { } label: { Text("Info") }
                              Button { } label: { Text("Message") }
                          }
                          .onTapGesture { vm.toggleMemberToShow(point) }
                          .scaleEffect(point == vm.memberToShow ? 1.05 : 0.95)
                          .opacity(point == vm.memberToShow ? 1 : 0.75)
                  }
              }
              .padding(.horizontal, 5)

              Spacer()
          }
          .frame(maxWidth: vm.broadcast.viewObvans.count > 0 ? vm.imageWidth + 20 : .infinity)
          .layoutPriority(1)
      }

      private var obvansColumn: some View {
          VStack(alignment: .leading) {
              ScrollView {
                  ForEach(vm.broadcast.viewObvans.sorted { $0.viewName < $1.viewName }) { obvan in
                      VStack {
                          ImageWrapper(id: obvan.id, type: .obvan, imageSize: .smallImages)
                              .scaledToFit()

                          SmartCollection(hSpacing: 5, vSpacing: 5) {
                              ForEach(vm.broadcast.crewsForObvan(obvan: obvan)) { crew in
                                  LogoInWhiteRectView(id: crew.member?.id ?? "")
                                      .frame(width: 30, height: 30)
                                      .contextMenu {
                                          Text("\(crew.viewPosition): \(crew.member?.viewCompactName ?? "")")
                                          Button { } label: { Text("Info") }
                                          Button { } label: { Text("Message") }
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

      @ToolbarContentBuilder
      private var toolbarContent: some ToolbarContent {
          ToolbarItem(placement: .navigationBarLeading) {
              Button { vm.cancel() } label: {
                  Image(systemName: "chevron.left")
              }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
              if vm.isSaving {
                  ProgressView()
              } else {
                  Button { vm.save() } label: {
                      Image(systemName: "checkmark")
                  }
              }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
              Button(role: .destructive) { vm.confirmDelete() } label: {
                  Image(systemName: "trash")
              }
          }
      }
  }
