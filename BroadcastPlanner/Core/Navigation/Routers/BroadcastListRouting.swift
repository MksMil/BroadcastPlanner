
// BroadcastListRouting.swift
@MainActor
protocol BroadcastListRouting: AnyObject {
    func openBroadcast(_ broadcast: Broadcast)
    func openNewBroadcast(_ broadcast: Broadcast)
}

// Router уже соответствует — добавляем extension
extension Router: BroadcastListRouting {
    func openBroadcast(_ broadcast: Broadcast) {
        broadcastPath.append(.createEdit(broadcast: broadcast))
    }
    func openNewBroadcast(_ broadcast: Broadcast) {
        broadcastPath.append(.createEdit(broadcast: broadcast))
    }
}
