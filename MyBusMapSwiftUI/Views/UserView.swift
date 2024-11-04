//
//  UserView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/11/22.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import Kingfisher
import SwiftUI

struct UserView: View {
    @StateObject var userViewModel = UserViewModel(authManager: AuthManager())
    var body: some View {
        VStack {
            if userViewModel.imageUrl == nil {
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
                KFImage(userViewModel.imageUrl)
                    .resizable()
                    //.border(.black, width: 1)
                    .frame(width: 100, height: 100, alignment: .center)
                    .clipShape(.circle)
                    .shadow(radius: 3)
                    .overlay {
                        Circle().stroke(.green, lineWidth: 3)
                    }

            }
            Text(userViewModel.userEmail)
            if !userViewModel.isLogin {
                GoogleSignInButton(action: {
                    Task {
                        try? await userViewModel.siginIn()
                    }
                })
                .frame(height: 50, alignment: .center)
                .padding(.horizontal, 50)
            }
            Spacer()

            if userViewModel.isLogin {
                Button {
                    userViewModel.signOut()
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
            userViewModel.checkIfSignIn()
        }
    }

}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
