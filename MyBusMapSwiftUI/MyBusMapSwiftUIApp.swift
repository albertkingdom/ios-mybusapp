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
    
    /// Detect if running in unit test environment
    private var isRunningTests: Bool {
        NSClassFromString("XCTestCase") != nil
    }
    
    init() {
        // Skip initialization when running tests
        guard !isRunningTests else { return }
        
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
        // Prevent crash if key is missing or placeholder "ci"
        if !apiKey.isEmpty && apiKey != "ci" {
            GMSServices.provideAPIKey(apiKey)
            GMSPlacesClient.provideAPIKey(apiKey)
        }
        if FirebaseApp.app() == nil {
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: path) {
                FirebaseApp.configure(options: options)
            } else {
                FirebaseApp.configure()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if isRunningTests {
                // Show empty view during tests to avoid Firebase dependencies
                EmptyView()
            } else {
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
}
