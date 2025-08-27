import SwiftUI
import Combine

struct TitleView: View {
    
    @EnvironmentObject var appState: ApplicationState
    
    @State private var title: String = "Hello"
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .onReceive(appState.titlePublisher) { newTitle in
                    title = newTitle
            }
            .frame(height: 30)
            .padding(.horizontal,8)
    }
}

