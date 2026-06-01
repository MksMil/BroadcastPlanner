import SwiftUI

final class SelectableCellController: ObservableObject{
    @Published var selected: Bool = false
    func setSelect(_ select: Bool, tapped: Bool,completion: @escaping ()->Void = {}){
        if select, !selected{
            selected = true
        } else if select, selected,tapped{
            selected = false
            completion()
        }
        if !select, selected{
            selected = false
        }
    }
}
