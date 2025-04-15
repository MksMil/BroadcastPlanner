struct ObvanDTO: Codable, Identifiable,BPDataProtocol {
    var id: String
    var name: String
    var imageId: String
    var broadcasterId: String
}
