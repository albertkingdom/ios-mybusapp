//
//  RealmManager.swift
//  MyBusMapSwiftUI
//
//  Created by YKLin on 8/22/22.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    let realm = try! Realm()
    
    func saveToDB(_ favorite: FavoriteRealm) {
        try! realm.write {
            realm.add(favorite)
        }
        print("Realm is located at: \(realm.configuration.fileURL!)")
        
    }
    func readAllFromDB() -> Results<FavoriteRealm> {
        let favorites = realm.objects(FavoriteRealm.self)
        return favorites
    }
    func deleteFromDB(objectToDelete: FavoriteRealm) {
        try! realm.write {
            realm.delete(objectToDelete)
        }
    }
}
