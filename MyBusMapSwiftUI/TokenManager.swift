//
//  TokenManager.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/7/13.
//

import Foundation

class TokenManager {
    private var currentToken: Token?
    private let clientID: String?
    private let clientKey: String?
    private let session: URLSessionProtocol
    private let TOKEN_URL: String
    
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
    
    func getValidToken() async throws -> String {
        if let token = currentToken, !isTokenExpired(token) {
            print("token還沒過期")
            return token.accessToken
        }
        return try await fetchNewToken()
    }
    
    private func isTokenExpired(_ token: Token) -> Bool {
        // 實現過期檢查邏輯
        let expirationDate = Date(timeIntervalSinceNow: TimeInterval(token.expiresIn))
        print("過期時間 \(expirationDate)")
        return Date() > expirationDate
    }
    
    internal func saveTokenToKeychain(token: Token) {
        do {
            let tokenData = try JSONEncoder().encode(token)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "authToken",
                kSecValueData as String: tokenData
            ]
            
            // Delete any existing items
            SecItemDelete(query as CFDictionary)
            
            // Add the new token
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving token: \(status)")
            }
            print("success save token \(token)")
        } catch {
            print("\(error)")
        }
        
    }
    internal func retrieveTokenFromKeychain() -> Token? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            
            if status == errSecItemNotFound {
                print("Token not found in Keychain")
            } else {
                print("Error retrieving token: \(status)")
            }
            return nil
        }
        
        
        guard let tokenData = item as? Data,
              let token = try? JSONDecoder().decode(Token.self, from: tokenData) else {
            return nil
        }
        
        return token
    }
    
    func deleteTokenFromKeychain() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken"
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
        print("success 刪除token")
    }
    private func isTokenExpired(token: Token) -> Bool {
        let expirationDate = Date(timeIntervalSinceNow: TimeInterval(token.expiresIn))
        print("expirationDate \(expirationDate)")
        return Date() > expirationDate
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
//            let data = try await NetworkManager.shared.getData(request)
            let data = try await session.data(for: request)
            print("data \(data)")
            let decoder = JSONDecoder()
            let token = try decoder.decode(Token.self, from: data)
            saveTokenToKeychain(token: token)
            self.currentToken = token
            print("saved token is \(token)")
            return token.accessToken
        } catch {
            print("fetchToken error \(error)")
        }
        return ""
    }
}


enum KeychainError: Error {
    case unexpectedData
    case unhandledError(status: OSStatus)
}
