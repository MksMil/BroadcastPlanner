//
//  NetworkManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 06.05.2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseCore

protocol NetworkManagerProtocol: AnyObject {
    func getCurrentSessionUserInfo()
    func getCurrentUser() async
    func getEvents() async
    func getNewChatMessages() async
    func createUser() async
    func getUsers() async
    func saveUser() async
    func goOnline() async
    func goOffline() async
}


final class NetworkManager: NetworkManagerProtocol {
    
    weak var globalStorage: GlobalStorage!
    var db: Firestore
    
    
    init(globalStorage: GlobalStorage) {
        self.globalStorage = globalStorage
        self.db = Firestore.firestore()
        
    }
    
    @MainActor
    func getCurrentSessionUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        self.globalStorage.currentSessionUser = SessionUser(user: currentUser)
    }
    @MainActor
    func getUsers() async {
        let usersRef = db.collection("users")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            globalStorage.users = usersSnapshot.documents.compactMap{try? $0.data(as: BPUser.self)}
            print(usersSnapshot.debugDescription)
            print("users fetched")
        } catch {
#if DEBUG
            print("DEBUG: getUsers flow error: \(error)")
#endif
        }
    }
    @MainActor
    func getCurrentUser() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
        do{
            globalStorage.currentUser = try await db.collection("users").document(id).getDocument(as: BPUser.self)
        }catch {
            print("error decoding: \(error)")
        }
    }
    
    @MainActor
    func createUser() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("users")
        let user = BPUser(id: id,name: "empty name")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(id).setData(data)
        } catch {
            #if DEBUG
            print("DEBUG: save user error: \(error.localizedDescription)")
            #endif
        }
    }
    
    @MainActor
    func saveUser() async{
        guard let user = globalStorage.currentUser, let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("users")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(id).setData(data)
        } catch {
            #if DEBUG
            print("DEBUG: save user error: \(error.localizedDescription)")
            #endif
        }
    }
    
    func getEvents() async {
        
    }
    
    func getNewChatMessages() async {
        
    }
    
    
    // MARK: - Online/Offline
    @MainActor
    func goOnline() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("users").document(id)
        do {
            try await userRef.updateData(["isOnline":true])
        } catch {
            #if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
            #endif
        }
    }
    @MainActor
    func goOffline() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("users").document(id)
        do {
            try await userRef.updateData(["isOnline":false])
        } catch {
            #if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
            #endif
        }
    }
}
