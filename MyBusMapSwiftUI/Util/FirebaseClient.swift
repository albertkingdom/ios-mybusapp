//
//  FirebaseClient.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2025/3/30.
//

// New file: FirebaseClient.swift
import Dependencies
import FirebaseFirestore

struct FirebaseClient {
    var getRemoteData: @Sendable (String) async -> [Favorite]
    var removeFromRemote: @Sendable (Favorite) async -> Void
}

extension FirebaseClient: DependencyKey {
    static let liveValue = FirebaseClient(
        getRemoteData: { email in
            // Implement your Firebase fetching logic here
            return await FirebaseManager.shared.getRemoteData(email: email)
        },
        removeFromRemote: { favorite in
            // Implement your Firebase removal logic here
            FirebaseManager.shared.removeFromRemote(favorite: favorite)
        }
    )
}

extension DependencyValues {
    var firebaseClient: FirebaseClient {
        get { self[FirebaseClient.self] }
        set { self[FirebaseClient.self] = newValue }
    }
}
