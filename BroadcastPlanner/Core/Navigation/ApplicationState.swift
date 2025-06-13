import SwiftUI

enum AppState {
    case authorized, notAuthorized
}

enum UserOnlineStatus {
    case online, offline
}

class ApplicationState: ObservableObject{
    @Published var state: AppState = .notAuthorized
    @Published var userOnlineStatus: UserOnlineStatus = .offline
}
