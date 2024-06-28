import Foundation

final class BPUserProfileViewModel: ObservableObject {
    var user: BPUserLocalData
    weak var globalStorage: GlobalStorage?
    
    init(user: BPUserLocalData) {
        self.user = user
    }
}
