import SwiftUI
import CoreData

public class VenuePoint: NSManagedObject {

}

extension VenuePoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VenuePoint> {
        return NSFetchRequest<VenuePoint>(entityName: "VenuePoint")
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
    @NSManaged public var broadcast: Broadcast?
    @NSManaged public var image: LocalImage?
    @NSManaged public var lights: NSSet?
    @NSManaged public var sounds: NSSet?
    @NSManaged public var members: NSSet?

}

// MARK: Generated accessors for cameras
extension VenuePoint {

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
extension VenuePoint {

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
extension VenuePoint {

    @objc(addSoundsObject:)
    @NSManaged public func addToSounds(_ value: Sound)

    @objc(removeSoundsObject:)
    @NSManaged public func removeFromSounds(_ value: Sound)

    @objc(addSounds:)
    @NSManaged public func addToSounds(_ values: NSSet)

    @objc(removeSounds:)
    @NSManaged public func removeFromSounds(_ values: NSSet)

}

// MARK: Generated accessors for members
extension VenuePoint {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: Member)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: Member)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}

extension VenuePoint : Identifiable {
    var viewId: String{
        id ?? ""
    }
    var viewNumber: Int {
        Int(number)
    }

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
    
    var viewCameras: [Camera]{
        cameras?.allObjects as? [Camera] ?? []
    }
    var viewSounds: [Sound] {
        sounds?.allObjects as? [Sound] ?? []
    }
    
    var viewLights: [Light] {
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
    
    var viewMembers: [Member]{
        (members?.allObjects as? [Member]) ?? []
    }
    
    var viewImage: Image {
        image?.smallImage ?? Image("cam1")
    }
    
    //DTO
    var cameraDTOs: [CameraDTO] {
        (cameras?.allObjects as? [Camera] ?? []).map{CameraDTO(id: $0.viewId, optic: $0.viewOptic)}
    }
    var soundDTOs: [SoundDTO] {
        (sounds?.allObjects as? [Sound] ?? []).map{SoundDTO(id: $0.viewId, windDefence: $0.viewWindDefence, placeType: $0.viewPlaceType)}
    }
    var lightDTOs: [LightDTO] {
        (lights?.allObjects as? [Light] ?? []).map{LightDTO(id: $0.viewId, lightType: $0.viewLightType)}
    }
    var dto: VenuePointDTO{
        VenuePointDTO(id: viewId,
                 memberIds: viewMembers.map{$0.viewId},
                 coordinateX: viewX,
                 coordinateY: viewY,
                 rotation: viewRotation.radians,
                 scale: viewScaleFactor,
                 imageId: viewImageId,
                 number: viewNumber,
                 description: viewDescription,
                 task: viewTask,
                 cameras: cameraDTOs,
                 sounds: soundDTOs,
                 lights: lightDTOs)
    }
}

extension VenuePoint: CoreDataUpdatable{
    func updateFromDTO(_ dto: VenuePointDTO) {
        if let context = self.managedObjectContext{
            self.id = dto.id
        }
    }
    
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            viewCameras.forEach{context.delete($0)}
            viewSounds.forEach{context.delete($0)}
            viewLights.forEach{context.delete($0)}
            //
            if let broadcast {
                viewMembers.forEach { broadcast.removeFromMembers($0)}
            }
        }
    }

}
