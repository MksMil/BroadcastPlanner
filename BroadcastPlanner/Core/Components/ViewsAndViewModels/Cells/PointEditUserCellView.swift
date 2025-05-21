import SwiftUI
import Combine

struct PointEditUserCellView: View {
    @StateObject var selectController = PointEditCellViewModel()
    @EnvironmentObject var vm: PointInfoPanelViewModel
    let user: LocalUser
    
    var body: some View {
        VStack{
            user.viewImage
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .border(.blue, width: 1)
            Text(user.viewCompactName)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .border(.orange, width: 1)
        }
        .background(content: {
            Color.randomColor()
        })
        .padding(5)
        .border(selectController.selected ?  .blue:.gray, width: 2)
        .onReceive(vm.publisher) { value in
            if value.0 == .users, let selectedUser = value.1 as? LocalUser{
                selectController.setSelect(user == selectedUser)
            }
        }
    }
}

final class PointEditCellViewModel: ObservableObject{
    @Published var selected: Bool = false
    func setSelect(_ select: Bool){
        if select, !selected{
            selected = true
        }
        if !select, selected{
            selected = false
        }
    }
    
}
