import Foundation

//structure to generate directors group in broadcast obvan

struct OBVanUnit: Codable, Identifiable,BPDataProtocol{
    var id: String
    var position: UserSpecialization
    var coordinateX: Double
    var coordinateY: Double
    var rotation: Double
    var isEnabled: Bool = true
    var userId: String
    var hardwares: [Hardware]
}

// MARK: - map LocalUnit to OBVanUnit for firebase storage
extension OBVanUnit{
    static func mapToObvan(localUnit: LocalOBVanUnit) -> OBVanUnit{
        OBVanUnit(id: localUnit.viewId,
                  position: localUnit.viewPosition,
                  coordinateX: localUnit.viewX,
                  coordinateY: localUnit.viewY,
                  rotation: localUnit.viewRotation,
//                  isEnabled: true,
                  userId: localUnit.viewUserId,
                  hardwares: localUnit.viewHardware)
    }
}
