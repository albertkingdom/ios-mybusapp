//
//  StopOfRoute.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/29/22.
//

import Foundation

struct StopOfRoute: Codable {
    let direction: Int
    let stops: [StopForRouteName]
    enum CodingKeys: String, CodingKey {
        case direction = "Direction"
        case stops = "Stops"
    }
    
}
struct StopForRouteName: Codable {
    
    let stopName: Name
    let stopSequence: Int
    let stopPosition: StopPosition
    
    

    enum CodingKeys: String, CodingKey {
    
        case stopName = "StopName"
        case stopSequence = "StopSequence"
        case stopPosition = "StopPosition"
        
    }
}

struct StopPosition: Codable {
    let positionLon, positionLat: Double
    let geoHash: String

    enum CodingKeys: String, CodingKey {
        case positionLon = "PositionLon"
        case positionLat = "PositionLat"
        case geoHash = "GeoHash"
    }
}
