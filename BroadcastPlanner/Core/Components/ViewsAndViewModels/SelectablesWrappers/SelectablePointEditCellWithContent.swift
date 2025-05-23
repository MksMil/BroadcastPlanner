import SwiftUI
// wrapper to reduce selectupdate render
struct SelectablePointEditCellWithContent<V: View, T: Equatable>: View {
    @EnvironmentObject var vm: PointInfoPanelViewModel
    @StateObject var selectController: SelectableCellController = SelectableCellController()
    let val: T
    let publishType: PointEditPublishType
    let content: ()->V
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8).fill(selectController.selected ?  .white.opacity(0.4):.clear)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.5), lineWidth: 1)
            })
            .overlay(content: {
                content()
            })
            .onReceive(vm.publisher) { value in
                if value.0 == publishType, let selectedValue = value.1 as? T {
                    selectController.setSelect(val == selectedValue,tapped: true){
                        switch publishType {
                            case .optic:
                                vm.selectedCameraOptic = .none
                                vm.publisher.send((PointEditPublishType.optic, OpticType.none))
                            case .windDefence:
                                vm.selectedSoundWindDefence = .none
                                vm.publisher.send((PointEditPublishType.windDefence, WindDefence.none))
                            case .placeType:
                                vm.selectedSoundPlaceType = .none
                                vm.publisher.send((PointEditPublishType.placeType, PlaceType.none))
                            case .light:
                                vm.selectedLight = .none
                                vm.publisher.send((PointEditPublishType.light, LightType.none))
                            default: return
                        }
                    }
                }
            }
            .onAppear{
                switch publishType {
                    case .number:
                        if vm.number == val as? Int{
                            print("number check in selectable cell")
                            selectController.setSelect(true, tapped: false)
                        }
                    case .user:
                        if vm.selectedUser == val as? LocalUser{
                            selectController.setSelect(true,tapped: false)
                        }
                    case .optic:
                        if vm.selectedCameraOptic == val as? OpticType{
                            selectController.setSelect(true,tapped: false)
                        }
                        
                    case .windDefence:
                        if vm.selectedSoundWindDefence == val as? WindDefence{
                            selectController.setSelect(true,tapped: false)
                        }
                    case .placeType:
                        if vm.selectedSoundPlaceType == val as? PlaceType{
                            selectController.setSelect(true,tapped: false)
                        }
                    case .light:
                        if vm.selectedLight == val as? LightType{
                            selectController.setSelect(true,tapped: false)
                        }
                }
            }
    }
}
