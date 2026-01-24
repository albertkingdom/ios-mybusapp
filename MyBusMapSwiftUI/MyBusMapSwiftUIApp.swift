//
//  MyBusMapSwiftUIApp.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import GoogleSignIn
import SwiftUI
import FirebaseCore
import GoogleMaps
import GooglePlaces

@main
struct MyBusMapSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var locationManager = LocationManager()  // 全局單例
    @StateObject var authManager = AuthManager()
    @StateObject var firebaseManager = FirebaseManager()
    
    init() {
        GMSServices.provideAPIKey("AIzaSyCBn-VSL1_pMBJhfImXl7c7YkcfSgx-pWI")
        GMSPlacesClient.provideAPIKey("AIzaSyCBn-VSL1_pMBJhfImXl7c7YkcfSgx-pWI")
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            //            ContentView()
            HomeView()
                .environmentObject(locationManager)
                .environmentObject(authManager)
                .environmentObject(firebaseManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
