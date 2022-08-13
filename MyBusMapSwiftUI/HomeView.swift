//
//  MainView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
      
        TabView {
            ContentView()
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }
            ListView()
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
        
        
            
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
