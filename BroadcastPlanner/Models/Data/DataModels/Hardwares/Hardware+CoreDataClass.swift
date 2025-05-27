import Foundation
import CoreData

public class Hardware: NSManagedObject {

}

extension Hardware {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hardware> {
        return NSFetchRequest<Hardware>(entityName: "Hardware")
    }

    @NSManaged public var channels: String?
    @NSManaged public var type: String?
    @NSManaged public var id: String?
    @NSManaged public var obvanUnit: Crew?

}

extension Hardware : Identifiable {

    var veiwId: String {
        id ?? ""
    }
    
    var viewType: ReplayType{
        ReplayType(rawValue: type ?? "") ?? ReplayType.none
    }
    var viewChannels: [String] {
        channels?.split(separator: ",") as? [String] ?? [String]()
    }
 
    var dto: HardwareDTO{
        HardwareDTO(id: veiwId,
                    envType: viewType,
                    chanels: viewChannels)
    }
}

extension Hardware: CoreDataUpdatable{
    func update(from dto: HardwareDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
        }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
         
     }
}
