struct SoundDTO: Codable, Identifiable,BPDataProtocol {
 
    var id: String
    var windDefence: WindDefence = .none
    var placeType: PlaceType = .none
}
