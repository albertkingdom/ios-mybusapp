//
//  TokenManagerTests.swift
//  MyBusMapTests
//
//  Created by yklin on 2024/7/13.
//

import XCTest
@testable import MyBusMapSwiftUI

// 1. A flexible MockURLSession that can be configured for different test scenarios.
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.mockData = data
        self.mockResponse = response
        self.mockError = error
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        // If no specific response is provided, create a default successful HTTP response.
        let response = mockResponse ?? HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        return (mockData ?? Data(), response)
    }
}


final class TokenManagerTests: XCTestCase {
    
    var tokenManager: TokenManager!
    var mockSession: MockURLSession!
    let userDefaults = UserDefaults.standard

    override func tearDownWithError() throws {
        // This runs after each test.
        // Clean up UserDefaults and Keychain to ensure test isolation.
        userDefaults.removeObject(forKey: "tokenExpirationDate")
        do {
            try tokenManager?.deleteTokenFromKeychain()
        } catch {
            // Print the error but don't let it interrupt the teardown process.
            print("An error occurred during tearDown while deleting keychain token: \(error)")
        }
        tokenManager = nil
        mockSession = nil
        try super.tearDownWithError()
    }

    // Test Case 1: Successfully fetching a new token.
    func testFetchNewToken_Success() async throws {
        // Arrange
        let tokenResponse = #"{"access_token": "fake-test-token", "expires_in": 3600}"#
        let tokenData = tokenResponse.data(using: .utf8)
        mockSession = MockURLSession(data: tokenData)
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: mockSession)

        // Act
        let receivedToken = try await tokenManager.fetchNewToken()

        // Assert
        XCTAssertEqual(receivedToken, "fake-test-token")

        // Verify that the token was saved to keychain
        let savedToken = tokenManager.retrieveTokenFromKeychain()
        XCTAssertEqual(savedToken, "fake-test-token")

        // Verify that the expiration date was saved
        let expirationDate = userDefaults.object(forKey: "tokenExpirationDate") as? Date
        XCTAssertNotNil(expirationDate)
        XCTAssertTrue(expirationDate! > Date())
    }

    // Test Case 2: Handling a network error when fetching a token.
    func testFetchNewToken_Failure_NetworkError() async {
        // Arrange
        let networkError = URLError(.notConnectedToInternet)
        mockSession = MockURLSession(error: networkError)
        tokenManager = TokenManager(clientID: "testID", clientKey: "testKey", session: mockSession)

        // Act & Assert
        do {
            _ = try await tokenManager.fetchNewToken()
            XCTFail("fetchNewToken should have thrown an error, but it did not.")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }
    
    // Test Case 3: Handling invalid JSON response.
    func testFetchNewToken_Failure_DecodingError() async {
        // Arrange
        let invalidJSONData = "{\"invalid_key\": \"value\"}".data(using: .utf8)
        mockSession = MockURLSession(data: invalidJSONData)
        tokenManager = TokenManager(clientID: "testID", clientKey: "testKey", session: mockSession)

        // Act & Assert
        do {
            _ = try await tokenManager.fetchNewToken()
            XCTFail("Expected fetchNewToken to throw a DecodingError, but it did not.")
        } catch is DecodingError {
            // Success! The expected error was thrown.
        } catch {
            XCTFail("Expected a DecodingError, but a different error was thrown: \(error)")
        }
    }

    // Test Case 6: Handling missing clientID.
    func testFetchNewToken_Failure_MissingClientID() async {
        // Arrange
        mockSession = MockURLSession()
        tokenManager = TokenManager(clientID: nil, clientKey: "testKey", session: mockSession)

        // Act & Assert
        do {
            _ = try await tokenManager.fetchNewToken()
            XCTFail("Expected fetchNewToken to throw NetworkError.missingApiKey, but it did not.")
        } catch NetworkError.missingApiKey {
            // Success! The expected error was thrown.
        } catch {
            XCTFail("Expected NetworkError.missingApiKey, but a different error was thrown: \(error)")
        }
    }

    // Test Case 7: Handling missing clientKey.
    func testFetchNewToken_Failure_MissingClientKey() async {
        // Arrange
        mockSession = MockURLSession()
        tokenManager = TokenManager(clientID: "testID", clientKey: nil, session: mockSession)

        // Act & Assert
        do {
            _ = try await tokenManager.fetchNewToken()
            XCTFail("Expected fetchNewToken to throw NetworkError.missingApiKey, but it did not.")
        } catch NetworkError.missingApiKey {
            // Success! The expected error was thrown.
        } catch {
            XCTFail("Expected NetworkError.missingApiKey, but a different error was thrown: \(error)")
        }
    }

    // Test Case 4: If a valid token exists, it should be returned immediately without a network call.
    func testGetValidToken_WhenTokenIsValid_ReturnsExistingToken() async throws {
        // Arrange
        // This mock session will throw an error if called, proving no network request was made.
        mockSession = MockURLSession(error: URLError(.cancelled))
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: mockSession)
        
        // Manually set the internal state to simulate a valid, existing token.
        tokenManager.currentToken = "existing-valid-token"
        userDefaults.set(Date().addingTimeInterval(3600), forKey: "tokenExpirationDate")

        // Act
        let receivedToken = try await tokenManager.getValidToken()

        // Assert
        XCTAssertEqual(receivedToken, "existing-valid-token")
    }
    
    // Test Case 5: If the token is expired, a new token should be fetched.
    func testGetValidToken_WhenTokenIsExpired_FetchesNewToken() async throws {
        // Arrange
        let newTokenResponse = #"{"access_token": "new-shiny-token", "expires_in": 3600}"#
        let newTokenData = newTokenResponse.data(using: .utf8)
        mockSession = MockURLSession(data: newTokenData)
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: mockSession)

        // Manually set the internal state to simulate an expired token.
        tokenManager.currentToken = "expired-token"
        userDefaults.set(Date().addingTimeInterval(-100), forKey: "tokenExpirationDate")

        // Act
        let receivedToken = try await tokenManager.getValidToken()

        // Assert
        XCTAssertEqual(receivedToken, "new-shiny-token")
    }

    // Test Case 8: Test saveTokenExpiration method.
    func testSaveTokenExpiration() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())

        // Act
        let expiresIn = 3600
        tokenManager.saveTokenExpiration(expiresIn: expiresIn)

        // Assert
        let savedExpirationDate = userDefaults.object(forKey: "tokenExpirationDate") as? Date
        XCTAssertNotNil(savedExpirationDate)
        let expectedExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        XCTAssertEqual(savedExpirationDate!.timeIntervalSince1970, expectedExpirationDate.timeIntervalSince1970, accuracy: 1.0)
    }

    // Test Case 9: Test isTokenExpired when token is not expired.
    func testIsTokenExpired_False() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        userDefaults.set(futureDate, forKey: "tokenExpirationDate")

        // Act
        let isExpired = tokenManager.isTokenExpired()

        // Assert
        XCTAssertFalse(isExpired)
    }

    // Test Case 10: Test isTokenExpired when token is expired.
    func testIsTokenExpired_True() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())
        let pastDate = Date().addingTimeInterval(-100) // 100 seconds ago
        userDefaults.set(pastDate, forKey: "tokenExpirationDate")

        // Act
        let isExpired = tokenManager.isTokenExpired()

        // Assert
        XCTAssertTrue(isExpired)
    }

    // Test Case 11: Test isTokenExpired when no expiration date is set.
    func testIsTokenExpired_NoExpirationDate() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())
        userDefaults.removeObject(forKey: "tokenExpirationDate")

        // Act
        let isExpired = tokenManager.isTokenExpired()

        // Assert
        XCTAssertTrue(isExpired)
    }

    // Test Case 12: Test saveTokenToKeychain method.
    func testSaveTokenToKeychain() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())
        let testToken = "test-token-123"

        // Act
        tokenManager.saveTokenToKeychain(token: testToken)

        // Assert
        let retrievedToken = tokenManager.retrieveTokenFromKeychain()
        XCTAssertEqual(retrievedToken, testToken)
    }

    // Test Case 13: Test retrieveTokenFromKeychain method.
    func testRetrieveTokenFromKeychain() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())
        let testToken = "retrieve-test-token"

        // Act
        tokenManager.saveTokenToKeychain(token: testToken)
        let retrievedToken = tokenManager.retrieveTokenFromKeychain()

        // Assert
        XCTAssertEqual(retrievedToken, testToken)
    }

    // Test Case 14: Test retrieveTokenFromKeychain when no token exists.
    func testRetrieveTokenFromKeychain_NoToken() {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())

        // Act
        let retrievedToken = tokenManager.retrieveTokenFromKeychain()

        // Assert
        XCTAssertNil(retrievedToken)
    }

    // Test Case 15: Test deleteTokenFromKeychain method.
    func testDeleteTokenFromKeychain() throws {
        // Arrange
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: MockURLSession())
        let testToken = "delete-test-token"
        tokenManager.saveTokenToKeychain(token: testToken)

        // Ensure token exists before deletion
        XCTAssertEqual(tokenManager.retrieveTokenFromKeychain(), testToken)

        // Act
        try tokenManager.deleteTokenFromKeychain()

        // Assert
        XCTAssertNil(tokenManager.retrieveTokenFromKeychain())
    }

    // Test Case 16: Test getValidToken when no currentToken exists.
    func testGetValidToken_NoCurrentToken_FetchesNewToken() async throws {
        // Arrange
        let tokenResponse = #"{"access_token": "fetched-new-token", "expires_in": 3600}"#
        let tokenData = tokenResponse.data(using: .utf8)
        mockSession = MockURLSession(data: tokenData)
        tokenManager = TokenManager(forTestWith: "testID", clientKey: "testKey", session: mockSession)

        // Ensure no current token and no expiration date
        tokenManager.currentToken = nil
        userDefaults.removeObject(forKey: "tokenExpirationDate")

        // Act
        let receivedToken = try await tokenManager.getValidToken()

        // Assert
        XCTAssertEqual(receivedToken, "fetched-new-token")
    }
}
