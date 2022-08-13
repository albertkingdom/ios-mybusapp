//
//  AppDelegate.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import UIKit
import GoogleMaps
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCBn-VSL1_pMBJhfImXl7c7YkcfSgx-pWI")
        FirebaseApp.configure()
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
