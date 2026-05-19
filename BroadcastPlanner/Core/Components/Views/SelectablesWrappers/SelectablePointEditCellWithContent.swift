import SwiftUI
// wrapper to reduce selectupdate render
struct SelectablePointEditCellWithContent<V: View, T: Equatable>: View {
    @EnvironmentObject var vm: UnitEditViewModel
    @StateObject var selectController: SelectableCellController = SelectableCellController()
    let val: T
    let publishType: PointEditPublishType
    let content: ()->V
    
    var body: some View {
      RoundedRectangle(cornerRadius: 8)
          .fill(selectController.selected ? .ultraThinMaterial : Material.ultraThin)
          .overlay {
              RoundedRectangle(cornerRadius: 8)
                  .stroke(
                      selectController.selected ? Color.primary.opacity(0.7) : Color.primary.opacity(0.1),
                      lineWidth: selectController.selected ? 2 : 0.5
                  )
          }
          .overlay { content() }
            .onReceive(vm.publisher) { value in
                if value.0 == publishType, let selectedValue = value.1 as? T {
                    selectController.setSelect(val == selectedValue,tapped: true){
                        switch publishType {
                            case .optic:
                                vm.selectedCameraOptic = "Empty"
                                vm.publisher.send((PointEditPublishType.optic, "Empty"))
                            case .windDefence:
                                vm.selectedSoundWindDefence = "Empty"
                                vm.publisher.send((PointEditPublishType.windDefence, "Empty"))
                            case .placeType:
                                vm.selectedSoundPlaceType = "Empty"
                                vm.publisher.send((PointEditPublishType.placeType, "Empty"))
                            case .light:
                                vm.selectedLight = "Empty"
                                vm.publisher.send((PointEditPublishType.light, "Empty"))
                            default: return
                        }
                    }
                }
            }
            .onAppear{
                switch publishType {
                    case .number:
                        if vm.number == val as? Int{
                            selectController.setSelect(true, tapped: false)
                        }
                    case .user:
                    if vm.selectedUserId == (val as? Member)?.id{
                            selectController.setSelect(true,tapped: false)
                        }
                    case .optic:
                        if vm.selectedCameraOptic == val as? String{
                            selectController.setSelect(true,tapped: false)
                        }
                        
                    case .windDefence:
                        if vm.selectedSoundWindDefence == val as? String{
                            selectController.setSelect(true,tapped: false)
                        }
                    case .placeType:
                        if vm.selectedSoundPlaceType == val as? String{
                            selectController.setSelect(true,tapped: false)
                        }
                    case .light:
                        if vm.selectedLight == val as? String{
                            selectController.setSelect(true,tapped: false)
                        }
                }
            }
    }
}
