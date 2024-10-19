//
//  FavStationsViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/16.
//

import Foundation
import RealmSwift
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class FavStationsViewModel: ObservableObject {
    let db = Firestore.firestore()
    
    @Published var realmFavList: Results<FavoriteRealm> = RealmManager.shared.readAllFromDB()
    @Published var favoriteList: [Favorite] = []
    @Published var remoteFavoriteRouteNames: [String] = []
    
    func getRemoteData() {
        if let user = Auth.auth().currentUser,
           let email = user.email
        {
            let docRef = db.collection("favoriteRoute").document(email)
            
            docRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                
                do {
                    let list = try document.data(as: FavoriteList.self)
                    print("getRemoteData favoriteList \(list)")
                    self.favoriteList = list.list ?? []
                    self.remoteFavoriteRouteNames = self.favoriteList.compactMap({
                        $0.name
                    })
                }catch {
                    print(error.localizedDescription)
                }
                
            }
            
        } else {
            print("not login")
        }
        
    }
}
