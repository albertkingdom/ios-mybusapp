//
//  UserViewModelTest.swift
//  MyBusMapTests
//
//  Created by yklin on 2024/11/3.
//

import FirebaseAuth
import Testing

@testable import MyBusMapSwiftUI

enum MockAuthError: Error {
    case authError
}
class MockAuthManager: AuthManagerProtocol {
    func signOut() {
        
    }
    
    func checkIfLogin() -> User? {
        return nil
    }
    
    var isSuccess: Bool
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
    let mockAuthResult = AuthResult(userEmail: "valid email", imageUrl: URL(string: "url")!)
    func signIn(completion: @escaping (Result<AuthResult, Error>) -> Void) {
        switch isSuccess {
        case true:
            completion(.success(mockAuthResult))
        case false:
            completion(.failure(MockAuthError.authError))
        }
    }

}

struct UserViewModelTest {

    @Test func testGoogleLogin_success() async throws {
        let mockAuthManager = MockAuthManager(isSuccess: true)
        let viewModel = UserViewModel(authManager: mockAuthManager)
        let result = try await viewModel.siginIn()
        #expect(result.userEmail == mockAuthManager.mockAuthResult.userEmail)
        #expect(result.imageUrl == mockAuthManager.mockAuthResult.imageUrl)
    }

    @Test func testGoogleLogin_failure() async throws {
        let mockAuthManager = MockAuthManager(isSuccess: false)
        let viewModel = UserViewModel(authManager: mockAuthManager)

        await #expect(
            throws: MockAuthError.authError,
            performing: {
                let result = try await viewModel.siginIn()
            })

    }
}
