import Foundation

struct ImageDTO: Codable, Identifiable, BPDataProtocol{
    var id: String
    var type: String
}
