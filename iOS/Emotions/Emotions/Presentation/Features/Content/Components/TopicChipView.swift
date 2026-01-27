import SwiftUI

struct TopicChipView: View {
    let title: String
    let colorHex: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.TextPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(colorFromHex(colorHex).opacity(0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(colorFromHex(colorHex).opacity(0.35), lineWidth: 1)
            )
    }

    private func colorFromHex(_ hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (120, 120, 120)
        }

        return Color(
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }
}

