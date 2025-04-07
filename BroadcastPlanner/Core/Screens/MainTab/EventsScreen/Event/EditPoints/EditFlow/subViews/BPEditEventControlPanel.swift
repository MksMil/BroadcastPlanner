import SwiftUI

struct BPEditEventControlPanel: View {
    
    let scaleUpAction: () -> Void
    let scaleDownAction: () -> Void
    let resetScaleAction: () -> Void

    var body: some View {
      RoundedRectangle(cornerRadius: 10)
            .fill(.white.opacity(0.4))
            .shadow(radius: 1)
            .frame(width: 130, height: 45)
            .overlay {
                HStack(spacing: 16){
                    
                    Button(action: {
                        scaleDownAction()
                    }, label: {
                        Image(systemName: "minus.magnifyingglass")
                    })
                    
                    Button(action: {
                        resetScaleAction()
                    }, label: {
                        Image(systemName: "square.arrowtriangle.4.outward")
                    })
                    
                    Button(action: {
                        scaleUpAction()
                    }, label: {
                        Image(systemName: "plus.magnifyingglass")
                    })
                    
                }
                .imageScale(.large)
            }
            .padding(.horizontal,5)
            .foregroundStyle(.black)
            .bold()
    }
}

#Preview {
    BPEditEventControlPanel(scaleUpAction: {},
                            scaleDownAction: {},
                            resetScaleAction: {})
}
