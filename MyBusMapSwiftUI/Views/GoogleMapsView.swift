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
    @Binding var existedMarkers: [GMSMarker]
    @Binding var showHighlightMarker: Bool
    @Binding var showNearByStationSheet: Bool
    @Binding var bottomPadding: Double
    var onSelectMarker: (GMSMarker) -> Void
    var onTapMyLocationBtn: () -> Void
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.london
        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        
//        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding+50, right: 10) // adjust mylocation button position
        print("bottomPadding \(bottomPadding)")
        
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

        updateMarkersOnMap(uiView: uiView)
        
        updateHighlightMarkersOnMap(uiView: uiView)
    
//        moveLocationButton(uiView)
        uiView.settings.myLocationButton = true
        let padding=bottomPadding+Double(100)
        uiView.padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: padding, right: 10.0) // adjust mylocation button position

    }
    private func moveLocationButton(_ mapView: GMSMapView) {
            for object in mapView.subviews {
                if object.thisClassName == "GMSUISettingsPaddingView" {
                    for view in object.subviews {
                        if view.thisClassName == "GMSUISettingsView" {
                            for btn in view.subviews {
                                if btn.thisClassName == "GMSx_MDCFloatingButton" {
                                    var frame = btn.frame
                                    frame.origin.x += 50
                                    frame.origin.y += 200
                                    btn.frame = frame
                                }
                            }
                        }
                    }
                }
            }
        }
    
    func updateMarkersOnMap(uiView: GMSMapView) {
        let markers = prepareMarkers()
        // delete all existed markers from map
        for marker in existedMarkers {
            marker.map = nil
        }
        // save a copy of new markers
        existedMarkers = markers
        // put markers on map
        for marker in markers {
            marker.map = uiView
           
        }
    }
    func updateHighlightMarkersOnMap(uiView: GMSMapView) {
        if !showHighlightMarker {
            // delete all highlight markers
            existedHighLightMarkers.forEach { marker in
                marker.map = nil
            }
            existedHighLightMarkers.removeAll()
        } else {
            let highlightMarkers = prepareHighlightMarkers()
            // add highlight markers to map
            existedHighLightMarkers.removeAll()
           
            existedHighLightMarkers.append(contentsOf: highlightMarkers)

            existedHighLightMarkers.forEach({$0.map = uiView})
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(parent: self,
                                  showNearByStationSheet: $showNearByStationSheet,
                                  onSelectMarker: onSelectMarker,
                                  location: $location,
                                  onTapMyLocationBtn: onTapMyLocationBtn
        )
    }
    
    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        let parent: GoogleMapsView
        @Binding var showNearByStationSheet: Bool
        var onSelectMarker: (GMSMarker) -> Void
        @Binding var locationSource: CLLocation?
        var onTapMyLocationBtn: () -> Void
        
        init(parent: GoogleMapsView,
             showNearByStationSheet: Binding<Bool>,
             onSelectMarker: @escaping (GMSMarker) -> Void,
             location: Binding<CLLocation?>,
             onTapMyLocationBtn: @escaping () -> Void
        ) {
            self.parent = parent
            _showNearByStationSheet = showNearByStationSheet
            self.onSelectMarker = onSelectMarker
            _locationSource = location
            self.onTapMyLocationBtn = onTapMyLocationBtn
        }
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            print("did tap marker")
            showNearByStationSheet.toggle()
            onSelectMarker(marker)
            return false
        }
        func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
            onTapMyLocationBtn()
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
        print("prepareMarkers \(markers)")
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
        print("prepareHighlightMarkers markers \(markers)")
        return markers
    }
}

extension GMSCameraPosition  {
     static var london = GMSCameraPosition.camera(withLatitude: 51.507, longitude: 0, zoom: 15)
 }
extension NSObject {
    var thisClassName: String {
        return NSStringFromClass(type(of: self))
    }
}
