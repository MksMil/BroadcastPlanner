import UIKit

protocol BluePrintEditable: AnyObject, BluePrintVisualRepresentable, BluePrintEditMovable {}

protocol BluePrintEditMovable {
  var id: String {get set}
  //geometry
  var coordinateX: CGFloat {get set}
  var coordinateY: CGFloat {get set}
  var scaleFactor: CGFloat{get set}
  var rotation: CGFloat {get set}
}

protocol BluePrintVisualRepresentable{
  //visual
  var number: Int?      {get set}
  var position: String? { get set}
  var firstName: String?{ get set}
  var lastName: String? { get set}
  var personId: String? {get set}
  var camera: String?   {get set}
  var sound: String?    {get set}
  var light: String?    {get set}
  var hardware: String?  {get set}
  
  var task: String? {get set}
  var description: String? {get set}
  var image: UIImage? {get set}
}

class LayoutRenderUnit: Identifiable, Hashable, BluePrintEditable{
  var id: String
  
  //geometry
  var coordinateX: CGFloat
  var coordinateY: CGFloat
  var scaleFactor: CGFloat
  var rotation: CGFloat
  
  //visual
  var number: Int?
  var position: String?
  var firstName: String?
  var lastName: String?
  var personId: String?
  var camera: String?
  var sound: String?
  var light: String?
  var hardware: String?
  
  var task: String?
  var description: String?
  var image: UIImage?
  init(
    id: String,
    coordinateX: CGFloat,
    coordinateY: CGFloat,
    scaleFactor: CGFloat,
    rotation: CGFloat,
    number: Int?,
    position: String? = "",
    firstName: String? = "",
    lastName: String? = "",
    personId: String?,
    camera: String?,
    sound: String?,
    light: String?,
    hardware: String?,
    task: String?,
    description: String?,
    image: UIImage? = nil
  ) {
    self.id = id
    self.coordinateX = coordinateX
    self.coordinateY = coordinateY
    self.scaleFactor = scaleFactor
    self.rotation = rotation
    self.number = number
    self.position = position
    self.firstName = firstName
    self.lastName = lastName
    self.personId = personId
    self.camera = camera
    self.sound = sound
    self.light = light
    self.hardware = hardware
    self.task = task
    self.description = description
    self.image = image
  }
  
  // Hashable
     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
     
     // Equatable — требуется для Hashable
     static func == (lhs: LayoutRenderUnit, rhs: LayoutRenderUnit) -> Bool {
         lhs.id == rhs.id
     }
 
}
