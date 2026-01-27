import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject
    var session: AppSession

    @State
    private var selectedPage: Int = Constants.initialPage

    var body: some View {
        content
    }
}

// MARK: - OnboardingView.UI
private extension OnboardingView {
    @ViewBuilder
    var content: some View {
        ZStack {
            Constants.backgroundColor.ignoresSafeArea()

            TabView(selection: $selectedPage) {
                OnboardingCardView(
                    iconName: Literals.firstCardIconName,
                    title: Literals.firstCardTitle,
                    description: Literals.firstCardDescription,
                    buttonAction: goToNextPage
                )
                .tag(Constants.firstPageTag)

                OnboardingCardView(
                    iconName: Literals.secondCardIconName,
                    title: Literals.secondCardTitle,
                    description: Literals.secondCardDescription,
                    buttonAction: goToNextPage
                )
                .tag(Constants.secondPageTag)

                OnboardingCardView(
                    iconName: Literals.thirdCardIconName,
                    title: Literals.thirdCardTitle,
                    description: Literals.thirdCardDescription,
                    buttonAction: completeOnboarding
                )
                .tag(Constants.thirdPageTag)
            }
            .tabViewStyle(Constants.tabViewStyle)
        }
        .safeAreaInset(edge: .bottom) {
            pageIndicatorBar
        }
    }

    @ViewBuilder
    var pageIndicatorBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: Constants.dotsSpacing) {
                ForEach(Constants.pagesRange, id: \.self) { index in
                    Circle()
                        .fill(index == selectedPage ? Constants.activeDotColor : Constants.inactiveDotColor)
                        .frame(width: Constants.dotSize, height: Constants.dotSize)
                        .shadow(
                            color: Constants.dotShadowColor,
                            radius: Constants.dotShadowRadius,
                            x: Constants.dotShadowX,
                            y: Constants.dotShadowY
                        )
                        .animation(Constants.dotAnimation, value: selectedPage)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.indicatorVerticalPadding)
        }
    }
}

// MARK: - OnboardingView.Actions
private extension OnboardingView {
    func goToNextPage() {
        let next = min(selectedPage + 1, Constants.lastPageTag)
        guard next != selectedPage else { return }

        withAnimation(Constants.pageChangeAnimation) {
            selectedPage = next
        }
    }

    func completeOnboarding() {
        session.onOnboardingFinished()
    }
}

// MARK: - OnboardingView.Constants
private extension OnboardingView {
    enum Constants {
        static let backgroundColor: Color = Color.Background

        static let initialPage: Int = 0

        static let firstPageTag: Int = 0
        static let secondPageTag: Int = 1
        static let thirdPageTag: Int = 2
        static let lastPageTag: Int = thirdPageTag

        static let pagesRange: Range<Int> = 0..<3

        static let tabViewStyle: PageTabViewStyle = PageTabViewStyle(indexDisplayMode: .never)

        static let dotSize: CGFloat = 18
        static let dotsSpacing: CGFloat = 18

        static let activeDotColor: Color = Color.Primary
        static let inactiveDotColor: Color = Color.Primary.opacity(0.75)

        static let dotShadowColor: Color = .black.opacity(0.20)
        static let dotShadowRadius: CGFloat = 4
        static let dotShadowX: CGFloat = 0
        static let dotShadowY: CGFloat = 3

        static let indicatorVerticalPadding: CGFloat = 14

        static let dotAnimation: Animation = .easeInOut(duration: 0.2)
        static let pageChangeAnimation: Animation = .easeInOut(duration: 0.25)
    }
}

// MARK: - OnboardingView.Literals
private extension OnboardingView {
    enum Literals {
        static let hasCompletedOnboardingKey = "hasCompletedOnboarding"

        static let firstCardIconName = "doc.text.fill"
        static let firstCardTitle = "Собирай мысли в одном месте"
        static let firstCardDescription = "Создавай заметки и структурируй их так, как удобно тебе"

        static let secondCardIconName = "square.stack.3d.up.fill"
        static let secondCardTitle = "Просто и понятно"
        static let secondCardDescription = "Управляй заметками с помощью альбомов и тем без лишних действий"

        static let thirdCardIconName = "chart.bar.fill"
        static let thirdCardTitle = "Умный анализ заметок"
        static let thirdCardDescription = "Аналитика от ИИ помогает лучше понять твою активность"
    }
}

// MARK: - OnboardingView.Previews
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
