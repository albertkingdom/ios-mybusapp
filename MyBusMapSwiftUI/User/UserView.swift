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
