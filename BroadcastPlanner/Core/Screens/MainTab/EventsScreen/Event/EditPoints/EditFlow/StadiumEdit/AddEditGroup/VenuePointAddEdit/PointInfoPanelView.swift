import Combine
import SwiftUI

struct PointInfoPanelView: View {
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var vm: AddEditPointOrObvanViewModel
   
    @FetchRequest<Member>(sortDescriptors: [SortDescriptor(\.lastName, order: .forward)]) var availableUsers

    var body: some View {
        VStack{

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
                        source: settings.opticType,
                        selectedItem: vm.selectedCameraOptic,
                        pageCount: 6,
                        spacing: 5
                    ) { optic in
                        vm.selectedCameraOptic = vm.selectedCameraOptic == optic ? settings.opticType[0]: optic
                        vm.publisher.send(
                            (PointEditPublishType.optic, optic)
                        )
                    } content: { optic in
                        SelectablePointEditCellWithContent(
                            val: optic,
                            publishType: PointEditPublishType.optic
                        ) {
                            PointEditTextCellView(text: optic)
                        }
                    }
                    .frame(height: 75)
                    
                    DividerWithText(text:"select mic and wind defence type")
                        .padding(.bottom,5)
                    
                    TabViewList(
                        source: settings.soundPlaceType,
                        selectedItem: vm.selectedSoundPlaceType,
                        pageCount: 6,
                        spacing: 5
                    ) { place in
                        vm.selectedSoundPlaceType = vm.selectedSoundPlaceType == place ? settings.soundPlaceType[0]: place
                        vm.publisher.send(
                            (PointEditPublishType.placeType, place)
                        )
                    } content: { place in
                        SelectablePointEditCellWithContent(
                            val: place,
                            publishType: PointEditPublishType.placeType
                        ) {
                            PointEditTextCellView(text: place)
                        }
                    }
                    .frame(height: 75)
                    .padding(.bottom,5)
                    
                    TabViewList(
                        source: settings.windDefenceType,
                        selectedItem: vm.selectedSoundWindDefence,
                        pageCount: 6,
                        spacing: 5
                    ) { defence in
                        vm.selectedSoundWindDefence = vm.selectedSoundWindDefence == defence ? settings.windDefenceType[0]: defence
                        vm.publisher.send(
                            (PointEditPublishType.windDefence, defence)
                        )
                    } content: { defence in
                        SelectablePointEditCellWithContent(
                            val: defence,
                            publishType: PointEditPublishType.windDefence
                        ) {
                            PointEditTextCellView(text: defence)
                        }
                    }
                    .frame(height: 75)
                    
                    DividerWithText(text:"select light type")
                        .padding(.bottom,5)
                    
                    TabViewList(
                        source: settings.lightType,
                        selectedItem: vm.selectedLight,
                        pageCount: 6,
                        spacing: 5
                    ) { light in
                        vm.selectedLight = vm.selectedLight == light ? settings.lightType[0]: light
                        vm.publisher.send(
                            (PointEditPublishType.light, light)
                        )
                    } content: { light in
                        SelectablePointEditCellWithContent(
                            val: light,
                            publishType: PointEditPublishType.light
                        ) {
                            PointEditTextCellView(text: light)
                        }
                    }
                    .frame(height: 75)
                    //            Divider()
                    //            TabViewList(source: settings.cameraPosition,
                    //                        pageCount: 5, spacing: 5) { position in
                    //                vm.position = position
                    //                vm.publisher.send((GlobalProperties.PublishChanges.cameras, position))
                    //            } content: { position in
                    //                SelectablePointEditCellWithContent(val: position,
                    //                                                   publishType: .cameras) {
                    //                    PointEditTextCellView(text: position)
                    //                }
                    //            }
                    //            .frame(height: 50)
                    DividerWithText(text: "select member")
                        .padding(.bottom,5)
                    TabViewList(
                        source: availableUsers.compactMap{ user in
                            if user != vm.selectedUser{
                                return user.isAvailableTo(broadcast: vm.broadcast) ? user: nil
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
                            PointEditUserCellView(name: user.viewCompactName,
                                                  id: user.viewId)
                        }
                        
                    }
                    .frame(height: 150)
                    Spacer()
                }
                .padding(15)
            }
        }
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
