import SwiftUI

///Структура для типичного блока кнопок accept/cancel  с внешними action's с вариантом кастомного вью между ними


struct ConfirmationButtonGroupView<T: View>: View {
    let height: Double
    @Binding var isAcceptDisabled: Bool
    let cancelAction: ()->Void
    let acceptAction: ()->Void
 
    @ViewBuilder var content: () -> T
        
    init(height: Double = 50,
         isAcceptDisabled: Binding<Bool>,
         cancelAction: @escaping () -> Void,
         acceptAction: @escaping () -> Void,
         content: (@escaping ()->T) = {EmptyView()} ) {
        self.height = height
        self.cancelAction = cancelAction
        self._isAcceptDisabled =  Binding(projectedValue: isAcceptDisabled)
        self.acceptAction = acceptAction
        self.content = content
    }
    
    var body: some View {
        HStack{
            Button {
                cancelAction()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .bold()
                    .padding(height / 4)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.red
                                .opacity(0.3))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color
                                        .red
                                        .opacity(0.5),
                                            lineWidth: 2)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            content()
                .frame(maxWidth: .infinity, alignment: .center)
            Button{
                acceptAction()
            } label: {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .bold()
                    .padding(height / 4)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isAcceptDisabled ? .gray.opacity(0.3) :.green.opacity(0.3))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isAcceptDisabled ?
                                            Color.gray.opacity(0.3) :Color.green.opacity(0.5),
                                            lineWidth: 2)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .disabled(isAcceptDisabled)
        }
        .frame(height: height)
        
    }
}

#Preview {
    ConfirmationButtonGroupView(height: 50,
                                isAcceptDisabled: .constant(false)) {
        
    } acceptAction: {
        
    } content: {
        Color.red
            .frame(maxWidth: .infinity)
            
    }


}


