import Foundation
import Firebase

// MARK: - Message
struct Message: Identifiable, Codable,BPDataProtocol  {
   
    var id: String
    var messageOwnerId: String
    var body: MessageBody
    var creationDate: Timestamp
    
}

// MARK: - MessageBody
struct MessageBody: Codable {
    var images: [String]? //URL string
    var text: String?
    var video: [String]? //URL string
    var audio: [String]?  //URL string
}


// MARK: - Message Hashsable&Equatable
extension Message: Hashable, Equatable{
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(messageOwnerId)
        hasher.combine(creationDate)
        let _ = hasher.finalize()
    }
}
