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
    @Binding var showLocationSearch: Bool
    @Binding var location: CLLocation?
    @Binding var query: String
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        
        filter.country = "TW"
        autocompleteController.autocompleteFilter = filter
        
        autocompleteController.delegate = context.coordinator
        return autocompleteController
    }
    
    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> PlacesSearchCoordinator {
        return PlacesSearchCoordinator(parent: self, showLocationSearch: $showLocationSearch, location: $location, query: $query)
    }
    
    class PlacesSearchCoordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        let parent: PlacesSearch
        @Binding var showLocationSearch: Bool
        @Binding var location: CLLocation?
        @Binding var query: String
        
        init(parent: PlacesSearch, showLocationSearch: Binding<Bool>, location: Binding<CLLocation?>, query: Binding<String>) {
            self.parent = parent
            _showLocationSearch = showLocationSearch
            _location = location
            _query = query
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            print("didAutocompleteWith")
            print("Place name: \(place.name)")
               print("Place ID: \(place.placeID)")
               print("Place attributions: \(place.attributions)")
            print("Place coord: \(place.coordinate)")
//            dismiss(animated: true, completion: nil)
            if let name = place.name {
                query = name
            }
            location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
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
