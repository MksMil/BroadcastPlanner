import SwiftUI
import CoreData

public class VenuePoint: NSManagedObject {

}

extension VenuePoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VenuePoint> {
        return NSFetchRequest<VenuePoint>(entityName: "VenuePoint")
    }

    @NSManaged public var id: String?
    @NSManaged public var number: Int16
    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var pointDescription: String?
    @NSManaged public var task: String?
    @NSManaged public var image: LocalImage?
    @NSManaged public var obvanId: String? //what am i want ???
    @NSManaged public var cameras: NSSet?
    @NSManaged public var broadcast: Broadcast?
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
                      number: viewNumber,
                      coordinateX: viewX,
                      coordinateY: viewY,
                      rotation: viewRotation.radians,
                      scaleFactor: viewScaleFactor,
                      description: viewDescription,
                      task: viewTask,
                      imageId: viewImageId,
                      obvanId: obvanId ?? "",
                      memberIds: viewMembers.map{$0.viewId},
                      cameras: cameraDTOs,
                      sounds: soundDTOs,
                      lights: lightDTOs)
    }
}

// MARK: - Creation
extension VenuePoint{
    static func createWithBroadcast(_ broadcast: Broadcast,
                                    in context: NSManagedObjectContext) -> VenuePoint{
        let id = UUID().uuidString
        let venuePoint = VenuePoint(context: context)
        venuePoint.id = id
        venuePoint.broadcast = broadcast
        return venuePoint
    }
}
// MARK: - CoreDataUpdatable + Update
extension VenuePoint: CoreDataUpdatable{
    //assign broadcast first, then updateDromDTO - critical
    func updateFromBroadcast(broadcast: Broadcast,
                             venuePointDTO: VenuePointDTO,
                             in context: NSManagedObjectContext){
        self.broadcast = broadcast
        updateFromDTO(venuePointDTO, in: context)
    }
    
    func updateFromDTO(_ dto: VenuePointDTO,
                       in context: NSManagedObjectContext) {
        self.id = dto.id
        self.number = Int16(dto.number)
        self.coordinateX = Float(dto.coordinateX)
        self.coordinateY = Float(dto.coordinateY)
        self.rotation = Int16(dto.rotation)
        self.scaleFactor = Float(dto.scaleFactor)
        self.pointDescription = dto.description
        self.task = dto.task
        self.obvanId = dto.obvanId
        //clean cameras
        cleanCameras(in: context)
        dto.cameras.forEach{
            let camera = context.makeObjectFromDTO($0)
            addToCameras(camera)
            camera.point = self
        }
        //clean sounds
        cleanSounds(in: context)
        dto.sounds.forEach{
            let sound = context.makeObjectFromDTO($0)
            addToSounds(sound)
            sound.point = self
        }
        //clean lights
        cleanLights(in: context)
        dto.lights.forEach{
            let light = context.makeObjectFromDTO($0)
            addToLights(light)
            light.point = self
        }
        //clean members
        cleanMembers(in: context)
        dto.memberIds.forEach{
            let member: Member = context.fetchOrCreateObject(withID: $0)
            addToMembers(member)
            member.addToVenuePoints(self)
        }
    }
    
    func updateValues(number: Int?  = nil,
                      x:Double? = nil,
                      y:Double? = nil,
                      rotation: Double? = nil,
                      scaleFactor: Double? = nil,
                      pointDescription: String? = nil,
                      task: String? = nil,
                      image: LocalImage? = nil,
                      obvanId: String? = nil,
                      cameras: [Camera]? = nil,
                      broadcast: Broadcast? = nil,
                      sounds: [Sound]? = nil,
                      lights: [Light]? = nil,
                      members: [Member]? = nil,
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
        if let rotation {
            self.rotation = Int16(rotation)
        }
        if let scaleFactor {
            self.scaleFactor = Float(scaleFactor)
        }
        if let pointDescription {
            self.pointDescription = pointDescription
        }
        if let task {
            self.task = task
        }
        if let image{
            if let oldImage = self.image{
                oldImage.removeFromParentVenuePoint(self)
            }
            self.image = image
            image.addToParentVenuePoint(self)
        }
        if let obvanId {
            self.obvanId = obvanId
        }
        if let cameras {
            cleanCameras(in: context)
            cameras.forEach{
                $0.point = self
                addToCameras($0)
            }
        }
        if let sounds {
            cleanSounds(in: context)
            sounds.forEach{
                $0.point = self
                addToSounds($0)
            }
        }
        if let lights {
            cleanLights(in: context)
            lights.forEach{
                $0.point = self
                addToLights($0)
            }
        }
        if let members {
            cleanMembers(in: context)
            members.forEach{
                $0.addToVenuePoints(self)
                addToMembers($0)
            }
        }
        if  let broadcast {
            if let oldBroadcast = self.broadcast{
                oldBroadcast.removeFromVenuePoints(self)
            }
            self.broadcast = broadcast
            self.broadcast?.lastUpdated = .now
        }
    }
    
    func cleanCameras(in context: NSManagedObjectContext){
        viewCameras.forEach{
            removeFromCameras($0)
            context.delete($0)
        }
    }
    func cleanSounds(in context: NSManagedObjectContext){
        viewSounds.forEach{
            removeFromSounds($0)
            context.delete($0)
        }
    }
    
    func cleanLights(in context: NSManagedObjectContext){
        viewLights.forEach{
            removeFromLights($0)
            context.delete($0)
        }
    }
    func cleanMembers(in context: NSManagedObjectContext){
        viewMembers.forEach{
            $0.removeFromVenuePoints(self)
            removeFromMembers($0)
        }
    }
    
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            cleanCameras(in: context)
            cleanSounds(in: context)
            cleanLights(in: context)
            cleanMembers(in: context)
            if let broadcast {
                broadcast.removeFromVenuePoints(self)
                self.broadcast = nil
            }
            if let image {
                image.removeFromParentVenuePoint(self)
                self.image = nil
            }
        }
    }

}

// MARK: - update from TemplatePoint
extension VenuePoint {
    
    func fromTemplaPoint(_ templatePoint: TemplatePoint, context: NSManagedObjectContext){
        context.performAndWait{
            number = templatePoint.number
            coordinateX = templatePoint.coordinateX
            coordinateY = templatePoint.coordinateY
            rotation = templatePoint.rotation
            scaleFactor = templatePoint.scaleFactor
            pointDescription = templatePoint.pointDescription
            task = templatePoint.task
            
            templatePoint.cameraDTOs.forEach{
                let camera: Camera = context.fetchOrCreateObject(withID: UUID().uuidString)
                camera.updateFromDTO($0, in: context)
                addToCameras(camera)
            }
            
            templatePoint.soundDTOs.forEach{
                let sound: Sound = context.fetchOrCreateObject(withID: UUID().uuidString)
                sound.updateFromDTO($0, in: context)
                addToSounds(sound)
            }
            
            templatePoint.lightDTOs.forEach{
                let light: Light = context.fetchOrCreateObject(withID: UUID().uuidString)
                light.updateFromDTO($0, in: context)
                addToLights(light)
            }
        }
    }
    
}

//@NSManaged public var id: String? -
//@NSManaged public var number: Int16 +
//@NSManaged public var coordinateX: Float +
//@NSManaged public var coordinateY: Float +
//@NSManaged public var rotation: Int16 +
//@NSManaged public var scaleFactor: Float +
//@NSManaged public var pointDescription: String? +
//@NSManaged public var task: String? +
//@NSManaged public var image: LocalImage?
//@NSManaged public var imageString: String? //what am i want ???
//@NSManaged public var cameras: NSSet?
//@NSManaged public var broadcast: Broadcast?
//@NSManaged public var lights: NSSet?
//@NSManaged public var sounds: NSSet?
//@NSManaged public var members: NSSet?
