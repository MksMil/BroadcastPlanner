import Combine
import SwiftUI

struct UnitEditView: View {
  @EnvironmentObject var settings: GlobalSettings

  @Environment(\.dismiss) var dismiss

  @StateObject var vm: UnitEditViewModel
  let state: LayoutState?

  var body: some View {

    VStack {

      ScrollView {
//        VStack(spacing: 0) {
          DividerWithText(text: "select position number")
            .padding(.bottom, 5)
          TabViewList(
            source: vm.availableNumbers,
            selectedItem: vm.number,
            pageCount: 6,
            spacing: 5
          ) { num in
            vm.number = vm.number == num ? 0 : num
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
          
          DividerWithText(text: "select camera type")
            .padding(.vertical, 5)
          
          TabViewList(
            source: settings.opticType,
            selectedItem: vm.selectedCameraOptic,
            pageCount: 6,
            spacing: 5
          ) { optic in
            vm.selectedCameraOptic =
            vm.selectedCameraOptic == optic ? settings.opticType[0] : optic
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
          
          DividerWithText(text: "select mic and wind defence type")
            .padding(.bottom, 5)
          
          TabViewList(
            source: settings.soundPlaceType,
            selectedItem: vm.selectedSoundPlaceType,
            pageCount: 6,
            spacing: 5
          ) { place in
            vm.selectedSoundPlaceType =
            vm.selectedSoundPlaceType == place
            ? settings.soundPlaceType[0] : place
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
          .padding(.bottom, 5)
          
          TabViewList(
            source: settings.windDefenceType,
            selectedItem: vm.selectedSoundWindDefence,
            pageCount: 6,
            spacing: 5
          ) { defence in
            vm.selectedSoundWindDefence =
            vm.selectedSoundWindDefence == defence
            ? settings.windDefenceType[0] : defence
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
          
          DividerWithText(text: "select light type")
            .padding(.bottom, 5)
          
          TabViewList(
            source: settings.lightType,
            selectedItem: vm.selectedLight,
            pageCount: 6,
            spacing: 5
          ) { light in
            vm.selectedLight =
            vm.selectedLight == light ? settings.lightType[0] : light
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
            .padding(.bottom, 5)
          TabViewList(
            source: vm.availableUsers  //.map{$0 as Member}
              .compactMap { user in
                if user.id != vm.selectedUserId, let state {
                  return !state.units.contains(where: { unit in
                    unit.id == user.id
                  }) ? user : nil
                } else {
                  return user
                }
              },
            selectedItem: vm.availableUsers.first(where: { user in
              
              return user.id == vm.selectedUserId
            }),
            pageCount: 4,
            spacing: 5
          ) { user in
            vm.selectUser(user: user)
            
          } content: { user in
            SelectablePointEditCellWithContent(
              val: user,
              publishType: PointEditPublishType.user
            ) {
              PointEditUserCellView(
                name: user.viewCompactName,
                id: user.viewId
              )
            }
          }
          .frame(height: 150)
//          Spacer()
//        }
      }
      .padding(15)
      .scrollBounceBehavior(.basedOnSize)
    
      HStack {
        Button("Cancel") { dismiss() }
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 20)
        
        Button("Save") { vm.save(); dismiss() }
          .foregroundStyle(.green)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity)
      }
      .frame(height: 56)
      .background {
        RoundedRectangle(cornerRadius: 14)
          .fill(.ultraThinMaterial)
          .overlay {
            RoundedRectangle(cornerRadius: 14)
              .stroke(Color.white.opacity(0.5), lineWidth: 1)
          }
      }
      
      .padding(.horizontal, 15)
      .padding(.bottom, 8)
      
    }
    .presentationBackground {
      MainBackground()
    }
    .presentationDragIndicator(.visible)
    .environmentObject(vm)
  }
}
