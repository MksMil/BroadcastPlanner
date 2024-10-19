import Foundation

struct Broadcaster: Codable, Identifiable {
    var id: String { title }
    var title: String
    var obVans: [OBVan] = []
    var eventIds: [String] = []
}








