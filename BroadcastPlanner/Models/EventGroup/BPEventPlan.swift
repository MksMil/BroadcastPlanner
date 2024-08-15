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
    
    // MARK: - MockData
//    static let MockEventPlan = BPEventPlan(id: "123",
//                                           fieldPoints:[
//                                            BPEventPlanPoint(
//                                            id: "1",
//                                            coordinates: BPEventPlanPointCoordinate(
//                                                x: 0.25,
//                                                y: 0.25),
//                                            user: BPUser(firstName: "Yaroslav", lastName: "Konoplya")),
//                                            BPEventPlanPoint(
//                                             id: "2",
//                                             coordinates: BPEventPlanPointCoordinate(
//                                                 x: 0.5,
//                                                 y: 0.5),
//                                             user: BPUser(firstName: "Anatoliy", lastName: "Smoktunovskiy")),
//                                            BPEventPlanPoint(
//                                             id: "3",
//                                             coordinates: BPEventPlanPointCoordinate(
//                                                 x: 0.75,
//                                                 y: 0.75),
//                                             user: BPUser(firstName: "Viktor", lastName: "Kabkov")),
//                                            BPEventPlanPoint(
//                                             id: "4",
//                                             coordinates: BPEventPlanPointCoordinate(
//                                               x: 0.9,
//                                                 y: 0.5),
//                                             user: BPUser(firstName: "Aleksandr", lastName: "Chudnovskiy"))
//                                           ],
//                                           carPoints: [
//                                            BPEventPlanPoint(
//                                            id: "5",
//                                            coordinates: BPEventPlanPointCoordinate(
//                                                x: 0.25,
//                                                y: 0.25),
//                                            user: BPUser(firstName: "Oleg", lastName: "Fedorok")),
//                                            BPEventPlanPoint(
//                                             id: "6",
//                                             coordinates: BPEventPlanPointCoordinate(
//                                                 x: 0.5,
//                                                 y: 0.5),
//                                             user: BPUser(firstName: "Mikhail", lastName: "Zaborskiy")),
//                                            BPEventPlanPoint(
//                                             id: "7",
//                                             coordinates: BPEventPlanPointCoordinate(
//                                                 x: 0.75,
//                                                 y: 0.75),
//                                             user: BPUser(firstName: "Garry", lastName: "Vitalievich")),
//                                            BPEventPlanPoint(
//                                             id: "8",
//                                             coordinates: BPEventPlanPointCoordinate(
//                                               x: 0.9,
//                                                 y: 0.5),
//                                             user: BPUser(firstName: "Volodya", lastName: "KUM"))
//                                           ])
}
