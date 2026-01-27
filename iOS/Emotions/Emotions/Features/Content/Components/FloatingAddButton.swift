import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(.systemBlue))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Создать альбом")
    }
}

