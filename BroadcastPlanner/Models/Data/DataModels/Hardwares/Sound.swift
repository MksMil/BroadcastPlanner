import Foundation
import CoreData


public class Sound: NSManagedObject {

}

extension Sound {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sound> {
        return NSFetchRequest<Sound>(entityName: "Sound")
    }

    @NSManaged public var placeType: String?
    @NSManaged public var windDefence: String?
    @NSManaged public var id: String?
    @NSManaged public var point: VenuePoint?

}

extension Sound : Identifiable {
    var viewId: String {
        id ?? ""
    }
    
    var viewPlaceType: PlaceType{
        PlaceType(rawValue: placeType ?? "---") ?? PlaceType.none
    }
    
    var viewWindDefence: WindDefence {
        WindDefence(rawValue: windDefence ?? "---") ?? WindDefence.none
    }
    
    var dto: SoundDTO{
        SoundDTO(id: viewId,
                 windDefence: viewWindDefence,
                 placeType: viewPlaceType)
    }
}

extension Sound: CoreDataUpdatable{
    func updateFromDTO(_ dto: SoundDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.placeType = dto.placeType.rawValue
        self.windDefence = dto.windDefence.rawValue
    }
    
    func updateValues(placeType: PlaceType? = nil,
                      windDefence: WindDefence? = nil,
                      point: VenuePoint? = nil){
        if let placeType {
            self.placeType = placeType.rawValue
        }
        if let windDefence {
            self.windDefence = windDefence.rawValue
        }
        if let point {
            if let oldPoint = self.point{
                oldPoint.removeFromSounds(self)
            }
            self.point = point
        }
    }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if point != nil {
            self.point = nil
        }
     }
}
