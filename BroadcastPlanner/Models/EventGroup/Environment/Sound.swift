// MARK: - Mic
struct Sound: Codable, Identifiable {
    enum WindDefence: String, Codable,CaseIterable, Identifiable{
        case none = "---"
        case dog = "Dog"
        
        var id: Self { self }
    }
    
    enum PlaceType: String, Codable, CaseIterable, Identifiable{
        case none = "---"
        case onCamera = "On Camera"
        case low = "Low Tripod"
        case superLow = "Super Low Tripod"
        case high = "High Tripod"
        case superHigh = "Super High Tripod"
        
        var id: Self { self }
    }
    
    var id: String
    var windDefence: WindDefence = .none
    var placeType: PlaceType = .none
}
