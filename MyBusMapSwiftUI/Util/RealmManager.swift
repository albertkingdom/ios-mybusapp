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
    private let realm: Realm

    init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func saveToDB(_ favorite: FavoriteRealm) {
        do {
            try realm.write {
                realm.add(favorite)
            }
        } catch {
            print("Error saving to Realm: \(error)")
        }
        print("Realm is located at: \(realm.configuration.fileURL!)")
        
    }
    func readAllFromDB() -> Results<FavoriteRealm> {
        let favorites = realm.objects(FavoriteRealm.self)
        return favorites
    }
    func deleteFromDB(objectToDelete: FavoriteRealm) {
        do {
            try realm.write {
                realm.delete(objectToDelete)
            }
        } catch {
            print("Error deleting from Realm: \(error)")
        }
    }
}
