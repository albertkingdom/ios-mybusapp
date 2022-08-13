//
//  UserDefaultManager.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/12/22.
//

import Foundation

class UserDefaultManager {
    static let shared = UserDefaultManager()
    let userdefault = UserDefaults.standard
    
    func saveStopToLocal(info: Favorite) {
        
        if let existing = userdefault.object(forKey: "favorite") as? Data
        {
            do {
                var favoriteList = try JSONDecoder().decode(FavoriteList.self, from: existing)
                favoriteList.list?.append(info)
                let encodedFavoriteList = try JSONEncoder().encode(favoriteList)
                userdefault.set(encodedFavoriteList, forKey: "favorite")
            } catch {
                print(error.localizedDescription)
            }
            
        } else {
            let favoriteList = FavoriteList(list: [info])
            do {
                let encodedFavoriteList = try JSONEncoder().encode(favoriteList)
                userdefault.set(encodedFavoriteList, forKey: "favorite")
            } catch {
                print(error.localizedDescription)
            }
        }

        print("saveStopToLocal")
    }
    
    func getSavedStopFromLocal() -> [Favorite] {

        if let existingSavedObj = userdefault.object(forKey: "favorite") as? Data
        {
            print("getSavedStopFromLocal")
            do {
                let favoriteList = try JSONDecoder().decode(FavoriteList.self, from: existingSavedObj)
                if let list = favoriteList.list {
                    return list
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        return []
    }
    
    func removeSaveStopFromLocal(target: Favorite) -> [Favorite] {
        
        if let existing = userdefault.object(forKey: "favorite") as? Data
        {
            do {
                var favoriteList = try JSONDecoder().decode(FavoriteList.self, from: existing)
                print("removeSaveStopFromLocal before \(favoriteList)")
                if var favorites = favoriteList.list,
                   let index = favorites.firstIndex(where: {$0.name == target.name})
                {
                    favorites.remove(at: index)
                    favoriteList.list = favorites
                    print("removeSaveStopFromLocal after \(favoriteList)")
                    let encodedFavoriteList = try JSONEncoder().encode(favoriteList)
                    userdefault.set(encodedFavoriteList, forKey: "favorite")
                    
                    return favorites
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return []
    }
}
