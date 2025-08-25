import SwiftUI

struct SelectableLocationCellWithContent<V: View, T: Equatable>: View {
    
    @EnvironmentObject var vm: AddEditVenueViewModel
    @StateObject var selectController: SelectableCellController = SelectableCellController()
    let val: T
    let publishType: LocationEditPublishType
    let content: ()->V
    
    var body: some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(5)
            .opacity(selectController.selected ? 1: 0.75)
            .scaleEffect(selectController.selected ? 1.0: 0.95)
            .onReceive(vm.publisher) { value in
                if value.0 == publishType, let selectedValue = value.1 as? T {
                    withAnimation{
                        selectController.setSelect(val == selectedValue,tapped: true){
                        }
                    }
                }
            }
            .onAppear {
                if let value = vm.selectedEventTemplate as? T, value == val{
                    selectController.setSelect(true, tapped: false)
                }
            }
    }
}

