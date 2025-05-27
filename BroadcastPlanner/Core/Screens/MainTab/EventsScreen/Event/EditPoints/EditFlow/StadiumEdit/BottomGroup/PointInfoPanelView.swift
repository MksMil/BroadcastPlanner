import Combine
import SwiftUI

struct PointInfoPanelView: View {

    @EnvironmentObject var pointManager: BPEditStadiumViewModel
    @Environment(\.dismiss) var dismiss

    @StateObject var vm: PointInfoPanelViewModel
    @FetchRequest<Member>(sortDescriptors: [SortDescriptor(\.lastName, order: .forward)]) var availableUsers
    let saveAction: (Int,Member?,OpticType,PlaceType,WindDefence,LightType)->()
    init(point: VenuePoint, saveAction: @escaping (Int,Member?,OpticType,PlaceType,WindDefence,LightType)->()) {
        self._vm = StateObject(
            wrappedValue: PointInfoPanelViewModel(point: point)
        )
        self.saveAction = saveAction
    }

    var body: some View {
        ScrollView{
            VStack(spacing: 0) {
                DividerWithText(text: "select position number")
                    .padding(.bottom,5)
                TabViewList(
                    source: vm.availableNumbers,
                    selectedItem: vm.number,
                    pageCount: 6,
                    spacing: 5
                ) { num in
                    vm.number = vm.number == num ? 0: num
                    vm.publisher.send((PointEditPublishType.number, num))
                } content: { num in
                    SelectablePointEditCellWithContent(
                        val: num,
                        publishType: PointEditPublishType.number
                    ) {
                        PointEditTextCellView(text: "\(num)")
                        
                    }
                }
                .frame(height: 75)
                
                DividerWithText(text:"select camera type")
                    .padding(.vertical,5)
                
                TabViewList(
                    source: OpticType.allCases,
                    selectedItem: vm.selectedCameraOptic,
                    pageCount: 6,
                    spacing: 5
                ) { optic in
                    vm.selectedCameraOptic = vm.selectedCameraOptic == optic ? .none: optic
                    vm.publisher.send(
                        (PointEditPublishType.optic, optic)
                    )
                } content: { optic in
                    SelectablePointEditCellWithContent(
                        val: optic,
                        publishType: PointEditPublishType.optic
                    ) {
                        PointEditTextCellView(text: optic.rawValue)
                    }
                }
                .frame(height: 75)
                
                DividerWithText(text:"select mic and wind defence type")
                    .padding(.bottom,5)
                
                TabViewList(
                    source: PlaceType.allCases,
                    selectedItem: vm.selectedSoundPlaceType,
                    pageCount: 6,
                    spacing: 5
                ) { place in
                    vm.selectedSoundPlaceType = vm.selectedSoundPlaceType == place ? .none: place
                    vm.publisher.send(
                        (PointEditPublishType.placeType, place)
                    )
                } content: { place in
                    SelectablePointEditCellWithContent(
                        val: place,
                        publishType: PointEditPublishType.placeType
                    ) {
                        PointEditTextCellView(text: place.rawValue)
                    }
                }
                .frame(height: 75)
                .padding(.bottom,5)
                
                TabViewList(
                    source: WindDefence.allCases,
                    selectedItem: vm.selectedSoundWindDefence,
                    pageCount: 6,
                    spacing: 5
                ) { defence in
                    vm.selectedSoundWindDefence = vm.selectedSoundWindDefence == defence ? .none: defence
                    vm.publisher.send(
                        (PointEditPublishType.windDefence, defence)
                    )
                } content: { defence in
                    SelectablePointEditCellWithContent(
                        val: defence,
                        publishType: PointEditPublishType.windDefence
                    ) {
                        PointEditTextCellView(text: defence.rawValue)
                    }
                }
                .frame(height: 75)
                
                DividerWithText(text:"select light type")
                    .padding(.bottom,5)
                
                TabViewList(
                    source: LightType.allCases,
                    selectedItem: vm.selectedLight,
                    pageCount: 6,
                    spacing: 5
                ) { light in
                    vm.selectedLight = vm.selectedLight == light ? .none: light
                    vm.publisher.send(
                        (PointEditPublishType.light, light)
                    )
                } content: { light in
                    SelectablePointEditCellWithContent(
                        val: light,
                        publishType: PointEditPublishType.light
                    ) {
                        PointEditTextCellView(text: light.rawValue)
                    }
                }
                .frame(height: 75)
                //            Divider()
                //            TabViewList(source: CameraPosition.allCases,
                //                        pageCount: 5, spacing: 5) { position in
                //                print("position tapped")
                //                vm.position = position
                //                vm.publisher.send((GlobalProperties.PublishChanges.cameras, position))
                //            } content: { position in
                //                SelectablePointEditCellWithContent(val: position,
                //                                                   publishType: .cameras) {
                //                    PointEditTextCellView(text: position.rawValue)
                //                }
                //            }
                //            .frame(height: 50)
                DividerWithText(text: "select user")
                    .padding(.bottom,5)
                TabViewList(
                    source: availableUsers.compactMap{ user in
                        if user != vm.selectedUser{
                            return user.isAvailableToEvent(event: pointManager.event) ? user: nil
                        } else {
                            return user
                        }
                    },
                    selectedItem: vm.selectedUser,
                    pageCount: 4,
                    spacing: 5
                ) { user in
                    vm.selectedUser = vm.selectedUser == user ? nil: user
                    vm.publisher.send((PointEditPublishType.user, user))
                } content: { user in
                    SelectablePointEditCellWithContent(
                        val: user,
                        publishType: PointEditPublishType.user
                    ) {
                        PointEditUserCellView(user: user)
                    }
                    
                }
                .frame(height: 150)
                
                DividerWithText(text: "save or cancel")
                    .padding(.bottom,5)
                HStack{
                    Spacer()
                    Button("Cancel"){
                        dismiss()
                    }
                    .padding(8)
                    .background{
                        RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.4))
                    }
                    Spacer()
                    Button(" Save "){
                        print("Save tapped: num:\(vm.number), user: \(vm.selectedUser?.viewCompactName ?? "no user"), optic: \(vm.selectedCameraOptic.rawValue), sound: \(vm.selectedSoundPlaceType.rawValue) / \(vm.selectedSoundWindDefence.rawValue), light: \(vm.selectedLight.rawValue)")
                        saveAction(vm.number,vm.selectedUser,vm.selectedCameraOptic,vm.selectedSoundPlaceType,vm.selectedSoundWindDefence,vm.selectedLight)
                        //save venuePoint invoked here
                        dismiss()
                    }
                    .padding(8)
                    .background{
                        RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.4))
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(15)
        }
        .environmentObject(vm)
    }
}

#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(
        localDataManager: lm,
        globalDataManager: NetworkManager(),
        userId: "123"
    )
    let localEvent = lm.fetchOrCreateObject(
        ofType: Broadcast.self,
        predicate: NSPredicate(format: "id == %@", "id"),
        in: lm.mainContext
    ) { ctx in
        let newEvent = Broadcast(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
    return BPEditStadiumView(event: localEvent)
        .environmentObject(mdm)
        .environment(\.managedObjectContext, lm.mainContext)
}
