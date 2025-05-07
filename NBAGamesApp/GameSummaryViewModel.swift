import Foundation

class GameSummaryViewModel: ObservableObject {
    @Published var games: [GameSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "http://127.0.0.1:8000"

    func fetchGames(for date: String) {
        isLoading = true
        errorMessage = nil
        let urlString = "\(baseURL)/games/summary?date=\(date)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data"
                    return
                }

                do {
                    let result = try JSONDecoder().decode([String: [GameSummary]].self, from: data)
                    self.games = result["games"] ?? []
                } catch {
                    self.errorMessage = "Failed to decode: \(error)"
                }
            }
        }.resume()
    }
}
