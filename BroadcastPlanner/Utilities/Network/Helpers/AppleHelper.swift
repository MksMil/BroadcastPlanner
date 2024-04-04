//
//  AppleHelper.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 28.02.2024.
//
import AuthenticationServices
import CryptoKit
import Foundation
import FirebaseAuth


final class AppleHelper {
    
    private var nounce: String = ""
    
    func makeFIRCredentialFromAppleID(credential: ASAuthorizationAppleIDCredential, andNounce nounce: String) throws-> AuthCredential{
        guard let appleIDToken = credential.identityToken else {  throw BPError.unableToComplete }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { throw BPError.unableToComplete }
        
        let newCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nounce,
            fullName: credential.fullName
        )
        return newCredential
    }
}



// MARK: - Crypto part
extension AppleHelper{
    func getRandomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    func getSha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
