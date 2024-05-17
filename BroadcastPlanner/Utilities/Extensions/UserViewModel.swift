//
//  UserViewModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.05.2024.
//

import SwiftUI
//import Combine

@MainActor
final class UserViewModel: ObservableObject {
    var user: BPUser? {
        didSet{
            setup()
        }
    }
    @Published var isOnline: Bool = false
    @Published var id: String = ""
    @Published var firstName: String = "empty name"
    @Published var lastName: String = "empty lastName"
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var homeAddress: String = ""
    
    @Published var creationDate: Date?
    @Published var leaveDate: Date?
    
    @Published var ownedEvents = [Event]()
    @Published var memberEvents = [Event]()
    
    @Published var specialization = [String]()
    
    @Published var photoURL: String?
    
    @Published var userImage: Image = Image("Fedorok_zloy")//Image(systemName: "person.crop.circle")
    
//     var cancelables: [AnyCancellable] = []
    
    func setup(){
        self.isOnline = user?.isOnline ?? false
        self.firstName = user?.firstName ?? ""
        self.lastName = user?.lastName ?? ""
        self.phoneNumber = user?.phoneNumber ?? ""
        self.email = user?.email ?? ""
        self.homeAddress = user?.homeAddress ?? ""
        self.creationDate = user?.creationDate
        self.leaveDate = user?.leaveDateConverted
        self.ownedEvents = user?.ownedEvents ?? []
        self.memberEvents = user?.memberEvents ?? []
        self.specialization = user?.specialization ?? []
        self.photoURL = user?.photoURL
    }
    
    func save(in globalStorage: GlobalStorage) async {
        globalStorage.currentUser?.firstName = firstName
        globalStorage.currentUser?.lastName = lastName
        globalStorage.currentUser?.phoneNumber = phoneNumber
        globalStorage.currentUser?.email = email
        globalStorage.currentUser?.homeAddress = homeAddress
        globalStorage.currentUser?.specialization = specialization
        await globalStorage.saveUser()
    }
}
