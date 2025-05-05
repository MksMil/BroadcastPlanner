import SwiftUI
import CoreData

public class LocationPoint: NSManagedObject {

}

extension LocationPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationPoint> {
        return NSFetchRequest<LocationPoint>(entityName: "LocationPoint")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var imageString: String?
    @NSManaged public var number: Int16
    @NSManaged public var pointDescription: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var task: String?
    @NSManaged public var scaleFactor: Float
    @NSManaged public var cameras: NSSet?
    @NSManaged public var event: Event?
    @NSManaged public var image: LocalImage?
    @NSManaged public var lights: NSSet?
    @NSManaged public var sounds: NSSet?
    @NSManaged public var user: NSSet?

}

// MARK: Generated accessors for cameras
extension LocationPoint {

    @objc(addCamerasObject:)
    @NSManaged public func addToCameras(_ value: Camera)

    @objc(removeCamerasObject:)
    @NSManaged public func removeFromCameras(_ value: Camera)

    @objc(addCameras:)
    @NSManaged public func addToCameras(_ values: NSSet)

    @objc(removeCameras:)
    @NSManaged public func removeFromCameras(_ values: NSSet)

}

// MARK: Generated accessors for lights
extension LocationPoint {

    @objc(addLightsObject:)
    @NSManaged public func addToLights(_ value: Light)

    @objc(removeLightsObject:)
    @NSManaged public func removeFromLights(_ value: Light)

    @objc(addLights:)
    @NSManaged public func addToLights(_ values: NSSet)

    @objc(removeLights:)
    @NSManaged public func removeFromLights(_ values: NSSet)

}

// MARK: Generated accessors for sounds
extension LocationPoint {

    @objc(addSoundsObject:)
    @NSManaged public func addToSounds(_ value: Sound)

    @objc(removeSoundsObject:)
    @NSManaged public func removeFromSounds(_ value: Sound)

    @objc(addSounds:)
    @NSManaged public func addToSounds(_ values: NSSet)

    @objc(removeSounds:)
    @NSManaged public func removeFromSounds(_ values: NSSet)

}

// MARK: Generated accessors for user
extension LocationPoint {

    @objc(addUserObject:)
    @NSManaged public func addToUser(_ value: LocalUser)

    @objc(removeUserObject:)
    @NSManaged public func removeFromUser(_ value: LocalUser)

    @objc(addUser:)
    @NSManaged public func addToUser(_ values: NSSet)

    @objc(removeUser:)
    @NSManaged public func removeFromUser(_ values: NSSet)

}

extension LocationPoint : Identifiable {

    var viewX: Double {
        Double(coordinateX)
    }
    
    var viewY: Double {
        Double(coordinateY)
    }
    var viewRotation: Angle{
        Angle(degrees: Double(rotation))
    }

    var viewScaleFactor: Double{
        Double(scaleFactor)
    }
    var viewId: String{
        id ?? ""
    }
    
    var viewNumber: Int {
        Int(number)
    }
    
    var viewCameras: [CameraDTO] {
        (cameras?.allObjects as? [Camera] ?? []).map{CameraDTO(id: $0.viewId, optic: $0.viewOptic)}
    }
    
    var viewLocalCameras: [Camera]{
        cameras?.allObjects as? [Camera] ?? []
    }
    
    var viewSounds: [SoundDTO] {
        (sounds?.allObjects as? [Sound] ?? []).map{SoundDTO(id: $0.viewId, windDefence: $0.viewWindDefence, placeType: $0.viewPlaceType)}
    }
    
    var viewLocalSounds: [Sound] {
        sounds?.allObjects as? [Sound] ?? []
    }
    
    var viewLights: [LightDTO] {
        (lights?.allObjects as? [Light] ?? []).map{LightDTO(id: $0.viewId, lightType: $0.viewLightType)}
    }
    
    var viewLocalLights: [Light] {
        lights?.allObjects as? [Light] ?? []
    }

    
    var viewImageId: String {
        image?.id ?? ""
    }
    
    var viewDescription: String {
        pointDescription ?? "Choose position"
    }
    
    var viewTask: String {
        task ?? "no task"
    }
    
    var viewUsers: [LocalUser]{
        (user?.allObjects as? [LocalUser]) ?? []
    }
    
    var viewImage: Image {
        image?.smallImage ?? Image("cam1")
    }
    
    var dto: PointDTO{
        PointDTO(id: viewId,
                 userId: viewUsers.map{$0.viewId},
                 coordinateX: viewX,
                 coordinateY: viewY,
                 rotation: viewRotation.radians,
                 scale: viewScaleFactor,
                 imageId: viewImageId,
                 number: viewNumber,
                 description: viewDescription,
                 task: viewTask,
                 cameras: viewCameras,
                 sounds: viewSounds,
                 lights: viewLights)
    }
}
