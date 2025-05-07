import Foundation

/// Represents an NBA player.
struct Player: Identifiable, Decodable, Hashable {
    let id: Int
    let fullName: String
    let firstName: String
    let lastName: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case fullName  = "full_name"
        case firstName = "first_name"
        case lastName  = "last_name"
        case isActive  = "is_active"
    }
}
