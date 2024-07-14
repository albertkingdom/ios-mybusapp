//
//  MyBusMapTests.swift
//  MyBusMapTests
//
//  Created by yklin on 2024/7/13.
//

import XCTest
@testable import MyBusMapSwiftUI


class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(for request: URLRequest) async throws -> Data {
        if let error = error {
            throw error
        }
        return data ?? Data()
    }
}
class MockKeychainManager {
    var token: Token?
    
    func saveToken(_ token: Token) {
        self.token = token
    }
    
    func retrieveToken() -> Token? {
        return token
    }
}

final class TokenManagerTests: XCTestCase {
    var mockSession: MockURLSession!
    var tokenManager: TokenManager!
    var mockKeychainManager: MockKeychainManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        mockSession = MockURLSession()
        tokenManager = TokenManager(clientID: "testClientID", clientKey: "testClientKey", session: mockSession)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try tokenManager.deleteTokenFromKeychain()
        mockSession = nil
        tokenManager = nil
        try super.tearDownWithError()
    }

    
    func testGetValidToken_withValidToken() async throws {
        let token = Token(accessToken: "testToken", expiresIn: 86400)
        tokenManager.saveTokenToKeychain(token: token)
        tokenManager = TokenManager(clientID: "testClientID", clientKey: "testClientKey", session: mockSession)

        let retrievedToken = try await tokenManager.getValidToken()
        XCTAssertEqual(retrievedToken, token.accessToken)
    }

    func testGetValidToken_withExpiredToken() async throws {
        let expiredToken = Token(accessToken: "expiredToken", expiresIn: -1000)
        tokenManager.saveTokenToKeychain(token: expiredToken)
        tokenManager = TokenManager(clientID: "testClientID", clientKey: "testClientKey", session: mockSession)
        
        let newToken = Token(accessToken: "newToken", expiresIn: 86400)
        mockSession.data = try? JSONEncoder().encode(newToken)
        
        let retrievedToken = try await tokenManager.getValidToken()
        XCTAssertEqual(retrievedToken, newToken.accessToken)
    }
    
    func testGetValidToken_withoutToken() async throws {
        let newToken = Token(accessToken: "newToken", expiresIn: 86400)
        mockSession.data = try? JSONEncoder().encode(newToken)
        
        let retrievedToken = try await tokenManager.getValidToken()
        XCTAssertEqual(retrievedToken, newToken.accessToken)
    }

}
