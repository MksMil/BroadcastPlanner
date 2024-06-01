//
//  AuthViewModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 31.05.2024.
//

import SwiftUI

final class AuthViewModel: ObservableObject{
    @Published var currentSessionUser: SessionUser?
    @Published var currentUser: BPUser?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    weak var globalStorage: GlobalStorage?
}
