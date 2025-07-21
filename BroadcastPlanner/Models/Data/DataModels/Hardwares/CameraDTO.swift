import Foundation

// MARK: - Camera
struct CameraDTO: Codable,
                  Identifiable,
                  CoreDataRepresentable {
    
    typealias Entity = Camera
    var primaryKeyPredicate: NSPredicate { NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    var id: String
    var optic: String = "Empty"
    var lastUpdated: Date = .now
}

