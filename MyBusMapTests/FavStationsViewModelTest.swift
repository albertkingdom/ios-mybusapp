//
//  FavStationsViewModelTest.swift
//  MyBusMapTests
//
//  Created by yklin on 2024/11/2.
//

import Realm
import RealmSwift
import Testing

@testable import MyBusMapSwiftUI

enum FirebaseError: Error {
    case getRemoteError
}

final class MockFirebaseManagerService: FirebaseManagerProtocol {
    private let shouldReturnSuccess: Bool
    var mockFavorites: [Favorite] = [
        Favorite(name: "station1", stationID: "1"),
        Favorite(name: "station2", stationID: "2")
    ]

    init(shouldReturnSuccess: Bool) {
        self.shouldReturnSuccess = shouldReturnSuccess
    }

    func getRemoteData(email: String) async -> [Favorite] {
        shouldReturnSuccess ? mockFavorites : []
    }

    func saveToRemote(email: String, favorite: Favorite) {}

    func removeFromRemote(favorite: Favorite) {
        mockFavorites = mockFavorites.filter { $0 != favorite }
    }
}

final class MockRealmManger: RealmManagerProtocol {
    var realm: Realm!

    private let mockFavorites: [FavoriteRealm] = [
        FavoriteRealm(name: "station1", stationID: "1"),
        FavoriteRealm(name: "station2", stationID: "2")
    ]

    init() {
        let config = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        do {
            realm = try Realm(configuration: config)
            try realm.write {
                realm.add(mockFavorites)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func saveToDB(_ favorite: FavoriteRealm) {
        do {
            try realm.write {
                realm.add(favorite)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func readAllFromDB() -> RealmSwift.Results<FavoriteRealm> {
        realm.objects(FavoriteRealm.self)
    }

    func deleteFromDB(objectToDelete: FavoriteRealm) {
        do {
            try realm.write {
                realm.delete(objectToDelete)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

final class MockFavStationsAuthManager: AuthManagerProtocol {
    var isLogin = false
    var email: String = ""

    func checkIfLogin() -> UserSession? {
        isLogin = false
        email = ""
        return nil
    }

    func signIn(completion: @escaping (Result<AuthResult, Error>) -> Void) {}

    func signOut() {
        isLogin = false
        email = ""
    }
}

struct FavStationsViewModelTest {
    @Test func testGetRemoteData_success() async {
        var viewModel = FavStationsViewModel(
            firebaseService: MockFirebaseManagerService(shouldReturnSuccess: true),
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager()
        )
        await viewModel.getRemoteData(email: "")
        #expect(viewModel.favoriteList.count == 2)
    }

    @Test func testGetRemoteData_failure() async {
        var viewModel = FavStationsViewModel(
            firebaseService: MockFirebaseManagerService(shouldReturnSuccess: false),
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager()
        )
        await viewModel.getRemoteData(email: "")
        #expect(viewModel.favoriteList.isEmpty)
    }

    @Test func testDeleteRemoteData() async {
        let mockFirebaseService = MockFirebaseManagerService(shouldReturnSuccess: true)
        var viewModel = FavStationsViewModel(
            firebaseService: mockFirebaseService,
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager()
        )
        viewModel.favoriteList = mockFirebaseService.mockFavorites
        let preCount = viewModel.favoriteList.count
        viewModel.deleteRemoteData(indexSet: IndexSet(integer: 0))
        #expect(viewModel.favoriteList.count == preCount - 1)
    }

    @Test func testDeleteLocalData() async {
        let mockRealmManager = MockRealmManger()
        var viewModel = FavStationsViewModel(
            firebaseService: MockFirebaseManagerService(shouldReturnSuccess: true),
            realmManager: mockRealmManager,
            authManager: MockFavStationsAuthManager()
        )
        viewModel.deleteLocalData(indexSet: IndexSet(integer: 0))
        #expect(mockRealmManager.readAllFromDB().count == 1)
        #expect(viewModel.realmFavList.count == 1)
    }

    @Test func testReadLocalData() {
        let viewModel = FavStationsViewModel(
            firebaseService: MockFirebaseManagerService(shouldReturnSuccess: true),
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager()
        )
        viewModel.readLocalData()
        #expect(viewModel.realmFavList.count == 2)
    }
}
