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
    func update(from dto: TemplatePointDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
        }
}
