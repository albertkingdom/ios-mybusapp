//
//  AuthManager.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//

import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn


struct AuthResult {
    let userEmail: String
    let imageUrl: URL
}
protocol AuthManagerProtocol {
    func signIn(completion: @escaping (Result<AuthResult, Error>) -> Void)
    func signOut()
    func checkIfLogin() -> User?
}

class AuthManager: ObservableObject, AuthManagerProtocol {
    @Published var isLogin = false
    @Published var email: String = ""
    init() {
        checkIfLogin()
    }
    func checkIfLogin() -> User? {
        if let user = Auth.auth().currentUser, let email = user.email, let imageUrl = user.photoURL {
            isLogin = true
            self.email = email
            print("isLogin")
            return user
        } else {
            print("isNotLogin")
            return nil
        }
    }
    
    func signIn(completion: @escaping (Result<AuthResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        guard
            let presentingViewController =
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                .windows.first?.rootViewController
        else { return }

        GIDSignIn.sharedInstance.signIn(
            with: config, presenting: presentingViewController
        ) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("authentication error \(error.localizedDescription)")
                    completion(.failure(error))
                }
                print(authResult ?? "none")
                if let userEmail = authResult?.user.email, let imageURL = authResult?.user.photoURL {
                    completion(.success(AuthResult(userEmail: userEmail, imageUrl: imageURL)))
                }
            }
        }
    }
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance.signOut()
            isLogin = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
