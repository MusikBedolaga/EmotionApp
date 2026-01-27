import SwiftUI

struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 12
    var shakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            travelDistance * sin(animatableData * .pi * shakes), y: 0
        ))
    }
}

struct AuthView: View {
    @EnvironmentObject
    var session: AppSession

    @StateObject
    var viewModel: AuthViewModel

    @State
    private var isAlertPresented = false

    let initialAuthMode: AppRoute.AuthMode

    init(viewModel: AuthViewModel, initialAuthMode: AppRoute.AuthMode) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.initialAuthMode = initialAuthMode
    }

    var body: some View {
        content
            .onAppear {
                viewModel.isRegistering = (initialAuthMode == .signUp)
            }
            .onChange(of: viewModel.errorMessage) {
                if viewModel.errorMessage != nil {
                    isAlertPresented = true
                }
            }
            .alert(isPresented: $isAlertPresented) {
                Alert(
                    title: Text(Literals.errorTitle),
                    message: Text(viewModel.friendlyError),
                    dismissButton: .default(Text(Literals.okButtonText)) { viewModel.errorMessage = nil }
                )   
            }
    }
}

// MARK: - AuthView.UI
private extension AuthView {
    @ViewBuilder
    var content: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: Constants.contentGap) {
                header
                textFields
                buttons
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    var header: some View {
        Spacer()
        Image(systemName: Literals.iconSystemName)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.iconSize, height: Constants.iconSize)
            .foregroundColor(.primary)
        Text(Literals.iconTitle)
            .font(.largeTitle)
            .foregroundColor(.textPrimary)
    }

    @ViewBuilder
    var textFields: some View {
        if viewModel.isRegistering {
            TextField(Literals.namePlaceholder, text: $viewModel.name)
                .textFieldStyle(AppTextFieldStyle())
                .overlay(
                    viewModel.shouldShakeName ? RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 2) : nil
                )
                .modifier(ShakeEffect(animatableData: viewModel.shouldShakeName ? 1 : 0))
        }
        TextField(viewModel.isRegistering ? Literals.emailPlaceholder : Literals.emailOrUsernamePlaceholder, text: $viewModel.email)
            .textFieldStyle(AppTextFieldStyle())
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .overlay(
                viewModel.shouldShakeEmail ? RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 2) : nil
            )
            .modifier(ShakeEffect(animatableData: viewModel.shouldShakeEmail ? 1 : 0))
        SecureField(Literals.passwordPlaceholder, text: $viewModel.password)
            .textFieldStyle(AppTextFieldStyle())
            .overlay(
                viewModel.shouldShakePassword ? RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 2) : nil
            )
            .modifier(ShakeEffect(animatableData: viewModel.shouldShakePassword ? 1 : 0))
        if viewModel.isRegistering {
            SecureField(Literals.repeatPasswordPlaceholder, text: .constant(""))
                .textFieldStyle(AppTextFieldStyle())
        }
    }

    @ViewBuilder
    var buttons: some View {
        AppDefaultButton(
            title: viewModel.isRegistering ? Literals.signUpButtonTitle : Literals.signInButtonTitle,
            isLoading: viewModel.isLoading
        ) {
            Task {
                let success: Bool
                if viewModel.isRegistering {
                    success = await viewModel.signUp()
                } else {
                    success = await viewModel.signIn()
                }
                if success {
                    session.onAuthSuccess()
                }
            }
        }
        .padding(.top)
        Button(action: {
            viewModel.isRegistering.toggle()
            viewModel.errorMessage = nil
        }) {
            Text(viewModel.isRegistering ? Literals.signInButtonText : Literals.signUpButtonText)
                .foregroundColor(.textSecondary)
        }
        .padding(.bottom)
        Spacer()
    }
}

// MARK: - AuthViewConstants
private extension AuthView {
    enum Constants {
        static let contentGap: CGFloat = 24
        static let iconSize: CGFloat = 100
    }
}
// MARK: - AuthViewLiterals
private extension AuthView {
    enum Literals {
        static let iconSystemName = "person.circle.fill"
        static let iconTitle = "Иконка"
        static let namePlaceholder = "Введите имя"
        static let emailOrUsernamePlaceholder = "Введите имя пользователя или email"
        static let emailPlaceholder = "Введите email"
        static let passwordPlaceholder = "Введите пароль"
        static let repeatPasswordPlaceholder = "Повторите пароль"
        static let signInButtonTitle = "Войти"
        static let signUpButtonTitle = "Создать аккаунт"
        static let signInButtonText = "Уже есть аккаунт? Войти"
        static let signUpButtonText = "Нет аккаунта? Регистрация"
        static let errorTitle = "Ошибка"
        static let okButtonText = "OK"
            }
        }
// MARK: - AuthView.AppTextFieldStyle
private struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.surface)
            .cornerRadius(10)
            .foregroundColor(.textPrimary)
    }
}
