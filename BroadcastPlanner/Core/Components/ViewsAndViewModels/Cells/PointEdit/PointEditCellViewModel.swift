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