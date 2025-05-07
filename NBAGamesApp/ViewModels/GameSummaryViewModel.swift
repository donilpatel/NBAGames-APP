import Foundation
import Combine

/// Decodable wrapper for the `/games/summary` response
private struct GamesResponse: Decodable {
    let games: [GameSummary]
}

@MainActor
class GameSummaryViewModel: ObservableObject {
    @Published var games: [GameSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "http://127.0.0.1:8000"
    private var cancellables = Set<AnyCancellable>()

    /// Fetch the list of games for a given date (MM/DD/YYYY)
    func fetchGames(for date: String) {
        isLoading = true
        errorMessage = nil
        games.removeAll()

        guard let url = URL(string: "\(baseURL)/games/summary?date=\(date)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GamesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.games = response.games
            }
            .store(in: &cancellables)
    }
}
