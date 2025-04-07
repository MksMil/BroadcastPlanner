import SwiftUI

struct CarUnitEnableCellView: View {
    
    @State var position: String
    @State var isEnabled: Bool
    
    let action: ()->Void
    
    var body: some View {
        HStack{
            Text(position)
            Spacer()
            Button(action: {
                action()
                isEnabled.toggle()
            }, label: {
                Image(systemName: isEnabled ? "checkmark":"xmark")
                    .foregroundStyle(isEnabled ? .green:.red)
            })
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.4))
        }
    }
}

#Preview {
    CarUnitEnableCellView(position: "director", isEnabled: true, action: {})
}
