import Foundation

class KeyPoints: Identifiable ,Codable {
    var id: String

    var title: String
    var points: [String: BPEventPlanPointCoordinate]
    
    
    
    init(id: String = UUID().uuidString,
         title: String = "",
         points: [String : BPEventPlanPointCoordinate] = [:]) {
        self.id = id
        self.title = title
        self.points = points
    }
    
}

extension KeyPoints: Hashable, Equatable {
    static func == (lhs: KeyPoints, rhs: KeyPoints) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
