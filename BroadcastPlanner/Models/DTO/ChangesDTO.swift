import Foundation
import Firebase


enum ChangesType: String, Codable{
    case update, remove
}

struct ChangesDTO: Codable, Identifiable {
    let id: String
    let changesType: ChangesType
    let timestamp: Timestamp
    
    let type: String
    let changesId: String
    
    //if updateCounter == users.count -> removeChanges()
    var updateCounter: Int
    
}
