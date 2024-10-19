//
//  RouteSheetViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/17.
//

import Foundation
import CoreLocation


class RouteSheetViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var sortedArrivalTimesForRouteName: [Int: [ArrivalTime]] = [:]
    var location: CLLocation?
    var routeName: String = ""
    
    init(routeName: String, location: CLLocation?) {
       
        self.routeName = routeName
        self.location = location
    }
    
    func fetchArrivalTimeForRouteNameAsync() async {
        DispatchQueue.main.async {
            
            self.isLoading = true
        }
        let coordinate = (location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0)
        do {
            let city = try await NetworkManager.shared.getDistrictAsync(from: coordinate)
            let arrivalTimes = try await NetworkManager.shared.fetchArrivalTimeForRouteNameAsync(cityName: city, routeName: routeName)
            
            let sorted = handleArrivalTime(arrivalTimes: arrivalTimes)
            DispatchQueue.main.async {
                self.sortedArrivalTimesForRouteName = sorted
                self.isLoading = false
            }
        } catch {
            print("fetchArrivalTimeForRouteNameAsync error \(error)")
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
        // self.sortedArrivalTimes = sorted
        return sorted
    }
}
