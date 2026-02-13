//
//  ArtShareApp.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import SwiftUI
import Firebase

@main
struct ArtShareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured")
        
        return true
    }
}
