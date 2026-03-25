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
  @NSManaged public var obvanId: String?  //what am i want ???
  @NSManaged public var camera: Camera?
  @NSManaged public var broadcast: Broadcast?
  @NSManaged public var light: Light?
  @NSManaged public var sound: Sound?
  @NSManaged public var member: Member?

}

extension VenuePoint: ImageParent {
  func assignImage(image: LocalImage, ofType: GlobalProperties.ImageType) {

  }
}

extension VenuePoint: Identifiable {
  var viewId: String {
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
  var viewRotation: Double {
    Double(rotation)
  }

  var viewScaleFactor: Double {
    Double(scaleFactor)
  }

  var viewCameraId: String {
    camera?.viewId ?? ""
  }
  var viewSoundId: String {
    sound?.viewId ?? ""
  }

  var viewLightId: String {
    light?.viewId ?? ""
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

  var viewMemberId: String {
    member?.viewId ?? ""
  }

  //DTO
  var cameraDTO: CameraDTO? {
    if let camera {
      return CameraDTO(id: camera.viewId, optic: camera.viewOptic)
    } else {
      return nil
    }
  }
  var soundDTO: SoundDTO? {
    if let sound {
      return SoundDTO(
        id: sound.viewId,
        windDefence: sound.viewWindDefence,
        placeType: sound.viewPlaceType
      )
    } else {
      return nil
    }
  }
  var lightDTO: LightDTO? {
    if let light {
      return LightDTO(id: light.viewId, lightType: light.viewLightType)
    } else {
      return nil
    }
  }
  var dto: VenuePointDTO {
    VenuePointDTO(
      id: viewId,
      number: viewNumber,
      coordinateX: viewX,
      coordinateY: viewY,
      rotation: viewRotation,
      scaleFactor: viewScaleFactor,
      description: viewDescription,
      task: viewTask,
      imageId: viewImageId,
      obvanId: obvanId ?? "",
      memberId: viewMemberId,
      camera: cameraDTO,
      sound: soundDTO,
      light: lightDTO
    )
  }
}

// MARK: - Creation
extension VenuePoint {
  static func createWithBroadcast(
    _ broadcast: Broadcast,
    in context: NSManagedObjectContext
  ) -> VenuePoint {
    let id = UUID().uuidString
    let venuePoint = VenuePoint(context: context)
    venuePoint.id = id
    venuePoint.broadcast = broadcast
    return venuePoint
  }
}
// MARK: - CoreDataUpdatable + Update
extension VenuePoint: CoreDataUpdatable {
  //assign broadcast first, then updateDromDTO - critical
  func updateFromBroadcast(
    broadcast: Broadcast,
    venuePointDTO: VenuePointDTO,
    in context: NSManagedObjectContext
  ) {
    self.broadcast = broadcast
    updateFromDTO(venuePointDTO, in: context)
  }

  func updateFromDTO(
    _ dto: VenuePointDTO,
    in context: NSManagedObjectContext
  ) {
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
    self.camera = {
      guard let camDTO = $0 else { return nil }
      let camera = context.makeObjectFromDTO(camDTO)
      camera.point = self
      return camera
    }(dto.camera)
    //clean sounds
    sound = {
      guard let soundDTO = $0 else { return nil }
      let sound = context.makeObjectFromDTO(soundDTO)
      sound.point = self
      return sound
    }(dto.sound)
    //clean lights
    light = {
      guard let lightDTO = $0 else { return nil }
      let light = context.makeObjectFromDTO(lightDTO)
      light.point = self
      return light
    }(dto.light)
    //clean members

    member = {
      guard !$0.isEmpty else { return nil }
      let member: Member = context.fetchOrCreateObject(withID: $0)
      member.addToVenuePoints(self)
      return member
    }(dto.memberId)
  }

  func updateValues(
    number: Int? = nil,
    x: Double? = nil,
    y: Double? = nil,
    rotation: Double? = nil,
    scaleFactor: Double? = nil,
    pointDescription: String? = nil,
    task: String? = nil,
    image: LocalImage? = nil,
    obvanId: String? = nil,
    newCamera: Camera? = nil,
    broadcast: Broadcast? = nil,
    newSound: Sound? = nil,
    newLight: Light? = nil,
    newMember: Member? = nil,
    in context: NSManagedObjectContext
  ) {
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
    if let image {
      if let oldImage = self.image {
        oldImage.removeFromParentVenuePoint(self)
      }
      self.image = image
      image.addToParentVenuePoint(self)
    }
    if let obvanId {
      self.obvanId = obvanId
    }

    if let oldCam = self.camera {
      context.delete(oldCam)
    }
    self.camera = newCamera
    camera?.point = self

    if let oldSound = sound {
      context.delete(oldSound)
    }
    self.sound = newSound
    sound?.point = self

    if let light {
      context.delete(light)
    }
    light = newLight
    light?.point = self

    if member != newMember {
      if let member {
        member.removeFromVenuePoints(self)
      }
      member = newMember
      member?.addToVenuePoints(self)
    }
    if let broadcast {
      if let oldBroadcast = self.broadcast {
        oldBroadcast.removeFromVenuePoints(self)
      }
      self.broadcast = broadcast
      self.broadcast?.lastUpdated = .now
    }
  }

  public override func prepareForDeletion() {
    super.prepareForDeletion()

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

// MARK: - update from TemplatePoint
extension VenuePoint {

  func fromLayoutUnit(
    _ unit: LayoutRenderUnit,
    context: NSManagedObjectContext
  ) {
    context.performAndWait {
      number = Int16(unit.number ?? 0)
      coordinateX = Float(unit.coordinateX)
      coordinateY = Float(unit.coordinateY)
      rotation = Int16(unit.rotation)
      scaleFactor = Float(unit.scaleFactor)
      pointDescription = unit.description
      task = unit.task

      if let memberId = unit.personId{
        let member: Member = context.fetchOrCreateObject(withID: memberId)
        self.member = member
        member.addToVenuePoints(self)
      }
      
      if let cam = unit.camera{
        let camera: Camera = context.fetchOrCreateObject(
          withID: UUID().uuidString)
        camera.optic = cam
        camera.point = self
        self.camera = camera
      }
      if let unitSound = unit.sound{
        let sound: Sound = context.fetchOrCreateObject(
          withID: UUID().uuidString
        )
        sound.placeType = unitSound
        sound.point = self
        self.sound = sound
      }
      
      if let unitLight = unit.light{
        let light: Light = context.fetchOrCreateObject(
          withID: UUID().uuidString
        )
        light.lightType = unitLight
        light.point = self
        self.light = light
      }
}
  }

}
