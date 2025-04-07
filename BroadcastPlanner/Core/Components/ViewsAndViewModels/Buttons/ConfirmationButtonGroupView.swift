import SwiftUI

///Структура для типичного блока кнопок accept/cancel  с внешними action's с вариантом кастомного вью между ними


struct ConfirmationButtonGroupView<T: View>: View {
    let height: Double
    let isAcceptDisabled: Bool
    let cancelAction: ()->Void
    let acceptAction: ()->Void
 
    @ViewBuilder var content: () -> T
        
    init(height: Double = 50,
         isAcceptDisabled: Bool,
         cancelAction: @escaping () -> Void,
         acceptAction: @escaping () -> Void,
         content: (@escaping ()->T) = {EmptyView()} ) {
        self.height = height
        self.cancelAction = cancelAction
        self.isAcceptDisabled = isAcceptDisabled
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
                    .frame(height: height)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThickMaterial
                                .opacity(0.3))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        .ultraThickMaterial
                                        .opacity(0.5),
                                            lineWidth: 2)
                            }
                    }
            }
            .fixedSize()
            content()
                .frame(height: height)
                .frame(maxWidth: .infinity, alignment: .center)
            Button{
                acceptAction()
            } label: {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .bold()
                    .padding(height / 4)
                    .frame(height: height)

                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.4))//isAcceptDisabled ? .ultraThinMaterial.opacity(0.3) : .ultraThinMaterial.opacity(0.5))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.white.opacity(0.4),//isAcceptDisabled ?
//                                        .ultraThinMaterial.opacity(0.3) :.ultraThinMaterial.opacity(0.5),
                                            lineWidth: 2)
                            }
                    }
                    .fixedSize()
            }
            .disabled(isAcceptDisabled)
        }
//        .frame(height: height)
        
    }
}

#Preview {
    ConfirmationButtonGroupView(height: 60,
                                isAcceptDisabled: false) {
        
    } acceptAction: {
        
    } content: {
        Color.gray
            .frame(maxWidth: .infinity)
            
    }


}


