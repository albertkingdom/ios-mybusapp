//
//  MapViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation
import CoreLocation
import GoogleMaps
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseFirestore


class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = MapViewModel()
    private var locationManager: CLLocationManager?
    @Published var location: CLLocation? {
        didSet {
            fetchNearByStationsWrapper()
        }
    }
    @Published var nearByStations: [NearByStation] = []
    @Published var arrivalTimes: [ArrivalTime] = []
    @Published var sortedArrivalTimes: [Int: [ArrivalTime]] = [:]
    @Published var sortedArrivalTimesForRouteName: [Int: [ArrivalTime]] = [:]
    @Published var sortedStopsForRouteName: [Int: [StopForRouteName]] = [:]
    var highlightCoordinate: [[String:Double]] = []
    var currentStationID: String = ""
    var clickedRouteName: String = ""
    var existedHighLightMarkers: [GMSMarker] = []
    var existedMarkers: [GMSMarker] = []
    @Published var isLoading: Bool = true
    let db = Firestore.firestore()
    @Published var isLogin: Bool = false
    @Published var favoriteList: [Favorite] = []
    var remotwFavoriteRouteNames: [String] = []
    
    func checkIfLogin() {
        if let _ = Auth.auth().currentUser {
            isLogin = true
            print("isLogin")
        } else {
            print("isNotLogin")
        }
    }
    
    
    
    
    
    func checkLocationAuthorization() {
        locationManager = CLLocationManager() // will call locationManagerDidChangeAuthorization method
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.delegate = self
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("notDetermined")
        case .restricted:
            print("location service is restricted")
        case .denied:
            print("location service is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("startUpdatingLocation")
            break
        @unknown default:
            break
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.location = locations.last
        print("location \(locations)")
        locationManager?.stopUpdatingLocation()
        Task {
            await fetchNearByStations()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
    func fetchNearByStationsWrapper()  {
        Task {
            await fetchNearByStations()
        }
    }
    private func fetchNearByStations() async {
        
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            
            let stations = try await NetworkManager.shared.fetchNearByStops(coordinate: coordinate, token: token)
            print("fetchNearByStations stations \(stations)")
            handleNearByStationsResponse(stations: stations)
        } catch {
            print("fetchNearByStations error \(error)")
        }
    }
    func handleNearByStationsResponse(stations: [Station]) {
        var nearbyStations: [NearByStation] = []
        var coordinates: [CLLocationCoordinate2D] = []
        
        for station in stations {
            if let index = nearbyStations.firstIndex(where: { $0.stationName == station.stationName.zhTw}) {
                // existing
                let routes = station.stops.map {
                    $0.routeName.zhTw
                }
                //
                if let indexOfSub = nearbyStations[index].subStations.firstIndex(where: { $0.stationID == station.stationID}) {
                    // existing substation
                    nearbyStations[index].subStations[indexOfSub].routes.append(contentsOf: routes)
                } else {
                    // add new substation
                    let subStation = SubStation(stationID: station.stationID,stationPosition: station.stationPosition, stationAddress: station.stationAddress, routes: routes)
                    nearbyStations[index].subStations.append(subStation)
                }
                
            } else {
                // no existing NearByStation
                let routes = station.stops.map {
                    $0.routeName.zhTw
                }
                let subStations = [SubStation(stationID: station.stationID,stationPosition: station.stationPosition, stationAddress: station.stationAddress, routes: routes)]
                nearbyStations.append(
                    NearByStation(stationName: station.stationName.zhTw, subStations: subStations)
                )
            }
        }
        DispatchQueue.main.async {
            self.nearByStations = nearbyStations
        }
        
    }
    
    func fetchArrivalTime(subStations: [SubStation]) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        //let city = "NewTaipei"
        let stationID = subStations[0].stationID
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            let city = try await NetworkManager.shared.getDistrictAsync(coordinate: coordinate, token: token)
            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeAsync(city: city.city, stationID: stationID, token: token)
            print("fetchArrivalTime  \(arrivalTimes)")
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            DispatchQueue.main.async {
                
                self.sortedArrivalTimes = sorted
                
                self.isLoading = false
            }
        } catch {
            print("fetchArrivalTime error \(error)")
        }
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
        //self.sortedArrivalTimes = sorted
        return sorted
    }
    
    func fetchArrivalTimeForRouteNameAsync(routeName: String) async {
        DispatchQueue.main.async {
            
            self.isLoading = true
        }
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            let city = try await NetworkManager.shared.getDistrictAsync(coordinate: coordinate, token: token)
            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeForRouteNameAsync(cityName: city.city, routeName: routeName, token: token)
            print("fetchArrivalTimeForRouteNameAsync  \(arrivalTimes)")
            
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            DispatchQueue.main.async {
                
                self.sortedArrivalTimesForRouteName = sorted
                self.isLoading = false
            }
        } catch {
            print("fetchArrivalTimeForRouteNameAsync error \(error)")
        }
    }
    
    func fetchStopsAsync(routeName: String) async {
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            let city = try await NetworkManager.shared.getDistrictAsync(coordinate: coordinate, token: token)
            let routes = try await NetworkManager.shared.fetchStopsAsync(cityName: city.city, routeName: routeName, token: token)
            print("fetchStopsAsync  \(routes)")
            let dict = handleStops(routes: routes)
            DispatchQueue.main.async {
                self.sortedStopsForRouteName = dict
            }
        } catch {
            print("fetchStopsAsync error \(error)")
        }
    }
    
    private func handleStops(routes: [StopOfRoute]) -> [Int: [StopForRouteName]]{
        var sorted: [Int: [StopForRouteName]] = [0: [], 1: []] // 0:'去程',1:'返程'
        for route in routes {
            if route.direction == 0 {
                sorted[0]?.append(contentsOf: route.stops)
            }
            if route.direction == 1 {
                sorted[1]?.append(contentsOf: route.stops)
            }
        }
        return sorted
    }
    
    // highlight marker
    func highlightMarker(subStations: [SubStation]) {
        var output: [[String:Double]] = []
        subStations.forEach {
            output.append(["lat": $0.stationPosition.positionLat, "lon": $0.stationPosition.positionLon])
        }
        //return output
        self.highlightCoordinate = output
    }
    func unHighlightMarker() {
        self.highlightCoordinate.removeAll()
    }
    
    func onSelectMarker(marker: GMSMarker) {
        let stationName = marker.title
        if let selectStation = nearByStations.first (where:{ station in
            station.stationName == stationName
        }) {
            Task {
                await fetchArrivalTime(subStations: selectStation.subStations)
            }
            highlightMarker(subStations: selectStation.subStations)
            currentStationID = selectStation.subStations.first?.stationID ?? ""
        }
        
        
    }
    
    func getRemoteData() {
        if let user = Auth.auth().currentUser,
           let email = user.email
        {
            let docRef = db.collection("favoriteRoute").document(email)
            
            docRef.addSnapshotListener { documentSnapshot, error in
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
                    self.remotwFavoriteRouteNames = self.favoriteList.compactMap({
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
}
