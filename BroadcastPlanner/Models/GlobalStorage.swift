//
//  GlobalStorage.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.01.2024.
//
//  Object for manage global data through the app

import Foundation

@MainActor
final class GlobalStorage: ObservableObject{
    // MARK: - Authentication
    @Published var currentFirebaseUser: AuthDataResultModel?
    
    // MARK: - Error Handling
    @Published var isErrorShow: Bool = false
    @Published var errorDescription: (String, String) = BPErrorHandleManager.mockError
}
