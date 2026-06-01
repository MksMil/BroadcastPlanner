import CoreData

public class Obvan: NSManagedObject {}

extension Obvan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Obvan> {
        return NSFetchRequest<Obvan>(entityName: "Obvan")
    }

    @NSManaged public var broadcaster: String?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var broadcasts: NSSet?
    @NSManaged public var crewTemplates: NSSet?
    @NSManaged public var image: LocalImage?
//    @NSManaged public var crews: NSSet?

}

// MARK: Generated accessors for broadcasts
extension Obvan {

    @objc(addBroadcastsObject:)
    @NSManaged public func addToBroadcasts(_ value: Broadcast)

    @objc(removeBroadcastsObject:)
    @NSManaged public func removeFromBroadcasts(_ value: Broadcast)

    @objc(addBroadcasts:)
    @NSManaged public func addToBroadcasts(_ values: NSSet)

    @objc(removeBroadcasts:)
    @NSManaged public func removeFromBroadcasts(_ values: NSSet)

}

// MARK: Generated accessors for crewTemplates
extension Obvan {

    @objc(addCrewTemplatesObject:)
    @NSManaged public func addToCrewTemplates(_ value: ObvanTemplateCrew)

    @objc(removeCrewTemplatesObject:)
    @NSManaged public func removeFromCrewTemplates(_ value: ObvanTemplateCrew)

    @objc(addCrewTemplates:)
    @NSManaged public func addToCrewTemplates(_ values: NSSet)

    @objc(removeCrewTemplates:)
    @NSManaged public func removeFromCrewTemplates(_ values: NSSet)

}

extension Obvan: ImageParent{
    func assignImage(image: LocalImage, ofType: GlobalProperties.ImageType) {
        if ofType == .obvan{
            self.image = image
            image.addToParentObvan(self)
        }
    }
}


// MARK: - Unwrapped + DTO
extension Obvan : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewName: String {
        name ?? ""
    }
    
    var viewBroadcasterName: String {
        broadcaster ?? "\"Roga AND Kopita\" co."
    }
    
    var viewBroadcasts: [Broadcast] {
        broadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    var viewImageId: String {
        image?.viewId ?? ""
    }
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }

    var viewTemplateCrews: [ObvanTemplateCrew] {
        return crewTemplates?.allObjects  as? [ObvanTemplateCrew] ?? []
    }
    
    var dto: ObvanDTO {
        ObvanDTO(id: viewId,
                 lastUpdated: viewLastUpdated,
                 name: viewName,
                 broadcaster: viewBroadcasterName,
                 obvanTemplateCrewDTOs: viewTemplateCrews.map{$0.dto})
    }
}

// MARK: - Update
extension Obvan: CoreDataUpdatable{
    //bg work
    func updateFromDTO(_ dto: ObvanDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.name = dto.name
        self.lastUpdated = dto.lastUpdated
        self.broadcaster = dto.broadcaster
        
        cleanTemplateCrews()
        dto.obvanTemplateCrewDTOs.forEach {
            let templateCrew = context.makeObjectFromDTO($0)
            addToCrewTemplates(templateCrew)
            templateCrew.parentObvan = self
        }
      
    }
    
    func updateWithValue(name: String? = nil,
                         broadcaster: String? = nil,
                         lastUpdated: Date = .now,
                         obvanSchema: LocalImage? = nil,
                         templateCrews: [ObvanTemplateCrew]? = nil,
                         in context: NSManagedObjectContext){
        if let name {
            self.name = name
        }
        
        if let broadcaster {
            self.broadcaster = broadcaster
        }
        
        self.lastUpdated = lastUpdated

        //old image continue to exist
        if let obvanSchema{
            if let image {
                image.removeFromParentObvan(self)
            }
            obvanSchema.addToParentObvan(self)
            self.image = obvanSchema
        }
 
        cleanTemplateCrews()
        
        if let templateCrews{
            templateCrews.forEach{
                addToCrewTemplates($0)
                $0.parentObvan = self
            }
        }
        viewBroadcasts.forEach{ $0.lastUpdated = .now }
    }
    
    func cleanTemplateCrews(){
        guard let context = self.managedObjectContext else { return }
        viewTemplateCrews.forEach{
            context.delete($0)}
    }
}

// MARK: - Remove (no scenario for now)
extension Obvan{
    public override func prepareForDeletion() {
        super.prepareForDeletion()
            //obvan image continue to exists, unlink
            if let image {
                image.removeFromParentObvan(self)
                self.image = nil
            }
            cleanTemplateCrews()
            viewBroadcasts.forEach {
                $0.cleanCrews(obvanId: id)
                $0.removeFromObvan(self)
                removeFromBroadcasts($0)
            }
    }
}
