//
//  FavStationsViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/16.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import RealmSwift

class FavStationsViewModel: ObservableObject {
    @Published var realmFavList: [FavoriteRealm]
    @Published var favoriteList: [Favorite] = []
    var remoteFavoriteRouteNames: [String] {
        return favoriteList.compactMap({
            $0.name
        })
    }
    let firebaseService: FirebaseManagerProtocol
    let realmManager: RealmManagerProtocol
    init(
        firebaseService: FirebaseManagerProtocol,
        realmManager: RealmManagerProtocol
    ) {
        self.firebaseService = firebaseService
        self.realmManager = realmManager
        self.realmFavList = Array(realmManager.readAllFromDB())
    }

    func getRemoteData(email: String) async {

        let favorites = await firebaseService.getRemoteData(email: email)
        print("favorites \(favorites)")
        self.favoriteList = favorites

    }
    
    func deleteRemoteData(indexSet: IndexSet) {
        if let index = indexSet.first {
            let favorite = favoriteList[index]
            firebaseService.removeFromRemote(favorite: favorite)
            favoriteList.remove(at: index)
        }
    }
    
    func deleteLocalData(indexSet: IndexSet) {
        if let index = indexSet.first {
            let favorite = realmFavList[index]
            realmManager.deleteFromDB(objectToDelete: favorite)
            readLocalData()
        }
    }
    
    func readLocalData() {
        self.realmFavList = Array(realmManager.readAllFromDB())
    }
}
