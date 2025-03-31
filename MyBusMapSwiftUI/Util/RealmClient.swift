//
//  RealmClient.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2025/3/30.
//
import Dependencies
import RealmSwift

struct RealmClient {
    var readAllFromDB: @Sendable () async -> [FavoriteRealm]
    var deleteFromDB: @Sendable (FavoriteRealm) async -> Void
}

extension RealmClient: DependencyKey {
    static let liveValue = RealmClient(
        readAllFromDB: {
            // Implement your Realm reading logic here
            await MainActor.run {
                let favorites = RealmManager.shared.readAllFromDB()
                return Array(favorites)
            }
        },
        deleteFromDB: { favorite in
            // Implement your Realm deletion logic here
            RealmManager.shared.deleteFromDB(objectToDelete: favorite)
        }
    )
}

extension DependencyValues {
    var realmClient: RealmClient {
        get { self[RealmClient.self] }
        set { self[RealmClient.self] = newValue }
    }
}
