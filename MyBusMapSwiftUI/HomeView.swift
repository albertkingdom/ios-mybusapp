//
//  MainView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var firebaseManager: FirebaseManager
    @StateObject var mapViewModel = MapViewModel()
    var favStationsViewModel = FavStationsViewModel(firebaseService: FirebaseManager(), realmManager: RealmManager())
    @State private var selectedTab = 0
    var body: some View {
      
        TabView(selection: $selectedTab) {
            ContentView(viewModel: mapViewModel)
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }.tag(0).environmentObject(locationManager)
            FavStationsView(favStationsViewModel: favStationsViewModel, selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("List")
                    }.tag(1)
            UserView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("User")
                }.tag(2)
        }
        .onReceive(locationManager.$location, perform: { newLocation in
            mapViewModel.fetchNearByStationsWrapper(location: newLocation ?? CLLocation(latitude: 0, longitude: 0))
        })
        
        
            
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
