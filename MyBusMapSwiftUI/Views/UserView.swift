//
//  UserView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/11/22.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import Kingfisher

struct UserView: View {
    @State var userEmail: String = ""
    @State var imageUri: URL? = nil
    @State var isLogin: Bool = false
    
    var body: some View {
        VStack {
            if imageUri == nil {
                Image(systemName: "person.fill")
                    .resizable()
                    //.border(.black, width: 1)
                    .frame(width: 100, height: 100, alignment: .center)
                    .cornerRadius(50)
            } else {
                KFImage(imageUri)
                    .resizable()
                    //.border(.black, width: 1)
                    .frame(width: 100, height: 100, alignment: .center)
                    .cornerRadius(50)
            }
            Text(userEmail)
            if !isLogin {
                GoogleSignInButton()
                    .frame(height: 50, alignment: .center)
                    .padding(.horizontal, 50)
                    .onTapGesture {
                        googleSignIn()
                    }
            }
            Spacer()
            
            if isLogin {
                Button {
                    signOut()
                } label: {
                    Text("登出".uppercased())
                        .foregroundColor(Color.black)
                }
                .padding()
                .frame(maxWidth: .infinity ,alignment: .center)
                .background(Color(red: 211/255, green: 211/255, blue: 211/255))
            }
        }
        .padding([.top], 50)
        .onAppear {
            updateUI()
        }
    }
    func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: (UIApplication.shared.windows.first?.rootViewController)!) { user, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            // send credential to firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("authentication error \(error.localizedDescription)")
                    return
                }
                print(authResult ?? "none")
                updateUI()
            }
        }
        
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            isLogin = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    func updateUI() {
        if let user = Auth.auth().currentUser,
           let email = user.email,
           let image = user.photoURL
        {
            isLogin = true
            userEmail = email
            imageUri = image
        }
    }
    
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(userEmail: "test@gmail.com")
    }
}
