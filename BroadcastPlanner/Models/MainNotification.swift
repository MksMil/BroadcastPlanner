import Foundation


struct StatusViewNotification: Identifiable,Equatable {
    var id: UUID
    let text: String
    let cycle: CycleType
    let route: RouterPath = .broadcastList
}
