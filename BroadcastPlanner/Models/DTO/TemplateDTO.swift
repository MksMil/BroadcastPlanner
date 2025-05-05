import Foundation

struct TemplateDTO: Identifiable, Codable,BPDataProtocol {
    var id: String
    var lastUpdated: Date
    
    var name: String
    var templatePoints: [TemplatePointDTO]
}
