import Foundation

class Stadium: Codable{
    var title: String
    var city: String
    var address: String
    
    init(title: String, city: String, address: String) {
        self.title = title
        self.city = city
        self.address = address
    }
}
