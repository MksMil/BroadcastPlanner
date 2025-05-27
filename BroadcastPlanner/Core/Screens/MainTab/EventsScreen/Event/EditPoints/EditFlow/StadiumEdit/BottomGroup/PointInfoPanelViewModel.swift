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
    var selectedUser: Member?

    var position: CameraPosition = .pitchSideHalfWay

    var publisher: PassthroughSubject = PassthroughSubject<(PointEditPublishType, Any), Never>()

    let point: VenuePoint
    var availableNumbers: [Int] {
        var nums: [Int] = []
        if let event = point.broadcast{
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

    init(point: VenuePoint) {
        self.point = point
        if let user = point.viewMembers.first {
            selectedUser = user
        }

        if let camera = point.viewCameras.first {
            selectedCameraOptic = camera.viewOptic
        }

        if let sound = point.viewSounds.first {
            selectedSoundPlaceType = sound.viewPlaceType
            selectedSoundWindDefence = sound.viewWindDefence
        }

        if let light = point.viewLights.first {
            selectedLight = light.viewLightType
        }
        number = point.viewNumber

        if let camPos = CameraPosition(rawValue: point.viewDescription) {
            position = camPos
        }
    }
}
