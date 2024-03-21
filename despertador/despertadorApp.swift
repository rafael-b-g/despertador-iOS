//
//  despertadorApp.swift
//  despertador
//
//  Created by Rafael Guimarães on 16/02/24.
//

import SwiftUI

@main
struct despertadorApp: App {
    @State private var connectedDevice = ConnectedDevice()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(connectedDevice)
        }
    }
}
