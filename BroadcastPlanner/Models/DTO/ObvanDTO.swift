import Foundation

struct ObvanDTO: Codable, Identifiable,BPDataProtocol {
    var id: String
    var lastUpdated: Date = .now
    var name: String
    var imageId: String
    var broadcaster: String
}
