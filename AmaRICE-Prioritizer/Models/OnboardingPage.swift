import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let imageHeightRatio: CGFloat
    let imageHorizontalPadding: CGFloat
    let checklist: [String]
    let usesNumberedChecklist: Bool
}
