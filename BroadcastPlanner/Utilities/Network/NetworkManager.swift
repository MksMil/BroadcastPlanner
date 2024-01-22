import Foundation
import Firebase

class NetworkManager{
    static let shared = NetworkManager()
    
    let baseURL = "http://127.0.0.1:8080"
    
    func getEvents() -> [Event]{
        return [
            MockData.sampleEvent,
            MockData.sampleEvent,
            MockData.sampleEvent
        ]
    }
    
    func getUsers() -> [BPUser]{
        return MockData.sampleUsers
    }
    
    func getUser(id: UUID) -> BPUser {
        let resUser = BPUser()
        guard let url = URL(string: baseURL + "/user/id/\(id.uuidString)" ) else {
            //Error
            return resUser
        }
        
        guard let data = try? Data(contentsOf: url) else {
            //error
            return resUser
        }
        
        let jsonDecoder = JSONDecoder()
        
        guard let user = try? jsonDecoder.decode(BPUser.self, from: data) else {
            //error
            return resUser
        }
        return user
    }
    
    
}
