import SwiftUI


struct StatusViewNotification: Identifiable,Equatable {
    var id: UUID
    let text: String
    let textColor: Color
    let cycle: CycleType
//    let route: RouterPath = .broadcastList
    
}

// MARK: - Helper
extension StatusViewNotification{
    static func random() -> StatusViewNotification {
        let random = StatusViewNotification(id: UUID(),
                                            text: "\(Int.random(in: 1...10))",
                                            textColor: [Color.primary, Color.secondary, Color.brown].randomElement()!,
                                            cycle: Bool.random() ? .once:.loop)
        return random
    }
    
}
