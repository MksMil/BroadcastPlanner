import SwiftUI
import Combine

struct SecondaryActionButton: View {
    let height: Double = 60
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    @State private var isSecondaryEnabled: Bool = false
    @State private var isSecondaryVisible: Bool = false
    @State private var secondaryIconName: String = "trash"
    var body: some View {
        Button {
            appState.secondaryAction()
        } label: {
            Image(systemName: secondaryIconName)
                .resizable()
                .scaledToFit()
                .bold()
                .padding(height / 4)
                .frame(height: height)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill( .ultraThinMaterial.opacity(isSecondaryEnabled ? 0.5 : 0.3))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial.opacity(isSecondaryEnabled ? 0.5: 0.3),
                                        lineWidth: 2)
                        }
                }
                .fixedSize()
        }
        .offset(x: isSecondaryVisible ? 0:-100)
        .disabled(!isSecondaryEnabled)
        .onReceive(appState.isSecondaryButtonEnabledPublisher) { isEnabled in
            if isSecondaryEnabled != isEnabled{
                withAnimation{
                    isSecondaryEnabled = isEnabled
                }
            }
        }
        .onReceive(appState.isSecondaryButtonVisiblePublisher) { isVisible in
            if isSecondaryVisible != isVisible{
                withAnimation(.easeInOut(duration: 0.5)){
                    isSecondaryVisible = isVisible
                }
            }
        }
        .onReceive(appState.secondaryIconPublisher) { icon in
            if !isSecondaryVisible {
                if secondaryIconName != icon.rawValue{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        secondaryIconName = icon.rawValue
                    }
                }
            } else {
                if secondaryIconName != icon.rawValue{
                    secondaryIconName = icon.rawValue
                }
            }
        }
    }
}
