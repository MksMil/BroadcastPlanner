import Combine
import SwiftUI

@MainActor
final class UnitEditViewModel: ObservableObject {
  let unit: LayoutRenderUnit?
  let dataManager: DataManager
  var number: Int = 0
  var selectedCameraOptic: String = "Empty"
  var selectedSoundPlaceType: String = "Empty"
  var selectedSoundWindDefence: String = "Empty"
  var selectedLight: String = "Empty"
  var selectedUserId: String?

  var position: String = "Unknown"
  var firstName: String?
  var lastName: String?
  var publisher: PassthroughSubject = PassthroughSubject<(PointEditPublishType, Any), Never>()
  //availableUsers
  let availableUsers: FetchedResults<Member>
  let availableNumbers: [Int] = Array(0...50)
  
  init(unit: LayoutRenderUnit?,
       dataManager: DataManager,
       availableUsers: FetchedResults<Member>) {
    self.unit = unit
    self.dataManager = dataManager
    self.availableUsers = availableUsers
    self.firstName = unit?.firstName
    self.lastName = unit?.lastName
    selectedUserId = unit?.personId ?? ""
    selectedCameraOptic = unit?.camera ?? "Empty"
    selectedSoundWindDefence = unit?.sound ?? "Empty"
    selectedSoundPlaceType = unit?.soundPlace ?? "Empty"
    selectedLight = unit?.light ?? "Empty"
    number = unit?.number ?? 0
    position = unit?.description ?? "Unknown"
    
  }
  
  func save(){
    unit?.personId = selectedUserId
    unit?.firstName = firstName
    unit?.lastName = lastName
    unit?.camera = selectedCameraOptic
    unit?.soundPlace = selectedSoundPlaceType
    unit?.sound = selectedSoundWindDefence
    unit?.light = selectedLight
    unit?.description = position
    unit?.number = number
    if let id = selectedUserId{
      Task{
        unit?.image = await dataManager.getImageWithId(id, type: .member, size: .smallImages)
      }
    }
    
  }
  func selectUser(user: Member){
    selectedUserId = selectedUserId == user.id ? nil : user.id
    publisher.send((PointEditPublishType.user, user))
    if selectedUserId != nil{
      firstName = user.firstName
      lastName = user.lastName
    }
  }
}
