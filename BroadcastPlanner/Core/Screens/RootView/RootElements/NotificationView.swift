

import SwiftUI
import Combine

struct NotificationView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var mdm: DataManager
    
    let source: [String] = ["Online","Error","Save complete","New message","New Event"]
    
    var body: some View {
        
        Text("Hello, World!")
    }
}

#Preview {
    NotificationView()
}
