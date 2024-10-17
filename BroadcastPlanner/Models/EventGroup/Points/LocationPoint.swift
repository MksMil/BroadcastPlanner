import Foundation

struct LocationPoint: Identifiable, Equatable,Hashable, Codable {
 
    var id: String
    var userId : String?
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var imageId: String
    
    var number: Int
    var description: String
    var task: String
    
    //id's
    var cameras: [Camera]
    var sounds: [Sound]
    var lights: [Light]
    
    
    
}
// MARK: - Hashable Equatable
extension LocationPoint {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LocationPoint, rhs: LocationPoint) -> Bool {
        lhs.id == rhs.id
    }

}










