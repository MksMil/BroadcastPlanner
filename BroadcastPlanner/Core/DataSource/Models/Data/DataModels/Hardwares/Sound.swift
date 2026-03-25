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
    
    var viewPlaceType: String{
        placeType ?? "Empty"
    }
    
    var viewWindDefence: String {
        windDefence ?? "Empty"
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
        self.placeType = dto.placeType
        self.windDefence = dto.windDefence
    }
    
    func updateValues(placeType: String? = nil,
                      windDefence: String? = nil,
                      point: VenuePoint? = nil){
        if let placeType {
            self.placeType = placeType
        }
        if let windDefence {
            self.windDefence = windDefence
        }
    }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if point != nil {
            point?.sound = nil
            self.point = nil
        }
     }
}
