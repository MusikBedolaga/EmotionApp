import SwiftUI

struct OnboardingCardView: View {
    let iconName: String
    let title: String
    let description: String
    let buttonAction: () -> Void

    var body: some View {
        content
    }
}

// MARK: - OnboardingCardView.UI
private extension OnboardingCardView {
    @ViewBuilder
    var content: some View {
        VStack(spacing: Constants.vStackSpacing) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .foregroundColor(.Primary)
                .padding(.bottom, Constants.iconBottomPadding)

            Text(title)
                .font(Font.sectionTitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.textHorizontalPadding)

            Text(description)
                .font(.bodyText)
                .multilineTextAlignment(.center)
                .foregroundColor(.TextPrimary)
                .padding(.horizontal, Constants.textHorizontalPadding)

            Spacer()

            AppDefaultButton(title: "Далее", isLoading: false, action: buttonAction)

        }
        .padding(.vertical, Constants.cardVerticalPadding)
        .cornerRadius(Constants.cardCornerRadius)
        .shadow(radius: Constants.cardShadowRadius)
        .padding(.horizontal, Constants.cardHorizontalPadding)
    }
}

// MARK: - OnboardingCardView.Constants
private extension OnboardingCardView {
    enum Constants {
        static let vStackSpacing: CGFloat = 16

        static let iconSize: CGFloat = 150
        static let iconBottomPadding: CGFloat = 24

        static let textHorizontalPadding: CGFloat = 16
        static let cardVerticalPadding: CGFloat = 48
        static let cardHorizontalPadding: CGFloat = 24
        static let cardCornerRadius: CGFloat = 12
        static let cardShadowRadius: CGFloat = 5
    }
}

// MARK: - OnboardingCardView.Previews
struct OnboardingCardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCardView(
            iconName: "lightbulb",
            title: "Собирай мысли в одном месте",
            description: "Создавай заметки и структурируй их так, как удобно тебе",
            buttonAction: {}
        )
        .previewLayout(.sizeThatFits)
    }
}

