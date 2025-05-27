import Foundation

struct TemplateDTO: Identifiable, Codable,BPDataProtocol,CoreDataRepresentable {
    
    typealias Entity = Template
    var primaryKeyPredicate: NSPredicate {
        NSPredicate(format: "id == %@", id as CVarArg)
    }
    var id: String
    var lastUpdated: Date = .now
    
    var name: String
    var templatePoints: [TemplatePointDTO]
}
