//
//  ArrivalTimeSheetViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/2/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import CoreLocation



struct DirectionTabInfo: Identifiable {
    let id = UUID()
    let direction: Int // The actual direction (0 or 1)
    let title: String // "去" or "回" (should be localized)
}

@MainActor
class ArrivalTimeSheetViewModel: NSObject, ObservableObject {
//    static let shared = ArrivalTimeSheetViewModel()
    let db = Firestore.firestore()
    @Published var favoriteList: [Favorite] = []
    @Published var remoteFavoriteRouteNames: [String] = []
    @Published var isLoading = true
    @Published var sortedArrivalTimes = [Int:[ArrivalTime]]()
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
    
    init(location: CLLocation?, stationID: String) {
        self.location = location
        self.stationID = stationID
        self.isLoading = true
    }
    private func handleArrivalTime(arrivalTimes: [ArrivalTime]) -> [Int:[ArrivalTime]] {
        var sorted: [Int: [ArrivalTime]] = [0: [], 1: []] // 0:'去程',1:'返程'
        for time in arrivalTimes {
            if time.direction == 0 {
                sorted[0]?.append(time)
            }
            if time.direction == 1 {
                sorted[1]?.append(time)
            }
        }
        // self.sortedArrivalTimes = sorted
        return sorted
    }
    
    func fetchArrivalTime() async {
        self.isLoading = true
//        guard let subStations else { return }
        //let city = "NewTaipei"
//        let stationID = subStations[0].stationID
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let city = try await NetworkManager.shared.getDistrictAsync(from: coordinate)
            print("station_id: \(stationID)")
            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeAsync(city: city, stationID: stationID)
            print("fetchArrivalTime  \(arrivalTimes)")
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            self.sortedArrivalTimes = sorted
            self.isLoading = false
            self.errorMessage = nil // Clear any previous error
        } catch let DecodingError.typeMismatch(type, context) {
            self.errorMessage = "資料解析錯誤：類型 '\(type)' 不匹配: \(context.debugDescription)"
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            self.isLoading = false
        } catch {
            self.errorMessage = "獲取到站時間失敗：\(error.localizedDescription)"
            print("fetchArrivalTime error \(error)")
            self.isLoading = false
        }
    }
    
    func getRemoteData() {
        if let user = Auth.auth().currentUser,
           let email = user.email
        {
            let docRef = db.collection("favoriteRoute").document(email)
            
            self.listenerRegistration = docRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                
                do {
                    let list = try document.data(as: FavoriteList.self)
                    print("getRemoteData favoriteList \(list)")
                    self.favoriteList = list.list ?? []
                    self.remoteFavoriteRouteNames = self.favoriteList.compactMap({
                        $0.name
                    })
                }catch {
                    print(error.localizedDescription)
                }
                
            }
            
        } else {
            print("not login")
        }
        
    }
    
    deinit {
        listenerRegistration?.remove()
        print("ArrivalTimeSheetViewModel deinitialized and listener removed.")
    }
}
