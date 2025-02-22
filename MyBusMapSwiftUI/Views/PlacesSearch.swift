//
//  PlacesSearch.swift
//  MyBusMapSwiftUI
//
//  Created by YKLin on 8/13/22.
//

import Foundation
import SwiftUI
import GooglePlaces

struct PlacesSearch: UIViewControllerRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var showLocationSearch: Bool
    var location: CLLocation?
    @Binding var query: String
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        // Specify the place data types to return.
        autocompleteController.placeFields = [.name, .coordinate]
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        
        filter.countries = ["TW"]
        autocompleteController.autocompleteFilter = filter
        
        autocompleteController.delegate = context.coordinator
        return autocompleteController
    }
    
    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> PlacesSearchCoordinator {
        return PlacesSearchCoordinator(
            parent: self,
            showLocationSearch: $showLocationSearch,
            location: location,
            query: $query,
            updateCurrentLocation: locationManager.updateLocation(to: )
        )
    }
    
    class PlacesSearchCoordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        let parent: PlacesSearch
        @Binding var showLocationSearch: Bool
        var location: CLLocation?
        @Binding var query: String
        var updateLocation: (CLLocation) -> Void
        
        init(parent: PlacesSearch, showLocationSearch: Binding<Bool>, location: CLLocation?, query: Binding<String>, updateCurrentLocation: @escaping (CLLocation)->Void) {
            self.parent = parent
            _showLocationSearch = showLocationSearch
            self.location = location
            _query = query
            self.updateLocation = updateCurrentLocation
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            if let name = place.name {
                query = name
            }
            let newLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            updateLocation(newLocation)
            showLocationSearch.toggle()
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
            print("didSelect prediction")
            return true
        }
        // User canceled the operation.
        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            showLocationSearch.toggle()
        }
        
        // Turn the network activity indicator on and off again.
        func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
            
        }
        
        func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
            
        }
        
    }
    typealias UIViewControllerType = GMSAutocompleteViewController
    
}
