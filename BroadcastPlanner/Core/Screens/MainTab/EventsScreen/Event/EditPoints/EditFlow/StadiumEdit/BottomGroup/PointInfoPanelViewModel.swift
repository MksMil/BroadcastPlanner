import Combine
import SwiftUI




final class PointInfoPanelViewModel: ObservableObject {
    // MARK: - vm Properties

    var number: Int = 0
    
    var availableNumbers: [Int] {
        var nums: [Int] = []
        if let event = point.event{
            nums = event.viewLocationPoints.map{$0.viewNumber}
        }
        var result = Array(1...50)
        result.removeAll { number in
            nums.contains(number)
        }
        return result
    }
    
    
    var position: CameraPosition = .pitchSideHalfWay

    var selectedUser: LocalUser?
    var selectedCameraOptic: OpticType = .none
    var selectedSoundPlaceType: PlaceType = .none
    var selectedSoundWindDefence: WindDefence = .none
    var selectedLight: LightType = .none

    var publisher: PassthroughSubject = PassthroughSubject<
        (PointInfoPublishType, Any), Never
    >()

    let point: LocationPoint

    // MARK: - vm init
    init(point: LocationPoint) {
        self.point = point
        if let user = point.viewUsers.first {
            selectedUser = user
        }

        if let camera = point.viewLocalCameras.first {
            selectedCameraOptic = camera.viewOptic
        }

        if let sound = point.viewLocalSounds.first {
            selectedSoundPlaceType = sound.viewPlaceType
            selectedSoundWindDefence = sound.viewWindDefence
        }

        if let light = point.viewLocalLights.first {
            selectedLight = light.viewLightType
        }
        number = point.viewNumber

        if let camPos = CameraPosition(rawValue: point.viewDescription) {
            position = camPos
        }
    }
}