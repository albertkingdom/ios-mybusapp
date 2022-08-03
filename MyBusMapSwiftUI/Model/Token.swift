//
//  Token.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//

import Foundation

struct Token: Codable {
    let accessToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}
