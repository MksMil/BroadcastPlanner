import Foundation

struct Broadcaster: Codable, Identifiable {
    var id: String { title }
    var title: String
    var obVanIds: [String] = []
    var eventIds: [String] = []
}








