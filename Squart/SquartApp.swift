//
//  SquartApp.swift
//  Squart
//
//  Created by Gazza on 9. 5. 2026..
//

import SwiftUI

@main
struct SquartApp: App {
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var iconManager = AppIconManager.shared

    var body: some Scene {
        WindowGroup {
            LaunchTransitionView {
                RootView()
            }
            .environmentObject(storeManager)
            .environmentObject(iconManager)
        }
    }
}
