//import SwiftUI
//import Combine
//
//struct PimaryActionButton: View {
//    let height: Double = 60
//    @EnvironmentObject var router: Router
//    @EnvironmentObject var appState: ApplicationState
//    
//    @State private var isPrimaryEnabled: Bool = false
//    @State private var isPrimaryVisible: Bool = false
//    @State private var primaryIconName: String = "checkmark"
//    @State private var isDis: Bool = false
//    
//    var body: some View {
//        Button{
//            isDis = true
//            appState.primaryAction()
//            makeEnabled()
//        } label: {
//            Image(systemName: primaryIconName)
//                .resizable()
//                .scaledToFit()
//                .bold()
//                .padding(height / 4)
//                .frame(height: height)
//                .background {
//                    RoundedRectangle(cornerRadius: 5)
//                        .fill( .ultraThinMaterial.opacity(isPrimaryEnabled ? 0.5 : 0.3))
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 5)
//                                .stroke(.ultraThinMaterial.opacity(isPrimaryEnabled ? 0.5: 0.3),
//                                        lineWidth: 2)
//                        }
//                }
//                .fixedSize()
//            
//        }
//        .offset(x: isPrimaryVisible ? 0:100)
//        .disabled(!isPrimaryEnabled)
//        .disabled(isDis)
//        .onReceive(appState.isPrimaryButtonEnabledPublisher) { isEnabled in
//            if isPrimaryEnabled != isEnabled{
//                withAnimation{
//                    isPrimaryEnabled = isEnabled
//                }
//            }
//        }
//        .onReceive(appState.isPrimaryButtonVisiblePublisher) { isVisible in
//            if isPrimaryVisible != isVisible{
//                withAnimation(.easeInOut(duration: 0.5)){
//                    isPrimaryVisible = isVisible
//                }
//            }
//        }
//        .onReceive(appState.primaryIconPublisher) { icon in
//            if !isPrimaryVisible {
//                if primaryIconName != icon.rawValue{
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
//                        primaryIconName = icon.rawValue
//                    }
//                }
//            } else {
//                if primaryIconName != icon.rawValue{
//                    primaryIconName = icon.rawValue
//                }
//            }
//        }
//    }
//    private func makeEnabled(){
//        Task{
//            try? await Task.sleep(nanoseconds: 500_000_000)
//            withAnimation{
//                isDis = false
//            }
//        }
//    }
//}
