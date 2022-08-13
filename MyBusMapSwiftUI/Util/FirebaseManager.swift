//
//  FirebaseManager.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/12/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    

    func saveToRemote(favorite: Favorite) {
        
        guard let user = Auth.auth().currentUser,
              let email = user.email else { return }
        
        let ref = db.collection("favoriteRoute").document(email)
        ref.getDocument { snapshot, error in
            if let snapshot = snapshot , snapshot.exists {
                print("email \(email) document already existed")
                do {
                    let encodedFavorite = try Firestore.Encoder().encode(favorite)
                    ref.updateData(["list": FieldValue.arrayUnion([encodedFavorite])])
                } catch {
                    print("update data error \(error)")
                }
            } else {
                print("email \(email) document not existed")
                let favoriteList = FavoriteList(list: [favorite])
                do {
                    try self.db.collection("favoriteRoute").document(email).setData(from: favoriteList)
                } catch let error {
                    print("Error writing city to Firestore: \(error)")
                }
            }
        }
        
    }
    
    func removeFromRemote(favorite: Favorite) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else { return }
        let ref = db.collection("favoriteRoute").document(email)
        do {
            let encodedFavorite = try Firestore.Encoder().encode(favorite)
            ref.updateData(["list": FieldValue.arrayRemove([encodedFavorite])])
        } catch {
            print("update data error \(error)")
        }
    }
}
