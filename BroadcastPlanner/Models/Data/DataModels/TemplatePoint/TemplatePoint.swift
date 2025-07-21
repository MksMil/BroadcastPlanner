import Foundation
import CoreData

public class TemplatePoint: NSManagedObject {}

extension TemplatePoint {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplatePoint> {
        return NSFetchRequest<TemplatePoint>(entityName: "TemplatePoint")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var number: Int16
    @NSManaged public var pointDescription: String?
    @NSManaged public var task: String?
    @NSManaged public var scaleFactor: Float
    @NSManaged public var rotation: Int16
    @NSManaged public var id: String?
    @NSManaged public var cameras: String?
    @NSManaged public var sounds: String?
    @NSManaged public var lights: String?
    @NSManaged public var parentTemplate: Template?

}

// MARK: - Unwrapped + DTO
extension TemplatePoint : Identifiable {
    var viewId: String {
        id ?? ""
    }
    
    var viewX: Double {
        Double(coordinateX)
    }
    
    var viewY: Double {
        Double(coordinateY)
    }
    
    var viewNumber: Int {
        Int(number)
    }
    
    var viewPointDescription: String {
        pointDescription ?? ""
    }
    
    var viewTask: String {
        task ?? ""
    }
    
    var viewScaleFactor: Double{
        Double(scaleFactor)
    }
    
    var viewRotation: Double {
        Double(rotation)
    }
    
    //to dto map helper
    var cameraDTOs: [CameraDTO] {
        var array = [CameraDTO]()
        if let cameras {
            let results = cameras.split(separator: ",").map{String($0)}
            for result in results {
                array.append(CameraDTO(id: UUID().uuidString,
                                       optic: result))
            }
        }
        return array
    }
    //to dto map helper
    var soundDTOs: [SoundDTO] {
        var array = [SoundDTO]()
        if let sounds {
            let results = sounds.split(separator: ",").map{String($0)}
            for result in results {
                array.append(SoundDTO(id: UUID().uuidString,placeType: result))
            }
        }
        return array
    }
    //to dto map helper
    var lightDTOs: [LightDTO] {
        var array = [LightDTO]()
        if let lights {
            let results = lights.split(separator: ",").map{String($0)}
            for result in results {
                array.append(LightDTO(id: UUID().uuidString,
                                      lightType: result))
            }
        }
        return array
    }
    
    var dto: TemplatePointDTO{
        TemplatePointDTO(
            id: viewId,
            coordinateX: viewX,
            coordinateY: viewY,
            rotation: viewRotation,
            scaleFactor: viewScaleFactor,
            cameras: cameraDTOs,
            sounds: soundDTOs,
            lights: lightDTOs,
            number: viewNumber,
            pointDescription: viewPointDescription,
            task: viewTask
        )
    }
}


// MARK: - Update
extension TemplatePoint: CoreDataUpdatable{
    
    func fromVenuePoint(_ venuePoint: VenuePoint){
        number = venuePoint.number
        coordinateX = venuePoint.coordinateX
        coordinateY = venuePoint.coordinateY
        scaleFactor = venuePoint.scaleFactor
        rotation = venuePoint.rotation
        task = venuePoint.task
        pointDescription = venuePoint.pointDescription
        cameras = venuePoint.viewCameras.map{$0.viewOptic}.joined(separator: ",")
        sounds = venuePoint.viewSounds.map{$0.viewPlaceType}.joined(separator: ",")
        lights = venuePoint.viewLights.map{$0.viewLightType}.joined(separator: ",")
    }
    
    //bg work
    func updateFromDTO(_ dto: TemplatePointDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.number = Int16(dto.number)
        self.coordinateX = Float(dto.coordinateX)
        self.coordinateY = Float(dto.coordinateY)
        self.scaleFactor = Float(dto.scaleFactor)
        self.rotation = Int16(dto.rotation)
        self.task = dto.task
        self.pointDescription = dto.pointDescription
        self.cameras = dto.cameras.map{$0.optic}.joined(separator: ",")
        self.sounds = dto.sounds.map{$0.placeType}.joined(separator: ",")
        self.lights = dto.lights.map{$0.lightType}.joined(separator: ",")
    }
    
    func updateValues(number: Int? = nil,
                      x:Double? = nil,
                      y:Double? = nil,
                      scaleFactor: Double? = nil,
                      rotation: Int? = nil,
                      task: String? = nil,
                      pointDescription: String? = nil,
                      cameras: [Camera]? = nil,
                      sounds: [Sound]? = nil,
                      lights: [Light]? = nil,
                      in context: NSManagedObjectContext){
        if let number {
            self.number = Int16(number)
        }
        
        if let x {
            self.coordinateX = Float(x)
        }
        if let y {
            self.coordinateY = Float(y)
        }
        if let scaleFactor {
            self.scaleFactor = Float(scaleFactor)
        }
        if let rotation {
            self.rotation = Int16(rotation)
        }
        if let task {
            self.task = task
        }
        if let pointDescription{
            self.pointDescription = pointDescription
        }
        
        if let cameras {
            self.cameras = cameras.map{$0.viewOptic}.joined(separator: ",")
        }
        if let sounds {
            self.sounds = sounds.map{$0.viewPlaceType}.joined(separator: ",")
        }
        if let lights {
            self.lights = lights.map{$0.viewLightType}.joined(separator: ",")
        }
        parentTemplate?.lastUpdated = .now
    }
}

// MARK: - Remove
extension TemplatePoint{
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if let parentTemplate {
            parentTemplate.removeFromTemplatePoints(self)
        }
        parentTemplate = nil
     }
}
