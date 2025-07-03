import SwiftUI
import Combine

struct BackwardButton: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    
    @State private var isBackwardEnabled: Bool = false
    @State private var isBackwardVisible: Bool = false
    var body: some View {
        Button {
            
        } label: {
            Image(systemName: "chevron.backward.circle")
                .font(.system(size: 50))
        }
        .offset(x: isBackwardVisible ? 0:-100)
        .disabled(!isBackwardEnabled)
        .onReceive(appState.isBacwardButtonEnabledPublisher) { enable in
            withAnimation {
                if isBackwardEnabled != enable{
                    isBackwardEnabled = enable
                }
            }
        }
        .onReceive(appState.isBackwardButtonVisiblePublisher) { visible in
                withAnimation {
                if isBackwardVisible != visible{
                    isBackwardVisible = visible
                }
            }
        }
    }
}
