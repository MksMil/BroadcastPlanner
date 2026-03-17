import SwiftUI

struct BPEditEventControlPanel: View {
    
    let scaleUpAction: () -> Void
    let scaleDownAction: () -> Void
    let resetScaleAction: () -> Void

    var body: some View {
        HStack{
                    
                    Button(action: {
                        scaleDownAction()
                    }, label: {
                        Image(systemName: "minus.magnifyingglass")
                    })
                    Spacer()
                    Button(action: {
                        resetScaleAction()
                    }, label: {
                        Image(systemName: "square.arrowtriangle.4.outward")
                    })
                    Spacer()
                    Button(action: {
                        scaleUpAction()
                    }, label: {
                        Image(systemName: "plus.magnifyingglass")
                    })
                    
                }
        .padding(.horizontal,10)
        .padding(.vertical,5)
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
                .imageScale(.large)
                .bold()
    }
}

#Preview {
    BPEditEventControlPanel(scaleUpAction: {},
                            scaleDownAction: {},
                            resetScaleAction: {})
}
