//
//  GoogleMapsRouteView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/28/22.
//

import Foundation
import GoogleMaps
import SwiftUI

struct GoogleMapsRouteView: UIViewRepresentable {
    // when binding property changes, will call updateUIView method
    @Binding var location: CLLocation?
    @Binding var stops: [Int:[StopForRouteName]]
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.london
        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        // marker
       
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
        for marker in markers {
            marker.map = uiView
        }
       
    }
    
    
    func prepareMarkers() -> [GMSMarker]{
        var markers: [GMSMarker] = []
        guard let stopsFirst = stops[0] else { return [] }
        for stop in stopsFirst {
           
            let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: stop.stopPosition.positionLat, longitude: stop.stopPosition.positionLon)
                marker.title = stop.stopName.zhTw
                markers.append(marker)
            
        }
        return markers
    }
}

