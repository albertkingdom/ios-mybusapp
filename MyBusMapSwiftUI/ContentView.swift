//
//  ContentView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import GoogleMaps
import SwiftUI

struct ContentView: View {
    @State private var mapView: GMSMapView? // 保存 GMSMapView 的引用
    
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var viewModel: MapViewModel
    @State var push: Bool = false

    var body: some View {
        ZStack {
            googleMapsView
            if viewModel.showLocationSearch {
                PlacesSearch(showLocationSearch: $viewModel.showLocationSearch,
                             location: locationManager.location,
                             query: $viewModel.query
                )
                .ignoresSafeArea()
                .zIndex(5)
            }
            
            SearchAndLocationBar(
                query: $viewModel.query,
                showLocationSearch: $viewModel.showLocationSearch,
                onCurrentLocationTap: {
                    locationManager.backToCurrentLocation()
                }
            )
            
            ZStack {
                if viewModel.showNearByStationSheet {
                    NearByStationSheet(
                        nearByStations: $viewModel.nearByStations,
                        showNearByStationSheet: $viewModel.showNearByStationSheet,
                        clickOnStationName: viewModel.onClickStationName(subStations: )
                    )
                } else {
                    ArrivalTimeSheet(
                        viewModel: ArrivalTimeSheetViewModel(
                            location: locationManager.location,
                            stationID: viewModel.currentStationID
                        ),
                        push: $push,
                        showNearByStationSheet: $viewModel.showNearByStationSheet,
                        unHighlightMarkers: viewModel.unHighlightMarker,
                        clearData: {}
                    )
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
   
    //    func onClickRouteName(routeName: String) {
    //        print("onClickRouteName \(routeName)")
    //        viewModel.clickedRouteName = routeName
    //        Task {
    //            await viewModel.fetchArrivalTimeForRouteNameAsync(routeName: routeName)
    //            await viewModel.fetchStopsAsync(routeName: routeName)
    //        }
    //    }
    
    //    func clearData() {
    //        viewModel.sortedArrivalTimes.removeAll()
    //    }

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
            showHighlightMarker: $viewModel.shouldShowHighlightMarker,
            showNearByStationSheet: $viewModel.showNearByStationSheet,
            onSelectMarker: viewModel.onSelectMarker(marker:)
        )
        .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            viewModel: MapViewModel()
        )
    }
}
