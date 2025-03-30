//
//  UserFeatureTests.swift
//  MyBusMapTests
//
//  Created by yklin on 2025/3/29.
//

import ComposableArchitecture
import FirebaseAuth
import XCTest

@testable import MyBusMapSwiftUI

@MainActor
final class UserFeatureTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCheckAuthStatus_WhenUserIsAuthenticated() async {
        let store = TestStore(
            initialState: UserFeature.State()
        ) {
            UserFeature()
        } withDependencies: { dependencies in
            // 模擬已登入狀態
            dependencies.authClient.checkAuthStatus = {
                true  // 返回模擬的已登入用戶
            }
        }

        await store.send(.checkAuthStatus) {
            $0.isAuthenticated = true
        }
    }

    func testSignInWithGoogle_Success() async {
        let store = TestStore(
            initialState: UserFeature.State()
        ) {
            UserFeature()
        } withDependencies: { dependencies in
            dependencies.authClient.signIn = {
                AuthResult(
                    userEmail: "test@example.com",
                    imageUrl: URL(string: "https://example.com/photo.jpg")!
                )
            }
        }

        await store.send(.signInWithGoogle)

        await store.receive(\.signInResponse) {
            $0.isAuthenticated = true
            $0.userEmail = "test@example.com"
            $0.imageUrl = URL(string: "https://example.com/photo.jpg")!
        }
    }

    func testSignOut_Success() async {
        let store = TestStore(
            initialState: UserFeature.State(
                isAuthenticated: true,
                userEmail: "test@example.com",
                imageUrl: URL(string: "https://example.com/photo.jpg")!
            )
        ) {
            UserFeature()
        } withDependencies: { dependencies in
            dependencies.authClient.signOut = {}
        }

        await store.send(.signOut)

        await store.receive(\.signOutResponse) {
            $0.isAuthenticated = false
            $0.userEmail = nil
            $0.imageUrl = nil
        }
    }
}
