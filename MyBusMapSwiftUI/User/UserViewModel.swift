//
//  UserViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/11/3.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

class UserViewModel: ObservableObject {
    var authManager: AuthManagerProtocol
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    @Published var isLogin: Bool = false
    @Published var userEmail: String = ""
    @Published var imageUrl: URL?
    
    @MainActor
    func siginIn() async throws -> AuthResult {
        try await withCheckedThrowingContinuation { continuation in
            authManager.signIn { authResult in
                switch authResult {
                case .success(let result):
                    print(authResult)
                    self.isLogin = true
                    self.userEmail = result.userEmail
                    self.imageUrl = result.imageUrl
                    continuation.resume(returning: result)
                    
                case .failure(let error):
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func signOut() {
        authManager.signOut()
        isLogin = false
        userEmail = ""
        imageUrl = nil
    }
    
    func checkIfSignIn() {
        if let session = authManager.checkIfLogin() {
            isLogin = true
            userEmail = session.email
            self.imageUrl = session.photoURL
        }
    }
}
