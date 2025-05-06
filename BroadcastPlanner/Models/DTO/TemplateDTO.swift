import Foundation

struct TemplateDTO: Identifiable, Codable,BPDataProtocol {
    var id: String
    var lastUpdated: Date = .now
    
    var name: String
    var templatePoints: [TemplatePointDTO]
}
