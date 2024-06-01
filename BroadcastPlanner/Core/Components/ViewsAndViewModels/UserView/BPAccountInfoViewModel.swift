//
//  UserViewModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.05.2024.
//

import SwiftUI
import Combine

@MainActor
final class BPAccountInfoViewModel: ObservableObject {
    var user: BPUser? {
        didSet{
            setup()
        }
    }
    
    weak var globalStorage: GlobalStorage?
    
    @Published var isEdit: Bool = false
    @Published var isEditSpec: Bool = false
    
    @Published var isOnline: Bool = false
    @Published var id: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
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
    //computed
   
    
    
    
    func setup(){
        print("setup user")
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
    
    func save() async {
        globalStorage?.authVm.currentUser?.firstName = firstName
        globalStorage?.authVm.currentUser?.lastName = lastName
        globalStorage?.authVm.currentUser?.phoneNumber = phoneNumber
        globalStorage?.authVm.currentUser?.email = email
        globalStorage?.authVm.currentUser?.homeAddress = homeAddress
        globalStorage?.authVm.currentUser?.specialization = specialization
        await globalStorage?.saveUser()
    }
}
