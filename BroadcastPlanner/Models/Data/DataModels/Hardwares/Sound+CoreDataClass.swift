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
    func update(from dto: SoundDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
        }
}
