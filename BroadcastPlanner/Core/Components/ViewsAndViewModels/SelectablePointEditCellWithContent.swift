struct SelectablePointEditCellWithContent<V: View, T: Equatable>: View {
    @EnvironmentObject var vm: PointInfoPanelViewModel
    @StateObject var selectController: PointEditCellViewModel = PointEditCellViewModel()
    let val: T
    let publishType: GlobalProperties.PublishChanges
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
                if value.0 == publishType, let selectedUser = value.1 as? T {
                    selectController.setSelect(val == selectedUser)
                }
            }
    }
}
