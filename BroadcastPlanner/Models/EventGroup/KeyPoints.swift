import Foundation

struct KeyPoints: Identifiable ,Codable {
    struct Coordinates: Codable {
        var x: Double
        var y: Double
        var retation: Double
    }
    
    var id: String

    var title: String
    var points: [String: Coordinates]
    
    
}

extension KeyPoints: Hashable, Equatable {
    static func == (lhs: KeyPoints, rhs: KeyPoints) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
