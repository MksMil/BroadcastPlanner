import Combine

final class PointInfoPanelViewModel: ObservableObject {

    var number: Int = 0{
        didSet{
            print("now number \(number)")
        }
    }
    var selectedCameraOptic: OpticType = .none
    var selectedSoundPlaceType: PlaceType = .none
    var selectedSoundWindDefence: WindDefence = .none
    var selectedLight: LightType = .none
    var selectedUser: LocalUser?

    var position: CameraPosition = .pitchSideHalfWay

    var publisher: PassthroughSubject = PassthroughSubject<(PointEditPublishType, Any), Never>()

    let point: LocationPoint
    var availableNumbers: [Int] {
        var nums: [Int] = []
        if let event = point.event{
            nums = event.viewLocationPoints.map{$0.viewNumber}
        }
        nums.removeAll { num in
            num == number
        }
        var result = Array(1...50)
        result.removeAll { number in
            nums.contains(number)
        }
        return result
    }

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
