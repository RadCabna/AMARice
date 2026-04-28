import Foundation

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Prioritize with Confidence",
            subtitle: "Stop guessing. Start calculating.",
            imageName: "onboardingImage_1",
            imageHeightRatio: 0.34,
            imageHorizontalPadding: 36,
            checklist: [],
            usesNumberedChecklist: false
        ),
        OnboardingPage(
            title: "Smart Prioritization with RICE",
            subtitle: "Four metrics. One powerful score.",
            imageName: "onboardingImage_2",
            imageHeightRatio: 0.38,
            imageHorizontalPadding: 26,
            checklist: [],
            usesNumberedChecklist: false
        ),
        OnboardingPage(
            title: "How It Works",
            subtitle: "Simple, fast, effective",
            imageName: "onboardingImage_3",
            imageHeightRatio: 0.48,
            imageHorizontalPadding: 24,
            checklist: [
                "Add your idea",
                "Enter RICE values",
                "Get instant score"
            ],
            usesNumberedChecklist: true
        ),
        OnboardingPage(
            title: "Make Data-Driven Decisions",
            subtitle: "See what matters most",
            imageName: "onboardingImage_4",
            imageHeightRatio: 0.37,
            imageHorizontalPadding: 24,
            checklist: [],
            usesNumberedChecklist: false
        ),
        OnboardingPage(
            title: "Ready to Prioritize?",
            subtitle: "Focus on what matters",
            imageName: "onboardingImage_5",
            imageHeightRatio: 0.5,
            imageHorizontalPadding: 24,
            checklist: [],
            usesNumberedChecklist: false
        )
    ]

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    func goNext() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }

    func goBack() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }
}
