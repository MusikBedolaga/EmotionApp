import SwiftUI

struct AnalyticsStubView: View {
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            Text("График будет позже")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .navigationTitle("Аналитика")
        .navigationBarTitleDisplayMode(.inline)
    }
}

