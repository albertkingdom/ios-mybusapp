//
//  MapViewControllerBridge.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation
import GoogleMaps
import SwiftUI

struct GoogleMapsView: UIViewRepresentable {
    // when binding property changes, will call updateUIView method
    @Binding var location: CLLocation?
    @Binding var nearByStations: [NearByStation]
    @Binding var highlightMarkersCoordinates: [[String:Double]]
    @Binding var existedHighLightMarkers: [GMSMarker]
    @Binding var showHighlightMarker: Bool
    @Binding var showNearByStationSheet: Bool
    var onSelectMarker: (GMSMarker) -> Void
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.london
        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.main.bounds.height/2, right: 10) // adjust mylocation button position
        
        
        mapView.delegate = context.coordinator
        return mapView
    }
    func updateUIView(_ uiView: GMSMapView, context: Context) {
       
        let currentLocation = GMSCameraPosition(
            latitude: location?.coordinate.latitude ?? 0,
            longitude: location?.coordinate.longitude ?? 0,
            zoom: 15
        )
        uiView.animate(to: currentLocation)
        
        let markers = prepareMarkers()
        let highlightMarkers = prepareHighlightMarkers()
        
        for marker in markers {
            marker.map = uiView
           
        }
        if !showHighlightMarker {
            // delete all highlight markers
            for marker in existedHighLightMarkers {
                marker.map = nil
            }
            existedHighLightMarkers.removeAll()
        } else {
            // add highlight markers to map
            existedHighLightMarkers = highlightMarkers
            for marker in highlightMarkers {
                marker.map = uiView
            }
            
        }
        
       
    }
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(parent: self,
                                  showNearByStationSheet: $showNearByStationSheet,
                                  onSelectMarker: onSelectMarker)
    }
    
    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        let parent: GoogleMapsView
        @Binding var showNearByStationSheet: Bool
        var onSelectMarker: (GMSMarker) -> Void
        
        init(parent: GoogleMapsView, showNearByStationSheet: Binding<Bool>, onSelectMarker: @escaping (GMSMarker) -> Void) {
            self.parent = parent
            _showNearByStationSheet = showNearByStationSheet
            self.onSelectMarker = onSelectMarker
        }
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            print("did tap marker")
            showNearByStationSheet.toggle()
            onSelectMarker(marker)
            return false
        }
    }
    
    func prepareMarkers() -> [GMSMarker]{
        var markers: [GMSMarker] = []
        for station in nearByStations {
            for sub in station.subStations {
            let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: sub.stationPosition.positionLat, longitude: sub.stationPosition.positionLon)
                marker.title = "\(station.stationName)"
                markers.append(marker)
                
            }
        }
        return markers
    }
    func prepareHighlightMarkers() -> [GMSMarker] {
        var markers: [GMSMarker] = []
        for highlightMarker in highlightMarkersCoordinates {
            let marker = GMSMarker()
            marker.icon = GMSMarker.markerImage(with: .blue)
            marker.position = CLLocationCoordinate2D(latitude: highlightMarker["lat"] ?? 0, longitude: highlightMarker["lon"] ?? 0)
            markers.append(marker)
        }
        return markers
    }
}

extension GMSCameraPosition  {
     static var london = GMSCameraPosition.camera(withLatitude: 51.507, longitude: 0, zoom: 15)
 }
