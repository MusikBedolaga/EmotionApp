import SwiftUI

struct AppDefaultButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        content
    }
}

// MARK: - AppDefaultButton.UI
private extension AppDefaultButton {
    @ViewBuilder
    var content: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .surface))
                    .padding(Constants.buttonInnerPadding)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(Constants.buttonInnerCornerRadius)
            } else {
                Text(title)
                    .font(.buttonText)
                    .foregroundColor(.surface)
                    .padding(Constants.buttonInnerPadding)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(Constants.buttonInnerCornerRadius)
            }
        }
        .disabled(isLoading)
        .padding(.horizontal, Constants.buttonOuterHorizontalPadding)
        .frame(maxHeight: Constants.buttonMaxHeight)
        .background(Color.Primary)
        .cornerRadius(Constants.buttonOuterCornerRadius)
    }
}

// MARK: - AppDefaultButton.Constants
private extension AppDefaultButton {
    enum Constants {
        static let buttonInnerPadding: CGFloat = 16
        static let buttonInnerCornerRadius: CGFloat = 12

        static let buttonOuterHorizontalPadding: CGFloat = 24
        static let buttonMaxHeight: CGFloat = 46
        static let buttonOuterCornerRadius: CGFloat = 20
    }
}

// MARK: - AppDefaultButton.Literals
private extension AppDefaultButton {
    enum Literals {
        static let buttonTitle = "Далее"
    }
}

// MARK: - AppDefaultButton.Previews
#Preview {
    AppDefaultButton(title: "Далее", isLoading: false, action: {})
}
