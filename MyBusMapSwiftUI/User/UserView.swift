//
//  UserView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/11/22.
//
import ComposableArchitecture
import GoogleSignInSwift
import Kingfisher
import Perception
import SwiftUI

struct UserView: View {
    let store: StoreOf<UserFeature>

    private var profileView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 10,
                        x: 0,
                        y: 5
                    )

                if let avatarImage = store.imageUrl {
                    KFImage(avatarImage)
                        .resizable()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.green, lineWidth: 3)
                        )
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
            }

            VStack(spacing: 8) {
                if let email = store.userEmail {
                    Text(email)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }

                if let error = store.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
    }

    private var authenticationView: some View {
        VStack(spacing: 20) {
            if !store.isAuthenticated {
                GoogleSignInButton(action: {
                    Task {
                        store.send(.signInWithGoogle)
                    }
                })
                .frame(height: 50)
                .padding(.horizontal, 50)
            } else {
                Button(
                    action: {
                        store.send(.signOut)
                    },
                    label: {
                        Text("登出")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(25)
                            .shadow(
                                color: Color.red.opacity(0.3),
                                radius: 5,
                                x: 0,
                                y: 3
                            )
                    }
                )
                .padding(.horizontal, 40)
            }
        }
    }

    private var appVersionView: some View {
        let appVersion =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? ""
        return Text("版本: \(appVersion)")
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            .opacity(appVersion.isEmpty ? 0 : 1)
    }

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1), Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    profileView.padding(.top, 50)

                    authenticationView

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .overlay(alignment: .bottom) {
                appVersionView
            }
            .onAppear {
                store.send(.checkAuthStatus)
            }
        }
    }
}

#Preview {
        UserView(
            store: Store(
                initialState: UserFeature.State()
            ) {
                UserFeature()
            }
        )
}
