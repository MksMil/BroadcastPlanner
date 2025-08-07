import SwiftUI
import Combine

@MainActor
final class AddEditPointOrObvanViewModel: ObservableObject{
    var number: Int = 0
    var selectedCameraOptic: String = "Empty"
    var selectedSoundPlaceType: String = "Empty"
    var selectedSoundWindDefence: String = "Empty"
    var selectedLight: String = "Empty"
    var selectedUser: Member?

    var position: String = "Unknown"

    var publisher: PassthroughSubject = PassthroughSubject<(PointEditPublishType, Any), Never>()

    let point: VenuePoint?
    let broadcast: Broadcast
    var availableNumbers: [Int] {
        var nums: [Int] = []
        
            nums = broadcast.viewVenuePoints.map{$0.viewNumber}
        
        nums.removeAll { num in
            num == number
        }
        var result = Array(1...50)
        result.removeAll { number in
            nums.contains(number)
        }
        return result
    }
    
    @Published var selectedObvan: Obvan?
    var sourceObvan: Obvan?
    var source: [String] = []
    

    init(point: VenuePoint?,
         selectedObvan: Obvan?,
         broadcast: Broadcast) {
        self.broadcast = broadcast
        self.selectedObvan = selectedObvan
        self.sourceObvan = selectedObvan
        
        self.point = point
        if let user = point?.viewMembers.first {
            selectedUser = user
        }

        if let camera = point?.viewCameras.first {
            selectedCameraOptic = camera.viewOptic
        }

        if let sound = point?.viewSounds.first {
            selectedSoundPlaceType = sound.viewPlaceType
            selectedSoundWindDefence = sound.viewWindDefence
        }

        if let light = point?.viewLights.first {
            selectedLight = light.viewLightType
        }
        number = point?.viewNumber ?? 0

        if let camPos = point?.pointDescription {
            position = camPos
        }
        
    }

}
