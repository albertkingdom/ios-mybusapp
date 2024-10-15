//
//  ContentView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    @StateObject var viewModel = MapViewModel.shared
    @State var showNearByStationSheet = true {
        didSet {
            print("showNearByStationSheet \(showNearByStationSheet)")
        }
    }
    @State var push: Bool = false
    @State var showHighlightMarker: Bool = false
    @State var showLocationSearch = false
    @State var query: String = "Tap to search"
    @State var bottomPadding: Double = 0.0 {
        didSet {
            print("bottomPadding \(bottomPadding)")
        }
    }
    var body: some View {
            ZStack {
                googleMapsView
                if showLocationSearch {
                    PlacesSearch(showLocationSearch: $showLocationSearch,
                                 location: $viewModel.location,
                                 query: $query
                    )
                    .ignoresSafeArea()
                    .zIndex(5)
                }
                SearchBarView(query: $query, showLocationSearch: $showLocationSearch)
                ZStack {
                    if showNearByStationSheet {
                        NearByStationSheet(
                            nearByStations: $viewModel.nearByStations,
                            showNearByStationSheet: $showNearByStationSheet,
                            clickOnStationName: onClickStationName(subStations: ),
                            dynamicHeight: $bottomPadding
                        )
                    }
                    if !showNearByStationSheet {
                        ArrivalTimeSheet(
                            arrivalTimes: $viewModel.sortedArrivalTimes,
                            push: $push,
                            showNearByStationSheet: $showNearByStationSheet,
                            clickOnRouteName: onClickRouteName(routeName:),
                            unHighlightMarkers: unHighlightMarker,
                            clearData: clearData
                        )
                        .onDisappear {
                            print("ArrivalTimeSheet onDisappear")
                            // viewModel.sortedArrivalTimes.removeAll()
                            // viewModel.currentStationID = ""
                        }
                    }
                }
                if push {
                    RouteSheet(
                        push: $push,
                        location: $viewModel.location,
                        title: viewModel.clickedRouteName,
                        arrivalTimes: $viewModel.sortedArrivalTimesForRouteName,
                        stops: $viewModel.sortedStopsForRouteName
                    )
                    //                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                    .edgesIgnoringSafeArea(.top)
                    .transition(.slide)
                    .zIndex(1)
                }
            }
            .zIndex(2)
    }
    func onClickStationName(subStations: [SubStation]) {
        Task {
            viewModel.subStations = subStations
            await viewModel.fetchArrivalTime()
//            viewModel.fetchArrivalTimeRepeatedly(subStations: subStations)
        }
        // highlight marker
        viewModel.highlightMarker(subStations: subStations)
        showHighlightMarker = true
        viewModel.currentStationID = subStations.first?.stationID ?? ""
    }
    func onClickRouteName(routeName: String) {
        print("onClickRouteName \(routeName)")
        viewModel.clickedRouteName = routeName
        Task {
            await viewModel.fetchArrivalTimeForRouteNameAsync(routeName: routeName)
            await viewModel.fetchStopsAsync(routeName: routeName)
        }
    }
    func unHighlightMarker() {
        viewModel.unHighlightMarker()
        showHighlightMarker = false
    }
    func clearData() {
        viewModel.sortedArrivalTimes.removeAll()
    }
    func onSelectMarker (marker: GMSMarker) {
        viewModel.onSelectMarker(marker: marker)
        showHighlightMarker = true
    }
    func onTapMyLocationButton() {
        viewModel.checkLocationAuthorization()
    }
}

private extension ContentView {
    var googleMapsView: some View {
        GoogleMapsView(location: $viewModel.location,
                       nearByStations: $viewModel.nearByStations,
                       highlightMarkersCoordinates: $viewModel.highlightCoordinate,
                       existedHighLightMarkers: $viewModel.existedHighLightMarkers,
                       existedMarkers: $viewModel.existedMarkers,
                       showHighlightMarker: $showHighlightMarker,
                       showNearByStationSheet: $showNearByStationSheet,
                       bottomPadding: $bottomPadding,
                       onSelectMarker: onSelectMarker(marker:),
                       onTapMyLocationBtn: onTapMyLocationButton
        )
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            viewModel.checkIfLogin()
            viewModel.checkLocationAuthorization()
        }
    }
}

struct SearchBarView: View {
    @Binding var query: String
    @Binding var showLocationSearch: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showLocationSearch = true
                }, label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.primary)
                        Text(query)
                            .foregroundColor(Color.gray)
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .onTapGesture {
                                query = "Tap to search"
                            }
                    }
                    .padding(.horizontal, 10)
                })
                .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                .background(Color.white)
                Spacer()
            }
            Spacer()
        }
        .padding(.top, 30)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
