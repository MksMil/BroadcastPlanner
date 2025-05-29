import Foundation
import CoreData

public class TemplatePoint: NSManagedObject {

}

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
    var viewCameras: [CameraDTO] {
        var array = [CameraDTO]()
        if let cameras {
          let results = cameras.split(separator: ",")
            for result in results {
                if let optic = OpticType(rawValue: String(result)){
                    array.append(CameraDTO(id: UUID().uuidString,
                                        optic: optic))
                }
            }
        }
        return array
    }
    //to dto map helper
    var viewSounds: [SoundDTO] {
        var array = [SoundDTO]()
        if let sounds {
            let results = sounds.split(separator: ",")
            for result in results {
                if let placeType = PlaceType(rawValue: String(result)){
                    array.append(SoundDTO(id: UUID().uuidString,placeType: placeType))
                }
            }
        }
        return array
    }
    //to dto map helper
    var viewLights: [LightDTO] {
        var array = [LightDTO]()
        if let lights {
            let results = lights.split(separator: ",")
            for result in results {
                if let lightType = LightType(rawValue: String(result)){
                    array.append(LightDTO(id: UUID().uuidString,
                                       lightType: lightType))
                }
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
            cameras: viewCameras,
            sounds: viewSounds,
            lights: viewLights,
            number: viewNumber,
            pointDescription: viewPointDescription,
            task: viewTask
        )
    }
}

extension TemplatePoint: CoreDataUpdatable{
    func updateFromDTO(_ dto: TemplatePointDTO, in context: NSManagedObjectContext) {
                self.id = dto.id
                self.number = Int16(dto.number)
                self.coordinateX = Float(dto.coordinateX)
                self.coordinateY = Float(dto.coordinateY)
                self.scaleFactor = Float(dto.scaleFactor)
                self.rotation = Int16(dto.rotation)
                self.task = dto.task
                self.pointDescription = dto.pointDescription
                self.cameras = dto.cameras.map{$0.optic.rawValue}.joined(separator: ", ")
                self.sounds = dto.sounds.map{$0.placeType.rawValue}.joined(separator: ", ")
                self.lights = dto.lights.map{$0.lightType.rawValue}.joined(separator: ", ")
    }
    
    func updateValues(number: Int?,x:Double?,y:Double?,
                      scaleFactor: Double?,rotation: Int?,
                      task: String?,pointDescription: String?,
                      cameras: [Camera]?, sounds: [Sound]?,lights: [Light]?,
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
            self.cameras = cameras.map{$0.viewOptic.rawValue}.joined(separator: ", ")
        }
        if let sounds {
            self.sounds = sounds.map{$0.viewPlaceType.rawValue}.joined(separator: ", ")
        }
        if let lights {
            self.lights = lights.map{$0.viewLightType.rawValue}.joined(separator: ", ")
        }
    }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        
     }
}
