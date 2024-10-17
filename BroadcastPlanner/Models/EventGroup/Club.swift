import UIKit

struct Club: Codable, Hashable, Identifiable{
    let id: String
    var title: String
    var contacts: String = ""
    var urlString: String = ""
    var imageLogoID: String
    var homeLocationID: String
    
}

extension Club: Equatable{
    static func == (lhs: Club, rhs: Club) -> Bool {
        lhs.id == rhs.id
    }
}
