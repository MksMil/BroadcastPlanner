import SwiftUI

struct AddUnitFormCell: View {
    enum AddUnitFormState {
        case selected //visible
        case unselected // 0.5 visible
        case noSelection // all cells visible
    }
    
    let text: String
    let state: AddUnitFormState
    
    var body: some View {
        Text(text)
            .foregroundStyle(.black)
            .fixedSize()
            .frame(width:  150, height: 25)
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: 5).fill(.white)
            }
            .opacity(state == .unselected ? 0.3: 1)
    }
}
