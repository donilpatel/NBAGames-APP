import SwiftUI

extension Color {
    static let bg = Color("Background")     // very dark gray / black
    static let card = Color("Card")         // slightly lighter
    static let accent = Color("AccentColor")
}
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.card)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
    }
}
