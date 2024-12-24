//
//  MigrationAssistant.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.12.2024.
//
// Class for assistance with prepare data for network transfer to network storage, and for handle newtwork data and prepare to save to 'cache'

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MigrationAssistant {

}

// MARK: - LocalUser Network assistence
extension MigrationAssistant {
    func prepareForSaveLocalUser(_ data: LocalUser)->[String: Any]{
        var resultDictToSave = [String: Any]()
        resultDictToSave[LocalUserProperties.firstName.rawValue] = data.firstName
        resultDictToSave[LocalUserProperties.lastName.rawValue] = data.lastName
        resultDictToSave[LocalUserProperties.email.rawValue] = data.email
        resultDictToSave[LocalUserProperties.homeAddress.rawValue] = data.homeAddress
        resultDictToSave[LocalUserProperties.phoneNumber.rawValue] = data.phoneNumber
        resultDictToSave[LocalUserProperties.isOnline.rawValue] = data.isOnline
        resultDictToSave[LocalUserProperties.creationDate.rawValue] = Timestamp(date: data.creationDate ?? Date())
        resultDictToSave[LocalUserProperties.leaveDate.rawValue] = Timestamp(date: data.leaveDate ?? Date())
        resultDictToSave[LocalUserProperties.specializations.rawValue] = data.specializations
        
        return resultDictToSave
    }
    
    func handleWithData(data: [String: Any]?) {
//        guard let data else { return }
        
//        firstName = data[LocalUserProperties.firstName.rawValue] as? String
//        lastName = data[LocalUserProperties.lastName.rawValue] as? String
//        email = data[LocalUserProperties.email.rawValue] as? String
//        phoneNumber = data[LocalUserProperties.phoneNumber.rawValue] as? String
//        homeAddress = data[LocalUserProperties.homeAddress.rawValue] as? String
//        
//        creationDate =  (data[LocalUserProperties.creationDate.rawValue] as? Timestamp)?.dateValue()
//        leaveDate = (data[LocalUserProperties.leaveDate.rawValue] as? Timestamp)?.dateValue()
//        isOnline = data[LocalUserProperties.isOnline.rawValue] as? Bool ?? false
//        
//        specializations = data[LocalUserProperties.specializations.rawValue] as? String
//        ownedEvents = data[LocalUserProperties.ownedEvents.rawValue] as? [String]
//        participateEvents = data[LocalUserProperties.participateEvents.rawValue] as? [String]
        
    }
}


enum LocalUserProperties: String {
    case id,firstName, lastName, email,homeAddress,phoneNumber, creationDate,leaveDate,isOnline,specializations,image,locationPoints,obVanUnits,ownedEvents,participateEvents
}

// MARK: - Network assistence
extension MigrationAssistant {
//    func prepareForSave()->[String: Any]{
//        var resultDictToSave = [String: Any]()
//        resultDictToSave[LocalEventProperties.firstName.rawValue] = firstName
//        resultDictToSave[LocalEventProperties.lastName.rawValue] = lastName
//        resultDictToSave[LocalEventProperties.email.rawValue] = email
//        resultDictToSave[LocalEventProperties.homeAddress.rawValue] = homeAddress
//        resultDictToSave[LocalEventProperties.phoneNumber.rawValue] = phoneNumber
//        resultDictToSave[LocalEventProperties.isOnline.rawValue] = isOnline
//        resultDictToSave[LocalEventProperties.date.rawValue] = Timestamp(date: date ?? Date())
//        resultDictToSave[LocalEventProperties.specializations.rawValue] = specializations
        
//        return resultDictToSave
//    }
    
//    func handleWithData(data: [String: Any]?) {
//        guard let data else { return }
//        
//    }
}


enum LocalEventProperties: String {
    case id, date, homeClubId, guestClubId,  locationId, locationPoints, broadcasterId, obVanId, obVanUnits, ownerIds, userIds

}
