//
//  UserFeature.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2025/9/27.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct UserFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isAuthenticated: Bool = false
        var userEmail: String?
        var imageUrl: URL?
        var error: String?
        // 明確實現 Equatable
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.isAuthenticated == rhs.isAuthenticated
                && lhs.userEmail == rhs.userEmail
                && lhs.imageUrl?.absoluteString == rhs.imageUrl?.absoluteString
                && lhs.error == rhs.error
        }
    }

    enum Action {
        case checkAuthStatus
        case signInWithGoogle
        case signInResponse(AuthResult)
        case signInError(String)
        case signOut
        case signOutResponse
    }

    @Dependency(\.authClient) var authClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkAuthStatus:
                state.isAuthenticated = authClient.checkAuthStatus()
                if let currentUser = authClient.getCurrentUser() {
                    state.userEmail = currentUser.userEmail
                    state.imageUrl = currentUser.imageUrl
                }
                state.error = nil
                return Effect<Action>.none

            case .signInWithGoogle:
                return .run { send in
                    do {
                        let authResult = try await authClient.signIn()
                        await send(.signInResponse(authResult))
                    } catch {
                        await send(.signInError(error.localizedDescription))
                    }
                }
            case .signInResponse(let result):
                state.userEmail = result.userEmail
                state.imageUrl = result.imageUrl
                state.isAuthenticated = true
                state.error = nil
                return .none

            case .signInError(let errorMessage):
                state.error = errorMessage
                return .none

            case .signOut:
                return .run { send in
                    try await authClient.signOut()
                    await send(.signOutResponse)
                }
            case .signOutResponse:
                state.isAuthenticated = false
                state.userEmail = nil
                state.imageUrl = nil
                return .none
            }
        }
    }
}
