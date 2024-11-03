//
//  AuthManager.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//

import FirebaseAuth
import Foundation

protocol AuthManagerProtocol {
    
}

class AuthManager: ObservableObject {
    @Published var isLogin = false
    @Published var email: String = ""
    init() {
        checkIfLogin()
    }
    func checkIfLogin() {
        if let user = Auth.auth().currentUser, let email = user.email {
            isLogin = true
            self.email = email
            print("isLogin")
        } else {
            print("isNotLogin")
        }
    }
}
