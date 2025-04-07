import Foundation

struct TemplatePoint: Identifiable, Codable,BPDataProtocol {
    var id: String
    
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    
    var cameras: [Camera]
    var sounds: [Sound]
    var lights: [Light]
    
    var number: Int
    var pointDescription: String
    var task : String
  
}

// MARK: - map to DTO
extension TemplatePoint {
    static func mapToTemplatePoint(localTemplatePoint: LocalTemplatePoint) -> TemplatePoint{
        TemplatePoint(
            id: localTemplatePoint.viewId,
            coordinateX: localTemplatePoint.viewX,
            coordinateY: localTemplatePoint.viewY,
            rotation: localTemplatePoint.viewRotation,
            scaleFactor: localTemplatePoint.viewScaleFactor,
            cameras: localTemplatePoint.viewCameras,
            sounds: localTemplatePoint.viewSounds,
            lights: localTemplatePoint.viewLights,
            number: localTemplatePoint.viewNumber,
            pointDescription: localTemplatePoint.viewPointDescription,
            task: localTemplatePoint.viewTask
        )
    }
}
