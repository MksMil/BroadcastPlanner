
 enum WindDefence: String, Codable,CaseIterable, Identifiable{
        case none = "---"
        case dog = "Dog"
        
        var id: Self { self }
    }
