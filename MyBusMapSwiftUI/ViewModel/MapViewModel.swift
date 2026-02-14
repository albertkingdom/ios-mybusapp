//
//  MapViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import FirebaseCore
import FirebaseFirestoreSwift
import Foundation
import GoogleMaps
import SwiftUI

class MapViewModel: ObservableObject {
    private var subStations: [SubStation]?

    @Published var nearByStations: [NearByStation] = []
    @Published var sortedArrivalTimesForRouteName: [Int: [ArrivalTime]] = [:]
    @Published var sortedStopsForRouteName: [Int: [StopForRouteName]] = [:]
    @Published var highlightCoordinate: [[String: Double]] = []
    var currentStationID: String = ""
    private var clickedRouteName: String = ""
    var existedHighLightMarkers: [GMSMarker] = []
    var existedMarkers: [GMSMarker] = []
    @Published var isLoading: Bool = true
    private var remotwFavoriteRouteNames: [String] = []
    @Published var showNearByStationSheet: Bool = true
    @Published var shouldShowHighlightMarker: Bool = false
    @Published var showLocationSearch: Bool = false
    @Published var query: String = "Tap to search"

    init() {
    }

    func fetchNearByStations(location: CLLocation) async {
        let coordinate = (
            location.coordinate.latitude, location.coordinate.longitude
        )
        do {
            let stations = try await NetworkManager.shared.fetchNearByStops(
                coordinate: coordinate)
            handleNearByStationsResponse(stations: stations)
        } catch {
            print("fetchNearByStations error \(error)")
        }
    }

    private func handleNearByStationsResponse(stations: [Station]) {
        var nearbyStationsDict: [String: NearByStation] = [:]

        stations.forEach { station in
            let stationName = station.stationName.zhTw
            let routes = station.stops.map { $0.routeName.zhTw }

            if var existedNearByStation = nearbyStationsDict[stationName] {
                if let subStationIndex = existedNearByStation.subStations
                    .firstIndex(where: { $0.stationID == station.stationID }) {
                    existedNearByStation.subStations[subStationIndex].routes
                        .append(contentsOf: routes)
                } else {
                    let subStation = SubStation(
                        stationID: station.stationID,
                        stationPosition: station.stationPosition,
                        stationAddress: station.stationAddress,
                        routes: routes
                    )
                    existedNearByStation.subStations.append(subStation)
                }
                nearbyStationsDict[stationName] = existedNearByStation
            } else {
                let subStation = SubStation(
                    stationID: station.stationID,
                    stationPosition: station.stationPosition,
                    stationAddress: station.stationAddress,
                    routes: routes
                )
                nearbyStationsDict[stationName] = NearByStation(
                    stationName: stationName, subStations: [subStation])
            }
        }
        let nearbyStations = Array(nearbyStationsDict.values)

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

    //    private func handleStops(routes: [StopOfRoute]) -> [Int: [StopForRouteName]] {
    //        var sorted: [Int: [StopForRouteName]] = [0: [], 1: []] // 0:'去程',1:'返程'
    //        for route in routes {
    //            if route.direction == 0 {
    //                sorted[0]?.append(contentsOf: route.stops)
    //            }
    //            if route.direction == 1 {
    //                sorted[1]?.append(contentsOf: route.stops)
    //            }
    //        }
    //        return sorted
    //    }

    // highlight marker
    func highlightMarker(subStations: [SubStation]) {
        var output: [[String: Double]] = []
        subStations.forEach {
            output.append([
                "lat": $0.stationPosition.positionLat,
                "lon": $0.stationPosition.positionLon
            ])
        }
        // return output
        self.highlightCoordinate = output
    }

    func unHighlightMarker() {
        self.highlightCoordinate.removeAll()
        shouldShowHighlightMarker = false
    }

    func onSelectMarker(marker: GMSMarker) {
        let stationName = marker.title
        if let selectStation = nearByStations.first(where: { station in
            station.stationName == stationName
        }) {
            highlightMarker(subStations: selectStation.subStations)
            currentStationID = selectStation.subStations.first?.stationID ?? ""
        }
        shouldShowHighlightMarker = true
    }

    func onClickStationName(subStations: [SubStation]) {
        Task {
            await MainActor.run {
                showNearByStationSheet = false
                self.subStations = subStations
            }
        }
        highlightMarker(subStations: subStations)
        shouldShowHighlightMarker = true
        currentStationID = subStations.first?.stationID ?? ""
    }
}
