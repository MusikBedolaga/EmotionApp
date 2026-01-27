import SwiftUI

struct AlbumCardView: View {
    let title: String
    let notesCountText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
                .lineLimit(2)

            Text(notesCountText)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

