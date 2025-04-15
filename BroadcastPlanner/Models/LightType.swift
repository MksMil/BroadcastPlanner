enum LightType: String, CaseIterable, Identifiable, Codable{
        case none = "---"
        case light = "some Light"
        
        var id: Self { self }
    }
