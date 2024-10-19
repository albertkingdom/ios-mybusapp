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
    @StateObject var mapViewModel = MapViewModel()
    var body: some View {
      
        TabView {
            ContentView(viewModel: mapViewModel)
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }
            FavStationsView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("List")
                    }
            UserView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("User")
                }
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
