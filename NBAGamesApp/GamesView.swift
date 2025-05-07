import SwiftUI

struct GamesView: View {
    @StateObject private var vm = GameSummaryViewModel()
    @State private var selectedDate = Date()
    @State private var searchText = ""

    // filter by team abbreviation or arena name
    private var filteredGames: [GameSummary] {
        vm.games.filter { game in
            searchText.isEmpty ||
            (game.home_team.abbreviation?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (game.away_team.abbreviation?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            game.arena.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Date + Refresh
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                Spacer()
                Button {
                    loadGames()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            // Search bar
            List {
                ForEach(filteredGames) { game in
                    NavigationLink(value: game) {
                        GameSummaryRow(game: game)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Filter by team or arena")
            .animation(.easeInOut, value: filteredGames)

        }
        .navigationTitle("Games")
        .background(Color.bg)
        .onAppear { loadGames() }
        .navigationDestination(for: GameSummary.self) { GameDetailView(game: $0) }
    }

    private func loadGames() {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        vm.fetchGames(for: fmt.string(from: selectedDate))
    }
}
