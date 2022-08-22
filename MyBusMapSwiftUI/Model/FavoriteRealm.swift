//
//  FavoriteRealm.swift
//  MyBusMapSwiftUI
//
//  Created by YKLin on 8/22/22.
//

import Foundation
import RealmSwift

class FavoriteRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var stationID: String = ""
    
    
    convenience init(name: String, stationID: String) {
        self.init()
        self.name = name
        self.stationID = stationID
    }
}
