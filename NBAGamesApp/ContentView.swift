import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GamesView()
            }
            .tabItem {
                Label("Games", systemImage: "sportscourt")
            }

            NavigationStack {
                PlayersView()
            }
            .tabItem {
                Label("Players", systemImage: "person.3")
            }
        }
        .accentColor(.accent)   // your SharedStyles accent
    }
}
