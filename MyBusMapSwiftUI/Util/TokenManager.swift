//
//  TokenManager.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/7/13.
//

import Foundation
import KeychainAccess

class TokenManager {
    var currentToken: String?
    private let clientID: String?
    private let clientKey: String?
    private let session: URLSessionProtocol
    private let TOKEN_URL: String
    
    // Use bundle identifier for service name to ensure uniqueness.
    // Please verify this matches your project's bundle identifier.
    private let keychain = Keychain(service: "com.example.MyBusMapSwiftUI")
    private let tokenKey = "authToken"

    init(clientID: String?,
         clientKey: String?,
         session: URLSessionProtocol = URLSession(configuration: .default)
    ) {
        self.clientID = clientID
        self.clientKey = clientKey
        self.session = session
        self.TOKEN_URL = "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token"
        self.currentToken = retrieveTokenFromKeychain()
    }
    
    // Initializer for testing purposes to avoid keychain access during setup.
    init(forTestWith clientID: String?, clientKey: String?, session: URLSessionProtocol) {
        self.clientID = clientID
        self.clientKey = clientKey
        self.session = session
        self.TOKEN_URL = "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token"
        // We intentionally don't read from keychain in tests to ensure isolation.
        self.currentToken = nil
    }
    
    func saveTokenExpiration(expiresIn: Int) {
        let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn)) // 當前時間加上 expires_in 秒
        UserDefaults.standard.set(expirationDate, forKey: "tokenExpirationDate")
    }
    
    func getValidToken() async throws -> String {
        if let token = currentToken, !isTokenExpired() {
            print("token還沒過期")
            return token
        }
        return try await fetchNewToken()
    }
    
    internal func isTokenExpired() -> Bool {
        // 實現過期檢查邏輯
        guard let expirationDate = UserDefaults.standard.object(forKey: "tokenExpirationDate") as? Date else {
               return true // 如果沒有儲存過期時間，視為過期
           }
           
        return Date() >= expirationDate
    }
    
    internal func saveTokenToKeychain(token: String) {
        do {
            try keychain.set(token, key: tokenKey)
            print("success save token")
        } catch {
            print("Error saving token to keychain: \(error)")
        }
    }
    
    internal func retrieveTokenFromKeychain() -> String? {
        do {
            let token = try keychain.get(tokenKey)
            return token
        } catch {
            print("Error retrieving token from keychain: \(error)")
            return nil
        }
    }
    
    func deleteTokenFromKeychain() throws {
        do {
            try keychain.remove(tokenKey)
            print("success 刪除token")
        } catch {
            // Re-throw if you need the caller to handle it
            throw error
        }
    }

    
    func fetchNewToken() async throws -> String {
        guard let url = URL(string: TOKEN_URL) else {
            throw NetworkError.invalidURL
        }
        guard let clientID = clientID,
              let clientKey = clientKey
        else { throw NetworkError.missingApiKey}
        
        let request = NetworkManager.Endpoint.token.request
        do {
            let (data, _) = try await session.data(for: request)
            print("data \(data)")
            let decoder = JSONDecoder()
            let token = try decoder.decode(Token.self, from: data)
            let accessToken = token.accessToken
            saveTokenToKeychain(token: accessToken)
            saveTokenExpiration(expiresIn: token.expiresIn)
            self.currentToken = accessToken
            print("saved token is \(accessToken)")
            return token.accessToken
        } catch {
            print("fetchToken error \(error)")
            throw error
        }
    }
}


enum KeychainError: Error {
    case unexpectedData
    case unhandledError(status: OSStatus)
}
