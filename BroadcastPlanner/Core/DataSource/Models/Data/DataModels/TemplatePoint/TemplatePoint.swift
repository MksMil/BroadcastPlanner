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
    @NSManaged public var camera: String?
    @NSManaged public var sound: String?
    @NSManaged public var light: String?
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
    
  var cameraDTO: CameraDTO? {
    if let camera {
      return CameraDTO(id: UUID().uuidString,
                       optic: camera)
    } else {
      return nil
    }
  }
    //to dto map helper
    var soundDTO: SoundDTO? {
        if let sound {
            return SoundDTO(id: UUID().uuidString,placeType: sound)
        } else {
          return nil
        }
    }
    //to dto map helper
    var lightDTO: LightDTO? {
        
        if let light {
            return LightDTO(id: UUID().uuidString,
                                      lightType: light)
        } else {
          return nil
        }
        
    }
    
    var dto: TemplatePointDTO{
        TemplatePointDTO(
            id: viewId,
            coordinateX: viewX,
            coordinateY: viewY,
            rotation: viewRotation,
            scaleFactor: viewScaleFactor,
            camera: cameraDTO,
            sound: soundDTO,
            light: lightDTO,
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
        camera = venuePoint.camera?.viewOptic
        sound = venuePoint.sound?.viewPlaceType
        light = venuePoint.light?.viewLightType
    }
  func fromUnit(_ unit: BluePrintEditable){
      number = Int16(unit.number ?? 0)
    coordinateX = Float(unit.coordinateX)
    coordinateY = Float(unit.coordinateY)
    scaleFactor = Float(unit.scaleFactor)
    rotation = Int16(unit.rotation)
      task = nil
      pointDescription = nil
      camera = unit.camera
      sound = unit.sound
      light = unit.light
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
        self.camera = dto.camera?.optic
        self.sound = dto.sound?.placeType
        self.light = dto.light?.lightType
    }
    
    func updateValues(number: Int? = nil,
                      x:Double? = nil,
                      y:Double? = nil,
                      scaleFactor: Double? = nil,
                      rotation: Int? = nil,
                      task: String? = nil,
                      pointDescription: String? = nil,
                      camera: Camera? = nil,
                      sound: Sound? = nil,
                      light: Light? = nil,
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
        
        if let camera {
            self.camera = camera.viewOptic
        }
        if let sound {
            self.sound = sound.viewPlaceType
        }
        if let light {
            self.light = light.viewLightType
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
