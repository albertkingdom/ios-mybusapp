//
//  District.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/29/22.
//

import Foundation

struct District: Codable {
    let city: String
    let cityName: String

    
    enum CodingKeys: String, CodingKey {
        case city = "City"
        case cityName = "CityName"
    }
}
