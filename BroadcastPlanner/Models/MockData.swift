//import Foundation
//import Firebase
//
//class MockData {
//    // MARK: - Mock User
//    var mockUsers: [BPUser] {
//        var user = BPUser(id: "mockID1")
//        user.firstName = "Adam"
//        user.lastName = "Sandler"
//        user.email = "mock@email.com"
//        user.homeAddress = "Mock city, Mock str. 17/23"
//        user.phoneNumber = "+0075557700"
//        user.specialization = [UserSpecialization.allCases[0].rawValue]
//        user.isOnline = true
//        user.creationDate =  Timestamp(date: Date(timeIntervalSince1970: 0))
//        user.leaveDate = Timestamp(date: Date(timeIntervalSince1970: 10000))
//        user.participatedEventIds = ["firstEventId","secondEventId"]
//        user.ownedEventIds = ["secondEventId"]
//        
//        var user1 = BPUser(id: "mockID2")
//        user1.firstName = "Fedor"
//        user1.lastName = "Bondarchuk"
//        user1.email = "mock@email.com"
//        user1.homeAddress = "Mock city, Mock str. 17/23"
//        user1.phoneNumber = "+0075557700"
//        user1.specialization = [UserSpecialization.allCases[0].rawValue]
//        user1.isOnline = true
//        user1.creationDate =  Timestamp(date: Date(timeIntervalSince1970: 0))
//        user1.leaveDate = Timestamp(date: Date(timeIntervalSince1970: 10000))
//        user1.participatedEventIds = ["firstEventId", "secondEventId"]
//        user1.ownedEventIds = ["firstEventId"]
//        
//        var user2 = BPUser(id: "mockID3")
//        user2.firstName = "Viktor"
//        user2.lastName = "Kabkoff"
//        user2.email = "mock@email.com"
//        user2.homeAddress = "Mock city, Mock str. 17/23"
//        user2.phoneNumber = "+0075557700"
//        user2.specialization = [UserSpecialization.allCases[0].rawValue]
//        user2.isOnline = true
//        user2.creationDate =  Timestamp(date: Date(timeIntervalSince1970: 0))
//        user2.leaveDate = Timestamp(date: Date(timeIntervalSince1970: 10000))
//        user2.participatedEventIds = ["firstEventId","secondEventId","thirdEventId"]
//        user2.ownedEventIds = ["thirdEventId"]
//        
//        return [user, user1, user2]
//    }
//    
//    // MARK: - Mock Event
//    var mockEvents: [BPEvent] {
//        [BPEvent(
//            id: "firstEventId",
//            date: Date(timeIntervalSince1970: 0),
//            broadcasterId: "Engener Service",
//            obVanId: "obvanId1",
//            locationPoints: [
//                LocationPoint(id: "point1Id",
//                              userId: ["mockID2"],
//                              coordinateX: 0,
//                              coordinateY: 0,
//                              rotation: 0,
//                              imageId: "locImage1",
//                              number: 1,
//                              description: "main cam",
//                              task: "work all match faino",
//                              cameras: [Camera(id: "cam1Id", optic: .x22)],
//                              sounds: [Sound(id: "soundId1",
//                                             windDefence: .dog,
//                                             placeType: .low)],
//                              lights: [Light(id: "lightId1", lightType: .light)]),
//                LocationPoint(id: "point2Id",
//                              userId: ["mockID1"],
//                              coordinateX: 0,
//                              coordinateY: 0,
//                              rotation: 0,
//                              imageId: "locImage1",
//                              number: 2,
//                              description: "cam",
//                              task: "work all match faino",
//                              cameras: [Camera(id: "cam2Id", optic: .x40)],
//                              sounds: [Sound(id: "soundId2",
//                                             windDefence: .dog,
//                                             placeType: .low)],
//                              lights: [])
//            ],
//            obvanUnits: [OBVanUnit(id: "unit1",
//                                   position: .replayOperator,
//                                   coordinateX: 0,
//                                   coordinateY: 0,
//                                   rotation: 0,
//                                   userId: "mockID1",
//                                   hardwares: [Hardware(id: "hardId1", envType: .evs, chanels: ["1","2"])]),
//                         OBVanUnit(id: "unit2",
//                                   position: .replayOperator,
//                                   coordinateX: 0,
//                                   coordinateY: 0,
//                                   rotation: 0,
//                                   userId: "mockID2",
//                                   hardwares: [Hardware(id: "hardId2", envType: .evs, chanels: ["3","4"])]),
//                         OBVanUnit(id: "unit3",
//                                   position: .replayOperator,
//                                   coordinateX: 0,
//                                   coordinateY: 0,
//                                   rotation: 0,
//                                   userId: "mockID3",
//                                   hardwares: [ Hardware(id: "hardId3", envType: .evs, chanels: ["1","2","3","4"]) ]
//                                  )
//            ],
//            locationID: "loc1Id",
//            homeClubId: "dynamoId",
//            guestClubId: "shakhtarId"
//        ),
//         BPEvent(
//            id: "secondEventId",
//            date: Date(timeIntervalSince1970: 10000),
//            broadcasterId: "Soft Group",
//            obVanId: "obvanId3",
//            locationPoints: [],
//            obvanUnits: [],
//            locationID: "loc2Id",
//            homeClubId: "VorsklaId",
//            guestClubId: "KolosId"
//         ),
//         BPEvent(
//            id: "thirdEventId",
//            date: Date(timeIntervalSince1970: 20000),
//            broadcasterId: "1+1",
//            obVanId: "obvanId4",
//            locationPoints: [],
//            obvanUnits: [],
//            locationID: "loc3Id",
//            homeClubId: "KolosId",
//            guestClubId: "dynamoId"
//         )
//        ]
//    }
//    
//    // MARK: - Mock Broadcaster
//    var mockBroadcasters: [Broadcaster]  {
//        [Broadcaster(id: UUID().uuidString,
//                     title: "Engener Service",
//                     obVans: [OBVan(id: "obvanId1",
//                                    name: "StarBird",
//                                    imageId: "StarBirdImaageID"),
//                              OBVan(id: "obvanId2",
//                                    name: "BlueBird",
//                                    imageId: "BlueBirdImageID")],
//                     eventIds: ["firstEventId"]),
//         Broadcaster(id: UUID().uuidString,
//                     title: "Soft Group",
//                     obVans: [OBVan(id: "obvanId3",
//                                    name: "SGObvan1",
//                                    imageId: "SGObvan1Image1")],
//                     eventIds: ["firstEventId"]),
//         Broadcaster(id: UUID().uuidString,
//                     title: "1+1",
//                     obVans: [OBVan(id: "obvanId4",
//                                    name: "StarMedia",
//                                    imageId: "StarMediaImage1")],
//                     eventIds: ["firstEventId"])
//        ]
//    }
//    
//    var mockObvans: [OBVan]  {
//        [OBVan(id: "obvanId1",
//               name: "StarBird",
//               imageId: "StarBirdImaageID"),
//         OBVan(id: "obvanId2",
//               name: "BlueBird",
//               imageId: "BlueBirdImageID"),
//         OBVan(id: "obvanId3",
//               name: "SGObvan1",
//               imageId: "SGObvan1Image1"),
//         OBVan(id: "obvanId4",
//               name: "StarMedia",
//               imageId: "StarMediaImage1")
//        ]
//    }
//    
//    var mockClubs: [Club]  {
//        [
//            Club(id: "dynamoId", title: "Dynamo", contacts: "Kyiv, Olimpiyskaya Olimpiyskiy stadium", urlString: "Dynamo.com", imageLogoID: "Dynamo-logo", homeLocationID: "loc1Id"
//                ),
//            Club(id: "shakhtarId", title: "Shakhtar", contacts: "Lviv, Lviv Arena stadium", urlString: "Shakhtar.com", imageLogoID: "Shakhtar-logo", homeLocationID: "loc2Id"
//                ),
//            Club(id: "VorsklaId", title: "Vorskla", contacts: "Poltava, Vorskla stadium", urlString: "Vorskla.com", imageLogoID: "Vorskla-logo", homeLocationID: "loc3Id"
//                ),
//            Club(id: "KolosId", title: "Kolos", contacts: "Kovalivka, Kolos stadium", urlString: "Kolos.com", imageLogoID: "Kolos-logo", homeLocationID: "loc4Id"
//                )
//        ]
//    }
//    var mockLocations: [Location]  {
//        [
//            Location(id: "loc1Id",
//                     title: "Olimpiyskiy stadium",
//                     address: "Kyiv st.metro Olimpiyskaya",
//                     imagesIds: ["imageId1"],
//                     locationBackgroundId: "olympBG"),
//            Location(id: "loc2Id",
//                     title: "Arena Lviv",
//                     address: "Lviv Arena-Lviv",
//                     imagesIds: ["imageId10"],
//                     locationBackgroundId: "arenaLvBG"),
//            Location(id: "loc3Id",
//                     title: "Vorskla",
//                     address: "Poltava",
//                     imagesIds: ["imageId20"],
//                     locationBackgroundId: "PolatavaBG"),
//            Location(id: "loc4Id",
//                     title: "Kolos Arena",
//                     address: "Kovalivka",
//                     imagesIds: ["imageId30"],
//                     locationBackgroundId: "KolosBG")
//        ]
//    }
//    
//    var mockLocationPoints: [LocationPoint]  {
//        [
//            LocationPoint(id: "point1Id",
//                          userId: ["mockID2"],
//                          coordinateX: 0,
//                          coordinateY: 0,
//                          rotation: 0,
//                          imageId: "locImage1",
//                          number: 1,
//                          description: "main cam",
//                          task: "work all match faino",
//                          cameras: [Camera(id: "cam1Id", optic: .x22)],
//                          sounds: [Sound(id: "soundId1",
//                                         windDefence: .dog,
//                                         placeType: .low)],
//                          lights: [Light(id: "lightId1", lightType: .light)]),
//            LocationPoint(id: "point2Id",
//                          userId: ["mockID1"],
//                          coordinateX: 0,
//                          coordinateY: 0,
//                          rotation: 0,
//                          imageId: "locImage1",
//                          number: 2,
//                          description: "cam",
//                          task: "work all match faino",
//                          cameras: [Camera(id: "cam2Id", optic: .x40)],
//                          sounds: [Sound(id: "soundId2",
//                                         windDefence: .dog,
//                                         placeType: .low)],
//                          lights: [])
//        ]
//    }
//    
//    var mockObvanUnits :[OBVanUnit]  {
//        [OBVanUnit(id: "unit1",
//                   position: .replayOperator,
//                   coordinateX: 0,
//                   coordinateY: 0,
//                   rotation: 0,
//                   isEnabled: true,
//                   userId: "mockID1",
//                   hardwares: [Hardware(id: "hardId1", envType: .evs, chanels: ["1","2"])]),
//         OBVanUnit(id: "unit2",
//                   position: .replayOperator,
//                   coordinateX: 0,
//                   coordinateY: 0,
//                   rotation: 0,
//                   isEnabled: true,
//                   userId: "mockID2",
//                   hardwares: [Hardware(id: "hardId2", envType: .evs, chanels: ["3","4"])]),
//         OBVanUnit(id: "unit3",
//                   position: .replayOperator,
//                   coordinateX: 0,
//                   coordinateY: 0,
//                   rotation: 0,
//                   isEnabled: true,
//                   userId: "mockID3",
//                   hardwares: [ Hardware(id: "hardId3", envType: .evs, chanels: ["1","2","3","4"]) ]
//                  )
//        ]
//    }
//    
//    var mockCameras: [Camera]  {
//        [
//            Camera(id: "cam1Id", optic: .x22),
//            Camera(id: "cam2Id", optic: .x40),
//            Camera(id: "cam3Id", optic: .x76),
//            Camera(id: "cam4Id", optic: .Archer2)
//        ]
//    }
//    
//    var mockSounds: [Sound] {
//        [
//            Sound(id: "soundId1",
//                  windDefence: .dog,
//                  placeType: .low),
//            Sound(id: "soundId2",
//                  windDefence: .dog,
//                  placeType: .low),
//            Sound(id: "soundId3",
//                  windDefence: .dog,
//                  placeType: .low),
//            Sound(id: "soundId4",
//                  windDefence: .dog,
//                  placeType: .low),
//        ]
//    }
//    
//    var mockLights: [Light]  {
//        [
//            Light(id: "lightId1", lightType: .light),
//            Light(id: "lightId2", lightType: .light),
//            Light(id: "lightId3", lightType: .light)
//        ]
//    }
//    
//    var mockHardware: [Hardware] {
//        [
//            Hardware(id: "hardId1", envType: .evs, chanels: ["1","2"]),
//            Hardware(id: "hardId2", envType: .evs, chanels: ["3","4"]),
//            Hardware(id: "hardId3", envType: .evs, chanels: ["1","2","3","4"])
//        ]
//    }
//}
