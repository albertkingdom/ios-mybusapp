//
//  MainView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//
import ComposableArchitecture
import CoreLocation
import SwiftUI

struct HomeView: View {
    let userStore = Store(
        initialState: UserFeature.State()
    ) {
        UserFeature()
    }
    let favoriteStore = Store(initialState: FavStations.State()) {
        FavStations()
    }
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var authManager: AuthManager

    @StateObject var mapViewModel = MapViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {

        TabView(selection: $selectedTab) {
            ContentView(viewModel: mapViewModel)
                    .tabItem {
                        Image(systemName: "map")
                        Text("地圖")
                    }.tag(0).environmentObject(locationManager)
            FavStationsView(store: favoriteStore, selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("路線蒐藏")
                    }.tag(1)
            UserView(store: userStore)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我")
                }.tag(2)
        }
        .onReceive(
            locationManager.$location,
            perform: { newLocation in
                Task {
                    await mapViewModel.fetchNearByStations(
                        location: newLocation
                            ?? CLLocation(latitude: 0, longitude: 0))
                }
            }
        )
        .onAppear {
            _ = authManager.checkIfLogin()
        }
        
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
