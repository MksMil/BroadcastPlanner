import SwiftUI

struct SelectableLocationCellWithContent<V: View, T: Equatable>: View {
    
    @EnvironmentObject var vm: AddEditLocationViewModel
    @StateObject var selectController: SelectableCellController = SelectableCellController()
    let val: T
    let publishType: LocationEditPublishType
    let content: ()->V
    
    var body: some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8).stroke(selectController.selected ?  Color.white:Color.clear, lineWidth: 4).blur(radius: 2)
            }
            .onReceive(vm.publisher) { value in
                if value.0 == publishType, let selectedValue = value.1 as? T {
                    selectController.setSelect(val == selectedValue,tapped: true){
                    }
                }
            }
    }
}

