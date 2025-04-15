//
//  LocalTemplate+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 24.01.2025.
//
//

import Foundation
import CoreData


extension LocalTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalTemplate> {
        return NSFetchRequest<LocalTemplate>(entityName: "LocalTemplate")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var templatePoints: NSSet?

}

// MARK: Generated accessors for templatePoints
extension LocalTemplate {

    @objc(addTemplatePointsObject:)
    @NSManaged public func addToTemplatePoints(_ value: LocalTemplatePoint)

    @objc(removeTemplatePointsObject:)
    @NSManaged public func removeFromTemplatePoints(_ value: LocalTemplatePoint)

    @objc(addTemplatePoints:)
    @NSManaged public func addToTemplatePoints(_ values: NSSet)

    @objc(removeTemplatePoints:)
    @NSManaged public func removeFromTemplatePoints(_ values: NSSet)

}

extension LocalTemplate : Identifiable {

    var viewId: String {
        id ?? ""
    }
    
    var viewName: String{
        name ?? ""
    }
    
    var viewPoints: [LocalTemplatePoint]{
        templatePoints?.allObjects as? [LocalTemplatePoint] ?? []
    }
    
    var dto: TemplateDTO{
        TemplateDTO(id: viewId,
                    name: viewName,
                    templatePoints: viewPoints.map{$0.dto})
    }
}
