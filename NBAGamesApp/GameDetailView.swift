import SwiftUI

struct GameDetailView: View {
    let game: GameSummary
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("Status: \(game.status)")
                Text("Starts at: \(game.start_time)")
                Text("Arena: \(game.arena)")
            }
            .multilineTextAlignment(.center)
            .font(.body)
            .foregroundColor(.white)
            .padding()

            Spacer()

            HStack(spacing: 60) {
                TeamScoreView(title: "Home", info: game.home_team)
                TeamScoreView(title: "Away", info: game.away_team)
            }

            Spacer()
        }
        .navigationTitle("Game Details")
        .navigationBarTitleDisplayMode(.inline)
        // Hide the default “< PreviousTitle” button
        .navigationBarBackButtonHidden(true)
        // Insert only the “<” icon
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .tint(.white)
            }
        }
        .toolbarBackground(Color.bg, for: .navigationBar)
        .toolbarBackground(.visible,   for: .navigationBar)
        .toolbarColorScheme(.dark,     for: .navigationBar)
        .background(Color.bg.ignoresSafeArea())
    }
}

fileprivate struct TeamScoreView: View {
    let title: String
    let info: GameSummary.TeamInfo

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(info.abbreviation ?? "-")
                .font(.title2)
                .foregroundColor(.white)

            Text("\(info.score ?? 0)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
