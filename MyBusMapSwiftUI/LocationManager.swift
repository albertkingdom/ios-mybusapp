//
//  LocationManager.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    private var locationManager: CLLocationManager?
    
    override init() {
        super.init()
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        locationManager = CLLocationManager() // will call locationManagerDidChangeAuthorization method
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.delegate = self
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
        @unknown default:
            break
        }
    }
    func backToCurrentLocation() {
        locationManager?.startUpdatingLocation()
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
    
    func fetchNearByStations() async {
        // Your asynchronous fetching logic here
    }
    
    func updateLocation(to location: CLLocation) {
        
        self.location = location
    }
}
