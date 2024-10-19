//
//  AuthManager.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//

import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLogin = false
    init() {
        checkIfLogin()
    }
    func checkIfLogin() {
        if let _ = Auth.auth().currentUser {
            isLogin = true
            print("isLogin")
        } else {
            print("isNotLogin")
        }
    }
}
