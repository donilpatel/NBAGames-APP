import SwiftUI

struct GameSummaryRow: View {
    let game: GameSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(game.away_team.abbreviation ?? "-") @ \(game.home_team.abbreviation ?? "-")")
                    .font(.headline)
                Text(game.arena)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(game.away_team.score ?? 0)")
                Text("\(game.home_team.score ?? 0)")
            }
        }
        .padding(8)
        .cardStyle()
    }
}
