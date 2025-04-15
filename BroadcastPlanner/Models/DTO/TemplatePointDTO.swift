
struct TemplatePointDTO: Identifiable, Codable,BPDataProtocol {
    var id: String
    
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scaleFactor: Double
    
    var cameras: [CameraDTO]
    var sounds: [SoundDTO]
    var lights: [LightDTO]
    
    var number: Int
    var pointDescription: String
    var task : String
  
}
