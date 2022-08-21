//
//  Station.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation

struct Station: Codable {
    let stationUID, stationID: String
    let stationName: StationName
    let stationPosition: StationPosition
    let stationAddress: String? = nil
    let stops: [Stop]
    let locationCityCode, bearing: String
    let updateTime: String
    let versionID: Int

    enum CodingKeys: String, CodingKey {
        case stationUID = "StationUID"
        case stationID = "StationID"
        case stationName = "StationName"
        case stationPosition = "StationPosition"
        case stationAddress = "StationAddress"
        case stops = "Stops"
        case locationCityCode = "LocationCityCode"
        case bearing = "Bearing"
        case updateTime = "UpdateTime"
        case versionID = "VersionID"
    }
}

// MARK: - StationName
struct StationName: Codable {
    let zhTw: String

    enum CodingKeys: String, CodingKey {
        case zhTw = "Zh_tw"
    }
}

// MARK: - StationPosition
struct StationPosition: Codable {
    let positionLon, positionLat: Double
    let geoHash: String

    enum CodingKeys: String, CodingKey {
        case positionLon = "PositionLon"
        case positionLat = "PositionLat"
        case geoHash = "GeoHash"
    }
}

// MARK: - Stop
struct Stop: Codable {
    let stopUID, stopID: String
    let stopName: Name
    let routeUID, routeID: String?
    let routeName: Name
    
    enum CodingKeys: String, CodingKey {
        case stopUID = "StopUID"
        case stopID = "StopID"
        case stopName = "StopName"
        case routeUID = "RouteUID"
        case routeID = "RouteID"
        case routeName = "RouteName"
    }
}

// MARK: - Name
struct Name: Codable {
    let zhTw, en: String

    enum CodingKeys: String, CodingKey {
        case zhTw = "Zh_tw"
        case en = "En"
    }
}
