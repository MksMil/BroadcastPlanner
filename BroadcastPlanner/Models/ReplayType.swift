enum ReplayType: String, Codable, CaseIterable, Identifiable{
        var id: Self { self }
        
        case none = "---"
        case evs = "EVS"
        case k2 = "K2-DYNO"
        case blt = "BLT"
        case slomo = "SLOMO"
        case vmix = "V-MIX"
        
        static var withoutEmpty: [ReplayType]{
            ReplayType.allCases.compactMap{
                switch $0 {
                    case .none: return nil
                    default: return $0
                }
            }
        }
    }
