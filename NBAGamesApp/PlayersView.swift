import SwiftUI

struct PlayersView: View {
    @StateObject private var vm = PlayerViewModel()
    @State private var searchText = ""

    var body: some View {
        List(vm.players) { player in
            NavigationLink(value: player) {
                PlayerRow(player: player)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search players by name")
        .onSubmit(of: .search) {
            vm.search(name: searchText)
        }
        .navigationTitle("Players")
        .navigationDestination(for: Player.self) { PlayerDetailView(player: $0) }
        .background(Color.bg)
        .animation(.easeInOut, value: vm.players)
    }
}
