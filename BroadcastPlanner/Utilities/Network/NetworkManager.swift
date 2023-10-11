import Foundation

class NetworkManager{
    static let shared = NetworkManager()
    
    func getEvents() -> [Event]{
        return [
            MockData.sampleEvent,
            MockData.sampleEvent,
            MockData.sampleEvent
        ]
    }
    
    func getUsers() -> [User]{
        return MockData.sampleUsers
    }
}
