import Foundation

struct GameSummary: Identifiable, Decodable, Hashable {
    var id: String { game_id }
    let game_id: String
    let status: String
    let start_time: String
    let arena: String
    let home_team: TeamInfo
    let away_team: TeamInfo

    struct TeamInfo: Decodable, Hashable {
        let name: String?
        let abbreviation: String?
        let score: Int?
    }

    // No need for an explicit CodingKeys—they match the JSON keys
}
