// MARK: - Helper Codable Struct
struct GlobalSettingsArray: Codable {
    let values: [String]
}

// MARK: - DTO

struct GlobalSettingsArrayDTO: Codable, Identifiable {
    let id: String      // == key ("userSpecialization" и т.д.)
    let values: [String]
}
