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
    @NSManaged public var crew: Crew?

}

extension Hardware : Identifiable {

    var veiwId: String {
        id ?? ""
    }
    
    var viewType: HardwareType{
        HardwareType(rawValue: type ?? "") ?? HardwareType.none
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
    func updateFromDTO(_ dto: HardwareDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.type = dto.envType.rawValue
        self.channels = dto.chanels.joined(separator: ", ")
    }
    
    func updateValues(type: HardwareType? = nil,
                      channels: [String]? = nil,
                      crew: Crew? = nil){
        if let type {
            self.type = type.rawValue
        }
        if let channels {
            self.channels = channels.joined(separator: ", ")
        }
        if let crew {
            if let oldCrew = self.crew{
                oldCrew.hardware = nil
            }
            self.crew = crew
        }
    }
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if crew != nil {
            self.crew = nil
        }
     }
}
