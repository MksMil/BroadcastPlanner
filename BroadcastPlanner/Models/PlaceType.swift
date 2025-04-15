
 enum PlaceType: String, Codable, CaseIterable, Identifiable{
        case none = "---"
        case onCamera = "On Camera"
        case low = "Low Tripod"
        case superLow = "Super Low Tripod"
        case high = "High Tripod"
        case superHigh = "Super High Tripod"
        
        var id: Self { self }
    }
