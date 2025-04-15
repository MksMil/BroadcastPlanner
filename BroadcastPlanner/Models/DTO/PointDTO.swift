struct PointDTO: Identifiable, Codable,BPDataProtocol {
 
    var id: String
    var userId : [String]

    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var scale: Double

    var imageId: String
    
    var number: Int
    var description: String
    var task: String
    
    var cameras: [CameraDTO]
    var sounds: [SoundDTO]
    var lights: [LightDTO]
}










