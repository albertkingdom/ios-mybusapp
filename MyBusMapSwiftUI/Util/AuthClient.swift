import Foundation
import ComposableArchitecture
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct AuthClient {
    var signIn: () async throws -> AuthResult
    var signOut: () async throws -> Void
    var checkAuthStatus: () -> Bool
    var getCurrentUser: () -> AuthResult?
}

extension AuthClient: DependencyKey {
    static let liveValue = Self(
        signIn: {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthResult, Error>) in
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    continuation.resume(throwing: AuthError.clientIDNotFound)
                    return
                }
                
                let config = GIDConfiguration(clientID: clientID)
                
                guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                    continuation.resume(throwing: AuthError.noPresentingViewController)
                    return
                }
                
                GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingViewController) { user, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let authentication = user?.authentication,
                          let idToken = authentication.idToken else {
                        continuation.resume(throwing: AuthError.noAuthentication)
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: authentication.accessToken
                    )
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        if let userEmail = authResult?.user.email,
                           let imageURL = authResult?.user.photoURL {
                            continuation.resume(returning: AuthResult(userEmail: userEmail, imageUrl: imageURL))
                        } else {
                            continuation.resume(throwing: AuthError.invalidUserData)
                        }
                    }
                }
            }
        },
        signOut: {
            let firebaseAuth = Auth.auth()
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance.signOut()
        },
        checkAuthStatus: {
            return Auth.auth().currentUser != nil
        },
        getCurrentUser: {
            guard let user = Auth.auth().currentUser else { return nil }
            return AuthResult(userEmail: user.email ?? "", imageUrl: user.photoURL )
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}


enum AuthError: LocalizedError {
    case clientIDNotFound
    case noPresentingViewController
    case noAuthentication
    case invalidUserData
    
    var errorDescription: String? {
        switch self {
        case .clientIDNotFound:
            return "Google Client ID not found"
        case .noPresentingViewController:
            return "No presenting view controller"
        case .noAuthentication:
            return "Authentication failed"
        case .invalidUserData:
            return "Invalid user data"
        }
    }
}
