//
//  FavoriteDisplayItem.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2025/9/28.
//
import Foundation

struct FavoriteDisplayItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let isRemote: Bool
}
