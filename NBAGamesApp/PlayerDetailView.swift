import SwiftUI
import Charts

struct PlayerDetailView: View {
    let player: Player
    @StateObject private var vm      = PlayerViewModel()
    @StateObject private var gamesVM = GameSummaryViewModel()
    @Environment(\.dismiss) private var dismiss

    // Stats state
    @State private var selectedPoint: (year: Int, pts: Double)?
    @State private var selectedSegment: Segment = .stats

    // Matches state
    @State private var matchDate   = Date()
    @State private var matchSearch = ""

    enum Segment: String, CaseIterable, Identifiable {
        case stats   = "Stats"
        case matches = "Matches"
        var id: Self { self }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                Picker("", selection: $selectedSegment) {
                    ForEach(Segment.allCases) { seg in
                        Text(seg.rawValue).tag(seg)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if selectedSegment == .stats {
                    statsView
                } else {
                    matchesView
                }
            }
            .padding(.vertical)
        }
        .background(Color.bg.ignoresSafeArea())
        .onAppear {
            vm.fetchCareer(playerId: player.id)
            vm.fetchPrediction(playerId: player.id)
            loadMatches()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.title2)
            }
            .tint(.white)
            Spacer()
            Text(player.fullName)
                .font(.largeTitle).bold().foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal)
    }

    // MARK: Stats View

    private var statsView: some View {
        VStack(spacing: 16) {
            Text(player.isActive ? "Active" : "Retired")
                .font(.subheadline)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(player.isActive ? .green : .red)
                .cornerRadius(8).foregroundColor(.white)

            careerTable
            pointsChart

            if let sel = selectedPoint {
                Text("Year: \(sel.year)   Points: \(Int(sel.pts))")
                    .font(.caption)
                    .foregroundColor(.accent)
            }

            if let err = vm.errorMessage {
                Text(err).foregroundColor(.red).padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }

    // MARK: Matches View

    private var matchesView: some View {
        VStack(spacing: 12) {
            DatePicker("Date", selection: $matchDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .foregroundColor(.white)
                .padding(.horizontal)

            Button("Load Matches") { loadMatches() }
                .buttonStyle(.borderedProminent)
                .tint(.accent)
                .padding(.horizontal)

            TextField("Filter by opponent…", text: $matchSearch)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if filteredMatches.isEmpty {
                Text("No games on \(formattedDate(matchDate))")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
            } else {
                ForEach(filteredMatches, id: \.game_id) { game in
                    GameMatchRow(game: game)
                        .padding(.horizontal)
                }
            }
        }
    }

    // MARK: – Helpers

    private func loadMatches() {
        let fmt = DateFormatter(); fmt.dateFormat = "MM/dd/yyyy"
        gamesVM.fetchGames(for: fmt.string(from: matchDate))
    }

    private var filteredMatches: [GameSummary] {
        let team = vm.careerStats.last?.teamAbbrev ?? ""
        return gamesVM.games
            .filter { $0.home_team.abbreviation == team ||
                      $0.away_team.abbreviation == team }
            .filter {
                matchSearch.isEmpty ||
                ($0.home_team.abbreviation?.contains(matchSearch.uppercased()) == true) ||
                ($0.away_team.abbreviation?.contains(matchSearch.uppercased()) == true)
            }
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateStyle = .medium
        return fmt.string(from: date)
    }

    // MARK: – Career Table

    private var careerTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Career Stats")
                .font(.headline).foregroundColor(.white)
            HStack {
                Text("Season").bold().frame(width: 80, alignment: .leading)
                Text("GP").bold().frame(width: 40)
                Text("PTS").bold().frame(width: 60)
                Text("Team").bold().frame(width: 50)
            }
            .foregroundColor(.gray)
            ForEach(vm.careerStats) { row in
                HStack {
                    Text(row.season)
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.white)
                    Text("\(row.gamesPlayed)")
                        .frame(width: 40)
                        .foregroundColor(.white)
                    Text(String(format: "%.1f", row.pts))
                        .frame(width: 60)
                        .foregroundColor(.white)
                    Text(row.teamAbbrev)
                        .frame(width: 50)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    // MARK: – Points Over Seasons Chart

    private var pointsChart: some View {
        // 1️⃣ Build numeric data
        let hist: [(year: Int, pts: Double)] = vm.careerStats.compactMap {
            guard let y = Int($0.season.prefix(4)) else { return nil }
            return (year: y, pts: $0.pts)
        }
        let pred = vm.prediction.map { (year: $0.lastSeason + 1, pts: $0.predicted) }
        let allYears = hist.map(\.year) + (pred.map { [$0.year] } ?? [])

        guard !allYears.isEmpty else { return AnyView(EmptyView()) }

        // 2️⃣ Compute domains
        let minYear = allYears.min()!
        let maxYear = allYears.max()!
        let maxPts  = max(hist.map(\.pts).max() ?? 0,
                          vm.prediction?.predicted ?? 0) * 1.1

        // 3️⃣ Last 4 season ticks
        let last4 = Array(stride(from: maxYear - 3, through: maxYear, by: 1))

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Points Over Seasons")
                    .font(.headline).foregroundColor(.white)

                Chart {
                    // Trend line
                    ForEach(hist, id: \.year) { item in
                        LineMark(
                            x: .value("Year", item.year),
                            y: .value("Points", item.pts)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.white)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                    // Prediction dot + label
                    if let p = vm.prediction {
                        PointMark(
                            x: .value("Year", p.lastSeason + 1),
                            y: .value("Points", p.predicted)
                        )
                        .symbolSize(100)
                        .foregroundStyle(.yellow)
                        .annotation(position: .top) {
                            Text("\(Int(p.predicted)) pts")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                // 4️⃣ Scales & ticks
                .chartXScale(domain: Double(minYear)...Double(maxYear))
                .chartYScale(domain: 0...maxPts)
                .chartXAxis {
                    AxisMarks(values: last4) { val in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [5]))
                        AxisTick()
                        AxisValueLabel {
                            if let yr = val.as(Int.self) {
                                Text("\(yr)")
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(); AxisTick(); AxisValueLabel()
                    }
                }
                .frame(height: 200)
                // 5️⃣ Tap to reveal prediction
                .onTapGesture {
                    if let p = vm.prediction {
                        selectedPoint = (year: p.lastSeason + 1, pts: p.predicted)
                    }
                }
            }
            .padding()
            .cardStyle()
        )
    }
}


/// A simple card‐style row for each game in “Matches”
struct GameMatchRow: View {
    let game: GameSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(game.status)
                    .font(.caption)
                    .foregroundColor(.gray)
                (Text(game.home_team.abbreviation ?? "-")
                    .font(.headline)
                 + Text(" \(game.home_team.score ?? 0)  vs  ")
                 + Text("\(game.away_team.score ?? 0) \(game.away_team.abbreviation ?? "-")"))
            }
            Spacer()
            Text(game.arena)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .cardStyle()
    }
}
