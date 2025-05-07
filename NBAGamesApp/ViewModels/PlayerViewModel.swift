// File: ViewModels/PlayerViewModel.swift

import Foundation
import Combine

// MARK: - CareerRow

struct CareerRow: Identifiable, Decodable, Hashable {
    var id: String { season }
    let season:      String   // e.g. "2024"
    let pts:         Double   // total points
    let gamesPlayed: Int      // GP
    let teamAbbrev:  String   // TEAM_ABBREVIATION

    enum CodingKeys: String, CodingKey {
        case season       = "SEASON_ID"
        case pts          = "PTS"
        case gamesPlayed  = "GP"
        case teamAbbrev   = "TEAM_ABBREVIATION"
    }
}

// MARK: - Prediction

struct Prediction: Decodable {
    let lastSeason: Int
    let predicted:  Double

    enum CodingKeys: String, CodingKey {
        case lastSeason = "last_season"
        case predicted  = "predicted_points_next_season"
    }
}

// MARK: - ViewModel

@MainActor
class PlayerViewModel: ObservableObject {
    // MARK: Published

    @Published var players:     [Player]     = []
    @Published var careerStats: [CareerRow] = []
    @Published var prediction:  Prediction? = nil
    @Published var errorMessage:String?     = nil

    // MARK: Private

    private let baseURL = "http://127.0.0.1:8000"
    private var cancellables = Set<AnyCancellable>()

    // MARK: Search

    func search(name: String) {
        errorMessage = nil
        players.removeAll()

        guard let url = URL(string: "\(baseURL)/players/search?name=\(name)") else {
            self.errorMessage = "Invalid search URL."
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Player].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    self.errorMessage = "Search failed: \(err.localizedDescription)"
                }
            } receiveValue: { results in
                self.players = results
            }
            .store(in: &cancellables)
    }

    // MARK: Career Stats

    struct CareerResponse: Decodable {
        let SeasonTotalsRegularSeason: [CareerRow]
    }

    func fetchCareer(playerId: Int) {
        errorMessage = nil
        careerStats.removeAll()

        guard let url = URL(string: "\(baseURL)/player/\(playerId)/career") else {
            self.errorMessage = "Invalid career URL."
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CareerResponse.self, decoder: JSONDecoder())
            .map { $0.SeasonTotalsRegularSeason }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    self.errorMessage = "Failed to load stats: \(err.localizedDescription)"
                }
            } receiveValue: { rows in
                self.careerStats = rows
            }
            .store(in: &cancellables)
    }

    // MARK: Prediction

    // in PlayerViewModel.swift

    func fetchPrediction(playerId: Int) {
        errorMessage = nil
        prediction = nil

        guard let url = URL(string: "\(baseURL)/player/\(playerId)/predict") else {
            errorMessage = "Invalid prediction URL."
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
          .map(\.data)
          // If backend returns {"error": "..."} we’ll treat that as a thrown NSError
          .tryMap { data in
            if let dict = try? JSONDecoder().decode([String:String].self, from: data),
               let msg = dict["error"] {
                throw NSError(domain: "", code: 0,
                              userInfo: [NSLocalizedDescriptionKey: msg])
            }
            return data
          }
          // Attempt to decode Prediction – any failure here (including missing keys)
          // will be replaced with nil
          .decode(type: Prediction.self, decoder: JSONDecoder())
          .map(Optional.some)
          .replaceError(with: nil)
          .receive(on: DispatchQueue.main)
          .assign(to: &$prediction)
    }

}
