import SwiftUI
import Combine

struct BackwardButton: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    
    @State private var isBackwardEnabled: Bool = false
    @State private var isBackwardVisible: Bool = false
    @State private var isDis: Bool = false
    var body: some View {
        Button {
            isDis = true
            appState.stepBackAction()
            makeEnabled()
        } label: {
            Image(systemName: "chevron.backward.circle")
                .font(.system(size: 50))
        }
        .offset(x: isBackwardVisible ? 0:-100)
        .disabled(!isBackwardEnabled)
        .disabled(isDis)
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
    private func makeEnabled(){
        Task{
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation{
                isDis = false
            }
        }
    }

}
