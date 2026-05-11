import SwiftUI

struct SettingsView: View {
    @StateObject
    private var viewModel: SettingsViewModel

    init(session: AppSession) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(session: session))
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("Профиль")
                    NavigationLink {
                        ProfileDetailsView(user: viewModel.user)
                    } label: {
                        profileCard
                    }
                    .buttonStyle(.plain)

                    sectionHeader("Тема")
                    themeCard

                    sectionHeader("Уведомления")
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
        SettingsCard {
            HStack(spacing: 12) {
                UserAvatarView(user: viewModel.user, size: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.displayName)
                        .font(.headline)
                        .foregroundStyle(Color(.label))

                    Text(viewModel.user.secondaryText)
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

    var themeCard: some View {
        SettingsCard {
            Picker("Тема", selection: $viewModel.selectedTheme) {
                ForEach(SettingsTheme.allCases) { theme in
                    Text(theme.title).tag(theme)
                }
            }
            .pickerStyle(.segmented)
            .padding(16)
        }
    }

    var notificationsCard: some View {
        SettingsCard {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge")
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
            SettingsCard {
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
}

private struct SettingsCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

private struct UserAvatarView: View {
    let user: SessionUser
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.14))
            .frame(width: size, height: size)
            .overlay(avatarContent)
    }

    @ViewBuilder
    private var avatarContent: some View {
        if user.initials.isEmpty {
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(Color.blue)
        } else {
            Text(user.initials)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundStyle(Color.blue)
        }
    }
}

private struct ProfileDetailsView: View {
    let user: SessionUser

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard

                    sectionHeader("Основная информация")
                    detailsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileDetailsView {
    var headerCard: some View {
        SettingsCard {
            VStack(spacing: 16) {
                UserAvatarView(user: user, size: 84)

                VStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.label))

                    Text(user.secondaryText)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
        }
    }

    var detailsCard: some View {
        SettingsCard {
            VStack(spacing: 0) {
                detailRow(title: "Имя пользователя", value: user.username)
                Divider()
                detailRow(title: "Email", value: user.emailText)
                Divider()
                detailRow(title: "ID пользователя", value: user.idText)
            }
        }
    }

    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.secondary)
            .padding(.horizontal, 6)
    }

    func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondary)

            Text(value)
                .font(.body)
                .foregroundStyle(Color(.label))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

