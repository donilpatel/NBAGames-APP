//
//  NBAGamesAppApp.swift
//  NBAGamesApp
//
//  Created by Ali Mujtaba Ahmed on 2025-05-01.
//

import SwiftUI

@main
struct NBAGamesAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()              // <- ContentView contains TabView
                .preferredColorScheme(.dark)
        }
    }
}
