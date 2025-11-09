//
//  ArrivalTimeSheetViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/2/22.
//

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct DirectionTabInfo: Identifiable {
    let id = UUID()
    let direction: Int  // The actual direction (0 or 1)
    let title: String  // "去" or "回" (should be localized)
}

@MainActor
class ArrivalTimeSheetViewModel: NSObject, ObservableObject {
    //    static let shared = ArrivalTimeSheetViewModel()
    @Published var favoriteList: [Favorite] = []
    @Published var remoteFavoriteRouteNames: [String] = []
    @Published var isLoading = true
    @Published var sortedArrivalTimes = [Int: [ArrivalTime]]()
    @Published var errorMessage: String?
    private var listenerRegistration: ListenerRegistration?
    var location: CLLocation?
    var stationID: String = ""

    var directionTabInfos: [DirectionTabInfo] {
        sortedArrivalTimes.keys.sorted().map { key in
            // TODO: Localize "去" and "回"
            DirectionTabInfo(direction: key, title: key == 0 ? "去" : "回")
        }
    }

    let db: Firestore
    let networkManager: NetworkManager

    init(
        location: CLLocation?,
        stationID: String,
        db: Firestore = Firestore.firestore(),
        networkManager: NetworkManager = NetworkManager.shared
    ) {
        self.location = location
        self.stationID = stationID
        self.isLoading = true
        self.db = db
        self.networkManager = networkManager
    }
    
    private func handleArrivalTime(arrivalTimes: [ArrivalTime]) -> [Int:
        [ArrivalTime]]
    {
        var sorted: [Int: [ArrivalTime]] = [0: [], 1: []]  // 0:'去程',1:'返程'
        for time in arrivalTimes {
            if time.direction == 0 {
                sorted[0]?.append(time)
            }
            if time.direction == 1 {
                sorted[1]?.append(time)
            }
        }
        return sorted
    }

    func fetchArrivalTime() async {
        self.isLoading = true
        guard let location = self.location else {
            self.errorMessage = "無法取得當前位置資訊。"
            self.isLoading = false
            return
        }
        let coordinate = (
            location.coordinate.latitude, location.coordinate.longitude
        )
        do {
            let city = try await networkManager.getDistrictAsync(
                from: coordinate
            )
            let arrivalTimes = try await networkManager.fetchArrivalTimeAsync(
                city: city,
                stationID: stationID
            )
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            self.sortedArrivalTimes = sorted
            self.isLoading = false
            self.errorMessage = nil  // Clear any previous error
        } catch let DecodingError.typeMismatch(type, context) {
            self.errorMessage =
                "資料解析錯誤：類型 '\(type)' 不匹配: \(context.debugDescription)"
            self.isLoading = false
        } catch {
            self.errorMessage = "獲取到站時間失敗：\(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func getRemoteData() {
        if let user = Auth.auth().currentUser,
            let email = user.email
        {
            let docRef = db.collection("favoriteRoute").document(email)

            self.listenerRegistration = docRef.addSnapshotListener {
                documentSnapshot,
                error in
                guard let document = documentSnapshot else {
                    self.errorMessage = "無法獲取收藏路線數據。"
                    return
                }
                guard let data = document.data() else {
                    self.errorMessage = "收藏路線數據為空。"
                    return
                }

                do {
                    let list = try document.data(as: FavoriteList.self)
                    self.favoriteList = list.list ?? []
                    self.remoteFavoriteRouteNames = self.favoriteList
                        .compactMap({
                            $0.name
                        })
                } catch {
                    self.errorMessage =
                        "解析收藏路線數據失敗：\(error.localizedDescription)"
                }

            }

        } else {
            self.errorMessage = "用戶未登入，無法獲取收藏路線。"
        }

    }

    deinit {
        listenerRegistration?.remove()
    }
}
