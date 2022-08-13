//
//  Favorite.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/11/22.
//

import Foundation

struct Favorite: Codable, Hashable, Identifiable {
    let id = UUID()
    var name: String?
    var stationID: String?
    enum CodingKeys: String, CodingKey {
        case name
        case stationID
    }
}

struct FavoriteList: Codable {
    var list: [Favorite]?
    enum CodingKeys: String, CodingKey {
        case list
    }
}
