import Foundation

struct LocationPoint: Identifiable, Equatable,Hashable, Codable,BPDataProtocol {
 
    var id: String
    var userId : [String]

    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
//    var scale: Double

    var imageId: String
    
    var number: Int
    var description: String
    var task: String
    
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

// MARK: - map from LocalLocationPoint
extension LocationPoint{
    static func mapToLocationPoint(localPoint: LocalLocationPoint) -> LocationPoint{
        LocationPoint(id: localPoint.viewId,
                      userId: localPoint.viewUsers.map{$0.userId},
                      coordinateX: localPoint.viewX,
                      coordinateY: localPoint.viewY,
                      rotation: localPoint.viewRotation,
                      imageId: localPoint.viewImageId,
                      number: localPoint.viewNumber,
                      description: localPoint.viewDescription,
                      task: localPoint.viewTask,
                      cameras: localPoint.viewCameras,
                      sounds: localPoint.viewSounds,
                      lights: localPoint.viewLights)
        
        
    }
}










