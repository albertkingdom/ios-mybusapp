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

struct FavoriteDisplayItem: Identifiable {
    let id = UUID()
    let name: String
    let isRemote: Bool
}

class FavStationsViewModel: ObservableObject {
    @Published var realmFavList: [FavoriteRealm]
    @Published var favoriteList: [Favorite] = []
    var displayList: [FavoriteDisplayItem] {
        if authManager.isLogin {
            return favoriteList.map {
                FavoriteDisplayItem(name: $0.name ?? "", isRemote: true)
            }
        } else {
            return realmFavList.map {
                FavoriteDisplayItem(name: $0.name, isRemote: false)
            }
        }
    }

    var remoteFavoriteRouteNames: [String] {
        return favoriteList.compactMap({
            $0.name
        })
    }
    let firebaseService: FirebaseManagerProtocol
    let realmManager: RealmManagerProtocol
    let authManager: AuthManager
    init(
        firebaseService: FirebaseManagerProtocol,
        realmManager: RealmManagerProtocol,
        authManager: AuthManager
    ) {
        self.firebaseService = firebaseService
        self.realmManager = realmManager
        self.realmFavList = Array(realmManager.readAllFromDB())
        self.authManager = authManager
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
