import Foundation

class BPEventPlan: Identifiable, Codable {
    var id: String
    var title: String
    
    var background: String
    
    var fieldPoints: [BPEventPlanPoint]
    var carPoints: [BPEventPlanPoint]
    
    var fieldBackground: String
    var carBackground: String
    
    init(id: String = "",
         title: String = "example",
         background: String = "",
         fieldPoints: [BPEventPlanPoint] = [],
         carPoints: [BPEventPlanPoint] = [],
         fieldBackground: String = "",
         carBackground: String = "") {
        self.id = id.isEmpty ? UUID().uuidString : id
        self.title = title
        self.background = background
        self.fieldPoints = fieldPoints
        self.carPoints = carPoints
        self.fieldBackground = fieldBackground
        self.carBackground = carBackground
    }
    
}
