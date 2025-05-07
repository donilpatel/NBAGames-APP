import SwiftUI

struct PlayerRow: View {
    let player: Player

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(.accent)
            VStack(alignment: .leading) {
                Text(player.fullName)
                    .font(.body)
                Text(player.isActive ? "Active" : "Retired")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .cardStyle()
    }
}
