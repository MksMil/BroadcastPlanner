//
//  Object for manage global data through the app

import Foundation

@MainActor
final class GlobalStorage: ObservableObject{
    // MARK: - Authentication
    var outerStorage: BPOuterStorage = .firebase
    var authProvider: BPAuthProvider
    
    var applCurrentNonce: String = ""
    
    @Published var currentFirebaseUser: UserAuthInfo?
    private(set) var password: String = ""
    
    // MARK: - Error Handling
    @Published var isErrorShow: Bool = false
    @Published var errorDescription: (String, String) = BPErrorHandleManager.mockError
    
    // MARK: - Init
    init(
        outerStorage: BPOuterStorage = .firebase,
        currentFirebaseUser: UserAuthInfo? = nil,
        password: String = "",
        isErrorShow: Bool = false,
        errorDescription: (String, String) = ("","")
    ) {
        self.outerStorage = outerStorage
        switch outerStorage {
        case .firebase:
            self.authProvider = AuthenticationManager.shared
        }
        self.currentFirebaseUser = currentFirebaseUser
        self.password = password
        self.isErrorShow = isErrorShow
        self.errorDescription = errorDescription
    }
    
    // MARK: - show Success Message
    func showSuccessMessage(){
        errorDescription = ("Success!","checkmark")
        isErrorShow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.isErrorShow = false
        }
    }
    // MARK: - show Error
    func showFirebaseError(error: Error){
        let err: (String, String) = BPErrorHandleManager.handleFError(error: error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
            self.errorDescription = err
            self.isErrorShow = true
        }
    }
    
    func showBPError(error: BPError){
        let err: (String, String) = BPErrorHandleManager.handleBPError(error: error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
            self.errorDescription = err
            self.isErrorShow = true
        }
    }
    
    // MARK: - show custom Error
    func showErrorWithDescription(des: (String,String)){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
            self.errorDescription = des
            self.isErrorShow = true
        }
    }
    
    func changePassword(newPassword: String){
        self.password = newPassword
    }
}
