import Foundation

struct Broadcaster: Codable, Identifiable,BPDataProtocol {
    var id: String 
    var title: String
    var obVans: [OBVan] = []
    var eventIds: [String] = []
}








