//
//  ArrivalTime.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//

import Foundation

enum Direction: Int, Codable, Comparable {
    case outbound = 0 // 去程
    case inbound = 1  // 返程
    case loop = 2     // 迴圈
    case unknown = 255 // 未知

    static func < (lhs: Direction, rhs: Direction) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct ArrivalTime: Codable, Identifiable {
    let id = UUID()
    let stopID: String
    let stopName: Name
    let routeName: Name
    let direction: Direction
    let stopStatus: Int // [0:'正常',1:'尚未發車',2:'交管不停靠',3:'末班車已過',4:'今日未營運']
    let estimateTime: Int?
    let srcUpdateTime, updateTime: String

    enum CodingKeys: String, CodingKey {
        case stopID = "StopID"
        case stopName = "StopName"
        case routeName = "RouteName"
        case direction = "Direction"
        case stopStatus = "StopStatus"
        case srcUpdateTime = "SrcUpdateTime"
        case updateTime = "UpdateTime"
        case estimateTime = "EstimateTime"
    }
}

// MARK: - Name
//struct Name: Codable {
//    let zhTw, en: String
//
//    enum CodingKeys: String, CodingKey {
//        case zhTw = "Zh_tw"
//        case en = "En"
//    }
//}
