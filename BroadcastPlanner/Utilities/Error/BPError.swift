import Foundation
import FirebaseAuth

enum BPError {
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

enum BPErrorHandleManager {
    static func handleError(error: NSError, completion: @escaping ()->()) {
        
    }
    
    static func handleError(error: AuthErrorCode, completion: @escaping ()->()){
        
    }
    
    static func handleError(error: BPError, completion: @escaping ()->()) -> (String, String){
        return ("BPError","apple.logo")
    }
    
    static var mockError: (String, String){
        return ("Error","wifi.exclamationmark")
    }
}
