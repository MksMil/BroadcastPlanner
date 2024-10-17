import XCTest
import CoreData
@testable import BroadcastPlanner

final class DataManagerTest: XCTestCase {
    
    // MARK: - Tests
    func test_update_LocalUser_from_BPUser(){
        let sut = DataManager.shared
        XCTAssertNotEqual(sut.moc, nil,"****moc not loaded")
//        let bpUser = mockData.mockUsers[0]
        let newUser = BPUser(id: "123")
//        let user = sut.createOrUpdate(user: bpUser)
        let user = LocalUser(context: sut.moc)

    }
    
//    func test_update_LocalEvent_from_Event(){
//        XCTAssertNotEqual(sut.moc, nil,"****moc not loaded")
//        let event = mockData.mockEvents[0]
//       
//        let localEvent = sut.createOrUpdate(event: event)
//        
//        XCTAssertEqual(localEvent.viewId, event.id)
//        XCTAssertEqual(localEvent.viewDate,
//                       BPDateFormater.format(date: Date(timeIntervalSince1970: 0)))
//        XCTAssertEqual(localEvent.viewBroadcasterName, "Engener Service")
//        
//    }

//    func addMockData(){
//        for user in mockData.mockUsers{
//            let _ = sut.createOrUpdateLocalUserWithUser(user)
//        }
//        for event in mockData.mockEvents{
//            let _ = sut.createOrUpdateLocalEventWithEvent(event)
//        }
//        for broadcastr in mockData.mockBroadcasters{
//            let _ = sut.createOrUpdateLocalBroadcasterWithBroadcaster(broadcastr)
//        }
//        for obvan in mockData.mockObvans{
//            let _ = sut.createOrUpdateLocalObvanWithObvan(obvan)
//        }
//        for club in mockData.mockClubs{
//            let _ = sut.createOrUpdateLocalClubWithClub(club)
//        }
//        for location in mockData.mockLocations{
//            let _ = sut.createOrUpdateLocalLocationWithLocation(location)
//        }
//        for point in mockData.mockLocationPoints{
//            let _ = sut.createOrUpdateLocalPointWithLocationPoint(point)
//        }
//        for unit in mockData.mockObvanUnits{
//            let _ = sut.createOrUpdateLocalObvanUnitWithObvanUnit(unit)
//        }
//        for camera in mockData.mockCameras{
//            let _ = sut.createOrUpdateCamera(camera)
//        }
//        for sound in mockData.mockSounds{
//            let _ = sut.createOrUpdateSound(sound)
//        }
//        for light in mockData.mockLights{
//            let _ = sut.createOrUpdateLocalLightWithLight(light)
//        }
//        for hard in mockData.mockHardware{
//           let _ = sut.createOrUpdateLocalHardwareWithHardware(hard)
//        }
//    }
}

