//
//  NearByStation.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//

import Foundation

struct NearByStation: Identifiable {
    let id = UUID()
    let stationName: String
    var subStations: [SubStation]
}


struct SubStation {
    let stationID: String
    let stationPosition: StationPosition
    let stationAddress: String?
    var routes: [String]
}
