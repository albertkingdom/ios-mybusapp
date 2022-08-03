//
//  MyBusMapSwiftUIApp.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import SwiftUI

@main
struct MyBusMapSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
//            ContentView()
            HomeView()
        }
    }
}
