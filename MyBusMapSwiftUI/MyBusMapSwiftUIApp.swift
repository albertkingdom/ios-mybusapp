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
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
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
