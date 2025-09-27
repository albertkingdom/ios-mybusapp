//
//  UserView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/11/22.
//

import ComposableArchitecture
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import Kingfisher
import Perception
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
                if state.isAuthenticated {
                    state.userEmail = Auth.auth().currentUser?.email
                    state.imageUrl = Auth.auth().currentUser?.photoURL
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

struct UserView: View {
    let store: StoreOf<UserFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.imageUrl == nil {
                    Image(systemName: "person.fill")
                        .resizable()
                        //.border(.black, width: 1)
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(.circle)
                        .shadow(radius: 3)
                        .overlay {
                            Circle().stroke(.gray, lineWidth: 3)
                        }

                } else {
                    KFImage(store.imageUrl)
                        .resizable()
                        //.border(.black, width: 1)
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(.circle)
                        .shadow(radius: 3)
                        .overlay {
                            Circle().stroke(.green, lineWidth: 3)
                        }

                }
                Text(store.userEmail ?? "")
                if let error = store.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                if !store.isAuthenticated {
                    GoogleSignInButton(action: {
                        Task {
                            store.send(.signInWithGoogle)
                        }
                    })
                    .frame(height: 50, alignment: .center)
                    .padding(.horizontal, 50)
                }
                Spacer()

                if store.isAuthenticated {
                    Button {
                        store.send(.signOut)
                    } label: {
                        Text("登出".uppercased())
                            .foregroundColor(Color.black)
                            .fontWeight(.heavy)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding([.top], 50)
            .onAppear {
                store.send(.checkAuthStatus)
            }
        }
    }

}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(
            store: Store(
                initialState: UserFeature.State()
            ) {
                UserFeature()
            }
        )
    }
}
