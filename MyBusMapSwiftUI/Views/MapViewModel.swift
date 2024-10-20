//
//  MapViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation
import GoogleMaps
import FirebaseCore
import FirebaseFirestoreSwift

import SwiftUI


class MapViewModel: ObservableObject {
    var subStations: [SubStation]?
    
    @Published var nearByStations: [NearByStation] = []
    @Published var sortedArrivalTimesForRouteName: [Int: [ArrivalTime]] = [:]
    @Published var sortedStopsForRouteName: [Int: [StopForRouteName]] = [:]
    var highlightCoordinate: [[String:Double]] = [] {
        didSet {
            print("highlightCoordinate", highlightCoordinate)
        }
    }
    var currentStationID: String = ""
    var clickedRouteName: String = ""
    var existedHighLightMarkers: [GMSMarker] = []
    var existedMarkers: [GMSMarker] = []
    @Published var isLoading: Bool = true
    var remotwFavoriteRouteNames: [String] = []

    init() {
        
    }
   
    func fetchNearByStationsWrapper(location: CLLocation) {
        Task {
            await fetchNearByStations(location: location)
        }
    }
    private func fetchNearByStations(location: CLLocation) async {
        
        let coordinate = (location.coordinate.latitude ?? 0, location.coordinate.longitude ?? 0)
        do {
            
            let stations = try await NetworkManager.shared.fetchNearByStops(coordinate: coordinate)
            print("fetchNearByStations stations \(stations)")
            handleNearByStationsResponse(stations: stations)
        } catch {
            print("fetchNearByStations error \(error)")
        }
    }
    func handleNearByStationsResponse(stations: [Station]) {
        var nearbyStations: [NearByStation] = []
        
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

//    private func handleArrivalTime(arrivalTimes: [ArrivalTime]) -> [Int:[ArrivalTime]] {
//        var sorted: [Int: [ArrivalTime]] = [0: [], 1: []] // 0:'去程',1:'返程'
//        for time in arrivalTimes {
//            if time.direction == 0 {
//                sorted[0]?.append(time)
//            }
//            if time.direction == 1 {
//                sorted[1]?.append(time)
//            }
//        }
//        // self.sortedArrivalTimes = sorted
//        return sorted
//    }
    
//    func fetchArrivalTimeForRouteNameAsync(routeName: String) async {
//        DispatchQueue.main.async {
//            
//            self.isLoading = true
//        }
//        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
//        do {
//            let city = try await NetworkManager.shared.getDistrictAsync(from: coordinate)
//            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeForRouteNameAsync(cityName: city, routeName: routeName)
//            print("fetchArrivalTimeForRouteNameAsync  \(arrivalTimes)")
//            
//            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
//            DispatchQueue.main.async {
//                self.sortedArrivalTimesForRouteName = sorted
//                self.isLoading = false
//            }
//        } catch {
//            print("fetchArrivalTimeForRouteNameAsync error \(error)")
//        }
//    }
//    
//    func fetchStopsAsync(routeName: String) async {
//        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
//        do {
//            let city = try await NetworkManager.shared.getDistrictAsync(from: coordinate)
//            let routes = try await NetworkManager.shared.fetchStopsAsync(cityName: city, routeName: routeName)
//            print("fetchStopsAsync  \(routes)")
//            let dict = handleStops(routes: routes)
//            DispatchQueue.main.async {
//                self.sortedStopsForRouteName = dict
//            }
//        } catch {
//            print("fetchStopsAsync error \(error)")
//        }
//    }
    
    private func handleStops(routes: [StopOfRoute]) -> [Int: [StopForRouteName]] {
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
//                await fetchArrivalTime()
            }
            highlightMarker(subStations: selectStation.subStations)
            currentStationID = selectStation.subStations.first?.stationID ?? ""
        }
        
        
    }

}
