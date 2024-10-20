//
//  ContentView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    @State private var mapView: GMSMapView? // 保存 GMSMapView 的引用
    
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var viewModel: MapViewModel
    @State var showNearByStationSheet = true
    @State var push: Bool = false
    @State private var showHighlightMarker: Bool = false
    @State private var showLocationSearch = false
    @State var query: String = "Tap to search"
    
    
    var body: some View {
        ZStack {
            googleMapsView
            if showLocationSearch {
                PlacesSearch(showLocationSearch: $showLocationSearch,
                             location: locationManager.location,
                             query: $query
                )
                .ignoresSafeArea()
                .zIndex(5)
            }
            
            HStack {
                SearchBarView(query: $query, showLocationSearch: $showLocationSearch)
                    .padding([.horizontal], 10)
                CurrentLocationButton(onTapButton: {
                    locationManager.backToCurrentLocation()
                })
                
            }
            .padding([.horizontal], 20)
            .frame(width: UIScreen.main.bounds.width)
            .position(CGPoint(x: UIScreen.main.bounds.width/2, y: 40.0))
            
            ZStack {
                if showNearByStationSheet {
                    NearByStationSheet(
                        nearByStations: $viewModel.nearByStations,
                        showNearByStationSheet: $showNearByStationSheet,
                        clickOnStationName: onClickStationName(subStations: )
                    )
                } else {
                    ArrivalTimeSheet(
                        viewModel: ArrivalTimeSheetViewModel(location: locationManager.location, stationID: viewModel.currentStationID),
                        push: $push,
                        showNearByStationSheet: $showNearByStationSheet,
                        //                            clickOnRouteName: onClickRouteName(routeName:),
                        unHighlightMarkers: unHighlightMarker,
                        clearData: {}
                    )
                    .onDisappear {
                        print("ArrivalTimeSheet onDisappear")
                        // viewModel.sortedArrivalTimes.removeAll()
                        // viewModel.currentStationID = ""
                    }
                }
            }
            //                if push {
            //                    RouteSheet(
            //                        mapViewModel: viewModel,
            //                        push: $push,
            //                        location: $viewModel.location,
            //                        title: viewModel.clickedRouteName,
            //                        arrivalTimes: $viewModel.sortedArrivalTimesForRouteName,
            //                        stops: $viewModel.sortedStopsForRouteName
            //                    )
            //                    //                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            //                    .edgesIgnoringSafeArea(.top)
            //                    .transition(.slide)
            //                    .zIndex(1)
            //                }
        }
        .zIndex(2)
    }
    func onClickStationName(subStations: [SubStation]) {
        print("onClickStationName", subStations)
        Task {
            showNearByStationSheet = false
            viewModel.subStations = subStations
        }
        // highlight marker
        viewModel.highlightMarker(subStations: subStations)
        showHighlightMarker = true
        viewModel.currentStationID = subStations.first?.stationID ?? ""
    }
    //    func onClickRouteName(routeName: String) {
    //        print("onClickRouteName \(routeName)")
    //        viewModel.clickedRouteName = routeName
    //        Task {
    //            await viewModel.fetchArrivalTimeForRouteNameAsync(routeName: routeName)
    //            await viewModel.fetchStopsAsync(routeName: routeName)
    //        }
    //    }
    func unHighlightMarker() {
        viewModel.unHighlightMarker()
        showHighlightMarker = false
    }
    //    func clearData() {
    //        viewModel.sortedArrivalTimes.removeAll()
    //    }
    func onSelectMarker (marker: GMSMarker) {
        viewModel.onSelectMarker(marker: marker)
        showHighlightMarker = true
    }
    func onTapMyLocationButton() {
        //        viewModel.checkLocationAuthorization()
    }
}

private extension ContentView {
    var googleMapsView: some View {
        GoogleMapsView(
            mapView: $mapView,
            location: locationManager.location,
            nearByStations: $viewModel.nearByStations,
            highlightMarkersCoordinates: $viewModel.highlightCoordinate,
            existedHighLightMarkers: $viewModel.existedHighLightMarkers,
            existedMarkers: $viewModel.existedMarkers,
            showHighlightMarker: $showHighlightMarker,
            showNearByStationSheet: $showNearByStationSheet,
            onSelectMarker: onSelectMarker(marker:)
        )
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            //            viewModel.checkIfLogin()
            //            viewModel.checkLocationAuthorization()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: MapViewModel()
        )
    }
}
