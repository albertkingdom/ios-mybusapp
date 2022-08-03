//
//  MapViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation
import CoreLocation
import GoogleMaps

@MainActor
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = MapViewModel()
    private var locationManager: CLLocationManager?
    @Published var location: CLLocation?
    @Published var nearByStations: [NearByStation] = []
    @Published var arrivalTimes: [ArrivalTime] = []
    @Published var sortedArrivalTimes: [Int: [ArrivalTime]] = [:]
    @Published var sortedArrivalTimesForRouteName: [Int: [ArrivalTime]] = [:]
    @Published var sortedStopsForRouteName: [Int: [StopForRouteName]] = [:]
    @Published var highlightCoordinate: [[String:Double]] = []
    var currentStationID: String = ""
    var clickedRouteName: String = ""
    var existedHighLightMarkers: [GMSMarker] = []
    @Published var isLoading: Bool = true
    
    
    func checkIfLocationServiceIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager() // will call locationManagerDidChangeAuthorization method
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            
        } else {
            print("location is unavailable")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location service is restricted")
        case .denied:
            print("location service is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.location = locations.last
        print("location \(locations)")
        locationManager?.stopUpdatingLocation()
        Task {
            let stations = await fetchNearByStations()
        }
    }
    
    func fetchNearByStations() async {

        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            
            let stations = try await NetworkManager.shared.fetchNearByStops(coordinate: coordinate, token: token)
            //print("fetchNearByStations stations \(stations)")
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
        self.nearByStations = nearbyStations
        
    }
    
    func fetchArrivalTime(subStations: [SubStation]) async {
        isLoading = true
        //let city = "NewTaipei"
        let stationID = subStations[0].stationID
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            let city = try await NetworkManager.shared.getDistrictAsync(coordinate: coordinate, token: token)
            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeAsync(city: city.city, stationID: stationID, token: token)
            print("fetchArrivalTime  \(arrivalTimes)")
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            self.sortedArrivalTimes = sorted
            
            isLoading = false
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
        isLoading = true
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let token = try await NetworkManager.shared.fetchToken()
            let city = try await NetworkManager.shared.getDistrictAsync(coordinate: coordinate, token: token)
            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeForRouteNameAsync(cityName: city.city, routeName: routeName, token: token)
            print("fetchArrivalTimeForRouteNameAsync  \(arrivalTimes)")
            
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            self.sortedArrivalTimesForRouteName = sorted
            isLoading = false
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
            sortedStopsForRouteName = dict
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
        if let selectStation = nearByStations.first { station in
            station.stationName == stationName
        } {
            Task {
                await fetchArrivalTime(subStations: selectStation.subStations)
            }
            currentStationID = selectStation.subStations.first?.stationID ?? ""
        }
        
        
    }
}
