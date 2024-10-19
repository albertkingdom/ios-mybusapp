//
//  MyBusMapSwiftUIApp.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import SwiftUI
import GoogleSignIn

@main
struct MyBusMapSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var locationManager = LocationManager() // 全局單例
    @StateObject var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            HomeView()
                .environmentObject(locationManager)
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
