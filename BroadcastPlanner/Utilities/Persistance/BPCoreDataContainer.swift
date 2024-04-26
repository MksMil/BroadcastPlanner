//
//  BPCoreDataContainer.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 25.04.2024.
//

import Foundation
import CoreData

class BPCoreDataContainer {
    let persistanceConteiner: NSPersistentContainer
    
    init() {
        self.persistanceConteiner = NSPersistentContainer(name: "BPDataModel")
        self.persistanceConteiner.loadPersistentStores { _, _ in
        }
    }
    
    
    //for the tests
    init(forPreview: Bool = false){
        self.persistanceConteiner = NSPersistentContainer(name: "BPDataModel")
        if forPreview {
            persistanceConteiner.persistentStoreDescriptions.first!.url = URL(filePath: "/dev/null")
        }
        self.persistanceConteiner.loadPersistentStores { _, _ in
        }
    }
    
}

// MARK: - MockData
extension BPCoreDataContainer {
    func addMockData(moc: NSManagedObjectContext){
        let user = BPUser(
            id: "ViktorID",
            email: "Viktor@email.ua",
            firstName: "Viktor",
            creationDate: Date()
        )
    }
}
