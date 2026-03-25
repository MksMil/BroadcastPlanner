import Foundation
import Combine


// MARK: - GlobalSettings Delegate Protocol
protocol GlobalSettingsDelegate: AnyObject {
    func updateGlobalSettingsArray(name: String, values: [String])
}

class GlobalSettings: ObservableObject, Codable {
    // MARK: - Properties
    @Published var userSpecialization: [String] = [
        "Producer",
        "Floor manager",
        "Main director",
        "Director",
        "Main cameramen",
        "Cameramen",
        "Replay director",
        "Replay operator",
        "Main sound director",
        "Sound director",
        "Graphics operator",
        "Unknown"
    ]
    
    @Published var cameraPosition: [String] = [
        "Unknown",
        "Main Match Camera Wide Angle",
        "Main Close Up",
        "Pitch Central Ring",
        "Left Behind Goal",
        "Right Behind Goal",
        "Reverse Central lower tier",
        "Right High behind goal",
        "left offside",
        "right offside",
        "Left Behind Goal Mirror",
        "Left PoleCam",
        "Goal LHS left",
        "Goal LHS right",
        "Left High behind goal",
        "Right Behind Goal Mirror",
        "Right PoleCam",
        "Goal RHS left",
        "Goal RHS right",
        "Reverse Central upper tier",
        "Second Reverse Central upper tier",
        "Second Reverse Central lower tier",
        "left pitch",
        "right pitch",
        "Stedicam Left Side",
        "Stedicam Right Side",
        "Reverse stedicam Left Side",
        "Reverse stedicam Right Side",
        "Upper left Beauty Shot",
        "Upper right Beauty Shot",
        "Lower left Beauty Shot",
        "Lower right Beauty Shot",
        "Helicopter",
        "Drone",
        "Left goal line",
        "Right goal line",
        "Spider cam",
        "Team arrivals",
        "Flash interview",
        "Dressing room",
        "Press conference",
        "Tunell cam"
    ]
    
    @Published var opticType: [String] = [
        "Empty",
        "x14",
        "x22",
        "x40",
        "x60",
        "x75",
        "x76",
        "x86",
        "x95",
        "pole cam",
        "spider",
        "drone",
        "helicopter",
        "Black Hawk",
        "Archer 2",
        "Unknown"
    ]
    
    @Published var soundPlaceType: [String] = [
        "Empty",
        "On Camera",
        "Low Tripod",
        "Super Low Tripod",
        "High Tripod",
        "Super High Tripod",
        "Unknown"
    ]
    
    @Published var windDefenceType: [String] = [
        "Empty",
        "Dog",
        "Unknown"
    ]
    
    @Published var lightType: [String] = [
        "Empty",
        "Unknown"
    ]
    
    @Published var hardwareType: [String] = [
        "Empty",
        "EVS",
        "K2-DYNO",
        "BLT",
        "SLOMO",
        "V-MIX",
        "Unknown"
    ]
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case userSpecialization
        case cameraPosition
        case opticType
        case soundPlaceType
        case windDefenceType
        case lightType
        case hardwareType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userSpecialization, forKey: .userSpecialization)
        try container.encode(cameraPosition, forKey: .cameraPosition)
        try container.encode(opticType, forKey: .opticType)
        try container.encode(soundPlaceType, forKey: .soundPlaceType)
        try container.encode(windDefenceType, forKey: .windDefenceType)
        try container.encode(lightType, forKey: .lightType)
        try container.encode(hardwareType, forKey: .hardwareType)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userSpecialization = try container.decode([String].self, forKey: .userSpecialization)
        cameraPosition = try container.decode([String].self, forKey: .cameraPosition)
        opticType = try container.decode([String].self, forKey: .opticType)
        soundPlaceType = try container.decode([String].self, forKey: .soundPlaceType)
        windDefenceType = try container.decode([String].self, forKey: .windDefenceType)
        lightType = try container.decode([String].self, forKey: .lightType)
        hardwareType = try container.decode([String].self, forKey: .hardwareType)
    }
    
    // MARK: - Initialization
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - UserDefaults Methods
    private static let userDefaultsKey = "GlobalSettings"
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            UserDefaults.standard.set(data, forKey: GlobalSettings.userDefaultsKey)
        } catch {
            print("Failed to save GlobalSettings to UserDefaults: \(error)")
        }
    }
    
    func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: GlobalSettings.userDefaultsKey) else {
            // Если данных нет, сохраняем текущие значения как начальные
            saveToUserDefaults()
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let loadedSettings = try decoder.decode(GlobalSettings.self, from: data)
            self.userSpecialization = loadedSettings.userSpecialization
            self.cameraPosition = loadedSettings.cameraPosition
            self.opticType = loadedSettings.opticType
            self.soundPlaceType = loadedSettings.soundPlaceType
            self.windDefenceType = loadedSettings.windDefenceType
            self.lightType = loadedSettings.lightType
            self.hardwareType = loadedSettings.hardwareType
        } catch {
            print("Failed to load GlobalSettings from UserDefaults: \(error)")
            // Сохраняем текущие значения в случае ошибки
            saveToUserDefaults()
        }
    }
    
    // MARK: - Auto-Save Setup
    private var cancellables = Set<AnyCancellable>()
    
    private func setupAutoSave() {
        Publishers.MergeMany(
            $userSpecialization,
            $cameraPosition,
            $opticType,
            $soundPlaceType,
            $windDefenceType,
            $lightType,
            $hardwareType
        )
        .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.saveToUserDefaults()
            //TODO: updated notification?
        }
        .store(in: &cancellables)
    }
}

// MARK: - GlobalSettingsDelegate
extension GlobalSettings: GlobalSettingsDelegate {
     func updateGlobalSettingsArray(name: String, values: [String]) {
         switch name {
         case "userSpecialization": self.userSpecialization = values
         case "cameraPosition": self.cameraPosition = values
         case "opticType": self.opticType = values
         case "soundPlaceType": self.soundPlaceType = values
         case "windDefenceType": self.windDefenceType = values
         case "lightType": self.lightType = values
         case "hardwareType": self.hardwareType = values
         default: break
         }
         saveToUserDefaults()
     }
}

extension GlobalSettings {
    func values(forKey key: String) -> [String] {
        switch key {
        case "userSpecialization": return userSpecialization
        case "cameraPosition":     return cameraPosition
        case "opticType":          return opticType
        case "soundPlaceType":     return soundPlaceType
        case "windDefenceType":    return windDefenceType
        case "lightType":          return lightType
        case "hardwareType":       return hardwareType
        default:
            assertionFailure("GlobalSettings: unknown key '\(key)'")
            return []
        }
    }
}


