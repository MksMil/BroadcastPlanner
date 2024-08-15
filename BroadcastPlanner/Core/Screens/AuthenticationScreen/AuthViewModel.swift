//
//  AuthViewModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 31.05.2024.
//

import SwiftUI

final class AuthViewModel: ObservableObject{
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
}
