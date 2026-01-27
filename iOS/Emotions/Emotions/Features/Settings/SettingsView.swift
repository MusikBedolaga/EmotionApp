import SwiftUI

struct SettingsView: View {
    @StateObject
    private var viewModel: SettingsViewModel

    init(session: AppSession, tokenManager: TokenManagerProtocol) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(session: session, tokenManager: tokenManager))
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("Профиль")
                    NavigationLink {
                        ProfileDetailsView()
                    } label: {
                        profileCard
                    }
                    .buttonStyle(.plain)

                    sectionHeader("УВЕДОМЛЕНИЯ")
                    notificationsCard

                    logoutCard
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - UI
private extension SettingsView {
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.secondary)
            .padding(.horizontal, 6)
    }

    var profileCard: some View {
        card {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGray3))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(Color.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Иван Иванов")
                        .font(.headline)
                        .foregroundStyle(Color(.label))

                    Text("ivan@example.com")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(16)
        }
    }

    var notificationsCard: some View {
        card {
            HStack(spacing: 12) {
                Image(systemName: "bell")
                    .foregroundStyle(Color(.label))
                    .frame(width: 22)

                Text("Уведомления")
                    .font(.body)
                    .foregroundStyle(Color(.label))

                Spacer(minLength: 0)

                Text(viewModel.notificationsEnabled ? "Вкл." : "Выкл.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)

                Toggle("", isOn: $viewModel.notificationsEnabled)
                    .labelsHidden()
            }
            .padding(16)
        }
    }

    var logoutCard: some View {
        Button {
            Task { await viewModel.logout() }
        } label: {
            card {
                HStack {
                    Spacer(minLength: 0)
                    Text("Выйти")
                        .font(.headline)
                        .foregroundStyle(Color.red)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 18)
            }
        }
        .buttonStyle(.plain)
    }

    func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Stub
private struct ProfileDetailsView: View {
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            Text("Профиль (заглушка)")
                .font(.headline)
                .foregroundStyle(Color.secondary)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

