//
//  Test.swift
//  MyBusMapTests
//
//  Created by yklin on 2024/11/2.
//

import Realm
import RealmSwift
import Testing
import FirebaseAuth

@testable import MyBusMapSwiftUI

enum FirebaseError: Error {
    case getRemoteError
}

class MockFirebaseManagerService: FirebaseManagerProtocol {
    var shouldReturnSuccess = false
    var mockFavorites: [Favorite] = [
        Favorite(name: "station1", stationID: "1"),
        Favorite(name: "station2", stationID: "2"),
    ]
    init(shouldReturnSuccess: Bool) {
        self.shouldReturnSuccess = shouldReturnSuccess
    }
    func getRemoteData(email: String) async -> [Favorite] {
        if shouldReturnSuccess {
            return mockFavorites
        } else {
            return []
        }
    }

    func saveToRemote(email: String, favorite: MyBusMapSwiftUI.Favorite) {

    }

    func removeFromRemote(favorite: MyBusMapSwiftUI.Favorite) {
        mockFavorites = mockFavorites.filter { $0 != favorite }
    }

}

class MockRealmManger: RealmManagerProtocol {
    var realm: Realm!
    init() {
        let config = Realm.Configuration(
            inMemoryIdentifier: UUID().uuidString)
        // Open the realm
        do {
            self.realm = try Realm(configuration: config)
            do {
                try realm?.write {
                    self.realm.add(mockFavorites)
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    var mockFavorites: [FavoriteRealm] = [
        FavoriteRealm(name: "station1", stationID: "1"),
        FavoriteRealm(name: "station2", stationID: "2"),
    ]
    func saveToDB(_ favorite: MyBusMapSwiftUI.FavoriteRealm) {
        do {
            try realm?.write {
                realm?.add(favorite)
            }
        } catch let error {
            print(error.localizedDescription)
        }
       
    }

    func readAllFromDB() -> RealmSwift.Results<MyBusMapSwiftUI.FavoriteRealm> {
        
            
        let objects = realm.objects(FavoriteRealm.self)
        return objects
        
        
    }

    func deleteFromDB(objectToDelete: MyBusMapSwiftUI.FavoriteRealm) {
        do {
            try realm.write {
                realm.delete(objectToDelete)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
            

}

final class MockFavStationsAuthManager: AuthManager {
    override func checkIfLogin() -> FirebaseAuth.User? {
        isLogin = false
        email = ""
        return nil
    }

    override func signIn(completion: @escaping (Result<AuthResult, Error>) -> Void) {
    }

    override func signOut() {
        isLogin = false
        email = ""
    }
}
struct FavStationsViewModelTest {

    @Test func testGetRemoteData_success() async {
        var viewModel: FavStationsViewModel = FavStationsViewModel(
            firebaseService: MockFirebaseManagerService(
                shouldReturnSuccess: true),
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager())
        await viewModel.getRemoteData(email: "")
        #expect(viewModel.favoriteList.count == 2)
    }

    @Test func testGetRemoteData_failure() async {
        var viewModel: FavStationsViewModel = FavStationsViewModel(
            firebaseService: MockFirebaseManagerService(
                shouldReturnSuccess: false),
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager())
        await viewModel.getRemoteData(email: "")
        #expect(viewModel.favoriteList.count == 0)
    }
    @Test func testDeleteRemoteData() async {
        let mockFirebaseService = MockFirebaseManagerService(
            shouldReturnSuccess: true)
        var viewModel: FavStationsViewModel = FavStationsViewModel(
            firebaseService: mockFirebaseService,
            realmManager: MockRealmManger(),
            authManager: MockFavStationsAuthManager())
        viewModel.favoriteList = mockFirebaseService.mockFavorites
        let preCount = viewModel.favoriteList.count
        let favoriteToBeDeleted = mockFirebaseService.mockFavorites[0]
        viewModel.deleteRemoteData(indexSet: IndexSet(integer: 0))
        #expect(viewModel.favoriteList.count == preCount - 1)
    }
    
    
    @Test func testDeleteLocalData() async {
        let mockFirebaseService = MockFirebaseManagerService(
            shouldReturnSuccess: true)
        let mockRealmManager = MockRealmManger()
        var viewModel: FavStationsViewModel = FavStationsViewModel(
            firebaseService: mockFirebaseService,
            realmManager: mockRealmManager,
            authManager: MockFavStationsAuthManager())
        
//        viewModel.realmFavList = mockRealmManager.readAllFromDB()
//        let preCount = viewModel.realmFavList.count
        viewModel.deleteLocalData(indexSet: IndexSet(integer: 0))
        #expect(mockRealmManager.readAllFromDB().count==1)
        #expect(viewModel.realmFavList.count == 1)
       
    }
    
    @Test func testReadLocalData() {
        let mockFirebaseService = MockFirebaseManagerService(
            shouldReturnSuccess: true)
        let mockRealmManager = MockRealmManger()
        let viewModel: FavStationsViewModel = FavStationsViewModel(
            firebaseService: mockFirebaseService,
            realmManager: mockRealmManager,
            authManager: MockFavStationsAuthManager())
        
        viewModel.readLocalData()
        #expect(viewModel.realmFavList.count == 2)
    }
}
