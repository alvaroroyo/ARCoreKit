import AuthenticationServices
import CryptoKit
import UIKit
import Combine

public final class AppleSignInManager: NSObject {
    
    public static let shared = AppleSignInManager()
    
    public private(set) var nonce: String?
    private var subject: PassthroughSubject<String, Error> = .init()
    
    public func loginWithApple() -> AnyPublisher<String, Error> {
        let nonce = randomNonceString()
        self.nonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
        
        return subject.eraseToAnyPublisher()
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    public enum AppleSignInManagerError: Error {
        case notAppleIDCredential
        case notNonce
        case appleIdToken
        case tokenString
        
        public var localizedDescription: String {
            switch self {
            case .notAppleIDCredential: return "Error converting ASAuthorization to ASAuthorizationAppleIDCredential"
            case .notNonce: return "Nonce value is nil"
            case .appleIdToken: return "Error getting appleIdToken"
            case .tokenString: return "Error converting token to string"
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        subject.send(completion: .failure(error))
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            subject.send(completion: .failure(AppleSignInManagerError.notAppleIDCredential))
            return
        }
        
        guard let nonce = self.nonce else {
            subject.send(completion: .failure(AppleSignInManagerError.notNonce))
            return
        }
        
        guard let appleIdToken = appleIdCredential.identityToken else {
            subject.send(completion: .failure(AppleSignInManagerError.appleIdToken))
            return
        }
        
        guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
            subject.send(completion: .failure(AppleSignInManagerError.tokenString))
            return
        }
        
        subject.send(idTokenString)
    }
}

//MARK: - Nonce
private extension AppleSignInManager {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
