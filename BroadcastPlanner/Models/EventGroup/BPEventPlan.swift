import Foundation

class BPEventPlan: Identifiable, Codable {
    var id: String
    var background: String
    var points: [BPEventPlanPoint]
    
    init(id: String = "",
         background: String = "",
         points: [BPEventPlanPoint] = []) {
        self.id = id.isEmpty ? UUID().uuidString : id
        self.background = background
        self.points = points
    }
    
    // MARK: - MockData
    static let MockEventPlan = BPEventPlan(id: "123",
                                           points:[
                                            BPEventPlanPoint(
                                            id: "1",
                                            coordinates: BPEventPlanPointCoordinate(
                                                x: 0.25,
                                                y: 0.25),
                                            user: BPUser(firstName: "Yaroslav", lastName: "Konoplya")),
                                            BPEventPlanPoint(
                                             id: "2",
                                             coordinates: BPEventPlanPointCoordinate(
                                                 x: 0.5,
                                                 y: 0.5),
                                             user: BPUser(firstName: "Anatoliy", lastName: "Smoktunovskiy")),
                                            BPEventPlanPoint(
                                             id: "3",
                                             coordinates: BPEventPlanPointCoordinate(
                                                 x: 0.75,
                                                 y: 0.75),
                                             user: BPUser(firstName: "Viktor", lastName: "Kabkov")),
                                            BPEventPlanPoint(
                                             id: "4",
                                             coordinates: BPEventPlanPointCoordinate(
                                               x: 0.9,
                                                 y: 0.5),
                                             user: BPUser(firstName: "Aleksandr", lastName: "Chudnovskiy"))
                                           ])
}
