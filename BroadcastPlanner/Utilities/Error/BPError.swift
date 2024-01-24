import Foundation
import FirebaseAuth

enum BPError: Error {
    //Network
    case invalidURL
    case invalidData
    case invalidResponce
    case unableToComplete
    
    var bpErrorDescription: (String, String) {
        switch self {
        case .invalidURL:
            return ("","")
        case .invalidData:
            return ("","")
        case .invalidResponce:
            return ("","")
        case .unableToComplete:
            return ("","")
//        default:
//            return ("","")
        }
    }
}

//handler, returned string for message and name of sf-symbol for Image(systemname: ). optionally can make some 'completion' task

enum BPErrorHandleManager {
    
    // MARK: - Firebase error handler
    static func handleFError(error: NSError) -> (String, String){

        switch error.code {
            //Auth
        case AuthErrorCode.wrongPassword.rawValue:
            return (/*"Wrong Password!"*/"This E-mail already in use","lock")
        case AuthErrorCode.userDisabled.rawValue:
            return ("Account disabled, please contact with network administrator","person.fill.badge.minus")
        case AuthErrorCode.invalidEmail.rawValue:
            return ("Wrong E-mail","person.slash.fill")
            // Rregister
        case AuthErrorCode.weakPassword.rawValue:
            return ("Password too weak!","figure.child.and.lock.open")
        case AuthErrorCode.userNotFound.rawValue:
            return ("Account not founded","person.fill.questionmark")
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return ("This E-mail already in use","person.fill.xmark")
            //network
        case AuthErrorCode.networkError.rawValue:
            return ("Network Error","network.slash")
        default:
            return ("Unknown Error, Sorry","sparkles")
        }
    }
    
    // MARK: - Custom error handling
    static func handleBPError(error: BPError) -> (String, String){
        switch error {
        case .invalidURL:
            return ("Invalid URL","eye.slash")
        default:
            return ("Unknown Error, Sorry","sparkles")
        }
        
    }
    
    // MARK: - Mock Error
    static var mockError: (String, String){
        return ("Error","wifi.exclamationmark")
    }
}
