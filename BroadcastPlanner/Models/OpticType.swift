 enum OpticType: String, CaseIterable, Identifiable, Codable{
        case none = "---"
        case x14 = "x14"
        case x22 = "x22"
        case x40 = "x40"
        case x60 = "x60"
        case x75 = "x75"
        case x76 = "x76"
        case x86 = "x86"
        case x95 = "x95"
        case poleCam = "pole cam"
        case spider = "spider"
        case drone = "drone"
        case helic = "helicopter"
        case blackHawk = "Black Hawk"
        case Archer2 = "Archer 2"
        
        var id: Self { self }
    }
