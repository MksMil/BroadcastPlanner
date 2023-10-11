import SwiftUI

struct MainTabView: View {
    
    var storage: Storage = Storage(cameras: [])
    
    var body: some View {
        TabView {
            EventMainView(viewModel: EventMainViewModel(cameras: storage.cameras))
                .tabItem { Label("Cams", systemImage: "video") }
            Text("Users Here")
                .tabItem { Label("User", systemImage: "person.crop.circle") }
        }
        .environmentObject(storage)
        .task {
            storage.users = NetworkManager.shared.getUsers()
            
        }
    }
}

#Preview {
    MainTabView()
}
