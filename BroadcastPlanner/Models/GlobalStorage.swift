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
    var password: String = ""
    
    // MARK: - Error Handling
    @Published var isErrorShow: Bool = false
    @Published var errorDescription: (String, String) = BPErrorHandleManager.mockError
    
    // MARK: - show Success
    func showSuccessMessage(){
        errorDescription = ("Success!","checkmark")
        isErrorShow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ /*[unowned self] in*/
            self.isErrorShow = false
        }
    }
    // MARK: - show Error
    func showError(error: Error){
        let err: (String, String) = BPErrorHandleManager.handleFError(error: error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){ [unowned self] in
            self.errorDescription = err
            self.isErrorShow = true
        }
    }
    
    // MARK: - show custom Error
    func showErrorWithDescription(des: (String,String)){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){ [unowned self] in
            self.errorDescription = des
            self.isErrorShow = true
        }
    }
}
