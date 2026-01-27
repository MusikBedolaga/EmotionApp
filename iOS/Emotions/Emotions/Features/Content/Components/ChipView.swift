import SwiftUI

struct ChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? Color.blue : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? .clear : Color.black.opacity(0.06), radius: 1.5, x: 0, y: 1)
    }
}

