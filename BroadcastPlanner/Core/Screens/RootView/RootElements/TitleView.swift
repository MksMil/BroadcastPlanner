import SwiftUI
import Combine

struct TitleView: View {
    
    @EnvironmentObject var appState: ApplicationState
    
    @State private var title: String = "Hello"
    
    var body: some View {
        Text(title)
            .font(.title)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .onReceive(appState.titlePublisher) { newTitle in
                    title = newTitle
            }
            .frame(height: 30)
    }
}

#if DEBUG
#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
        .environmentObject(Router())
}
#endif
