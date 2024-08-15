import Foundation


struct Chat: Identifiable, Codable {
    
    var id: String
    
    var users: [String]
    var superUsers: [String]
    
    var messages: [Message]
    var newMessages: [Message]
}
