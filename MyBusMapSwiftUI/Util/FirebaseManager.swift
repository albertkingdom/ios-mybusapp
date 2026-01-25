//
//  FirebaseManager.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/12/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI
import FirebaseCore
import GoogleSignIn

protocol FirebaseManagerProtocol {
    func getRemoteData(email: String) async -> [Favorite]
    func saveToRemote(email: String, favorite: Favorite)
    func removeFromRemote(favorite: Favorite)
}

class FirebaseManager: FirebaseManagerProtocol, ObservableObject {
    static let shared = FirebaseManager()
    lazy var db = Firestore.firestore()
    
    func getRemoteData(email: String) async -> [Favorite] {

        let docRef = db.collection("favoriteRoute").document(email)
        do {
            let document = try await docRef.getDocument()
            guard let data = document.data() else {
                print("Document data was empty.")
                return []
            }
            print("Current data: \(data)")

            let list = try document.data(as: FavoriteList.self)
            print("getRemoteData favoriteList \(list)")
            return list.list ?? []
        } catch (let error) {
            print(error.localizedDescription)
        }
        return []
    }
    func saveToRemote(email: String, favorite: Favorite) {
        let ref = db.collection("favoriteRoute").document(email)
        ref.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                print("email \(email) document already existed")
                do {
                    let encodedFavorite = try Firestore.Encoder().encode(
                        favorite)
                    ref.updateData([
                        "list": FieldValue.arrayUnion([encodedFavorite])
                    ])
                } catch {
                    print("update data error \(error)")
                }
            } else {
                print("email \(email) document not existed")
                let favoriteList = FavoriteList(list: [favorite])
                do {
                    try self.db.collection("favoriteRoute").document(email)
                        .setData(from: favoriteList)
                } catch let error {
                    print("Error writing city to Firestore: \(error)")
                }
            }
        }

    }

    func removeFromRemote(favorite: Favorite) {
        guard let user = Auth.auth().currentUser,
            let email = user.email
        else { return }
        let ref = db.collection("favoriteRoute").document(email)
        do {
            let encodedFavorite = try Firestore.Encoder().encode(favorite)
            ref.updateData(["list": FieldValue.arrayRemove([encodedFavorite])])
        } catch {
            print("update data error \(error)")
        }
    }
    
}
