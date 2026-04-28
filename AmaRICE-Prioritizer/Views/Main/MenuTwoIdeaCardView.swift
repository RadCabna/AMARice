import SwiftUI

struct MenuTwoIdeaCardView: View {
    let idea: IdeaItem

    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            HStack(alignment: .top, spacing: screenHeight * 0.014) {
                VStack(spacing: screenHeight * 0.002) {
                    Text("\(idea.riceScore)")
                        .font(.outfitMedium(size: screenHeight * 0.032))
                        .foregroundStyle(.white)
                    Text("RICE")
                        .font(.outfitLight(size: screenHeight * 0.012))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .frame(width: screenHeight * 0.09, height: screenHeight * 0.09)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.018)
                        .fill(riceScoreColor)
                )

                VStack(alignment: .leading, spacing: screenHeight * 0.008) {
                    HStack {
                        Text(idea.title)
                            .font(.outfitMedium(size: screenHeight * 0.028))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        statusPill
                    }

                    Text(idea.details.isEmpty ? "No description" : idea.details)
                        .font(.outfitLight(size: screenHeight * 0.016))
                        .foregroundStyle(.black.opacity(0.65))
                        .lineLimit(2)
                }
            }

            HStack(spacing: screenHeight * 0.007) {
                metric(
                    title: "Reach",
                    value: "\(formatNumber(idea.reach))",
                    iconName: "reachIcon",
                    color: Color("appColor_1")
                )
                metric(
                    title: "Impact",
                    value: "\(formatNumber(idea.impact))x",
                    iconName: "impactIcon",
                    color: Color("appColor_4")
                )
                metric(
                    title: "Confidence",
                    value: "\(Int((idea.confidence * 100).rounded()))%",
                    iconName: "confidenceIcon",
                    color: Color("appColor_3")
                )
                metric(
                    title: "Effort",
                    value: "\(formatNumber(idea.effort))",
                    iconName: "effortIcon",
                    color: Color("appColor_2")
                )
            }
        }
        .padding(.horizontal, screenHeight * 0.02)
        .padding(.vertical, screenHeight * 0.018)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var statusPill: some View {
        Text(idea.status.rawValue)
            .font(.outfitLight(size: screenHeight * 0.014))
            .foregroundStyle(.white)
            .padding(.horizontal, screenHeight * 0.011)
            .padding(.vertical, screenHeight * 0.004)
            .background(Capsule().fill(statusColor))
    }

    private var riceScoreColor: Color {
        if idea.riceScore <= 100 {
            return Color("appColor_5")
        } else if idea.riceScore <= 500 {
            return Color("appColor_2")
        } else {
            return Color("appColor_3")
        }
    }

    private var statusColor: Color {
        switch idea.status {
        case .new: return Color("appColor_4")
        case .inProgress: return Color("appColor_2")
        case .success: return Color("appColor_3")
        case .failed: return Color("appColor_5")
        case .archived: return .gray
        }
    }

    private func metric(title: String, value: String, iconName: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: screenHeight * 0.006) {
            RoundedRectangle(cornerRadius: screenHeight * 0.012)
                .fill(color.opacity(0.16))
                .frame(width: screenHeight * 0.017, height: screenHeight * 0.038)
                .overlay {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.013, height: screenHeight * 0.013)
                }

            VStack(alignment: .leading, spacing: screenHeight * 0.002) {
                Text(title)
                    .font(.outfitLight(size: screenHeight * 0.012))
                    .foregroundStyle(.black.opacity(0.5))
                    .lineLimit(1)
                Text(value)
                    .font(.outfitLight(size: screenHeight * 0.016))
                    .foregroundStyle(.black.opacity(0.82))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        }
        let s = String(format: "%.1f", value)
        return s.hasSuffix(".0") ? String(Int(value)) : s
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        MenuTwoIdeaCardView(
            idea: IdeaItem(
                id: UUID(),
                createdAt: Date(),
                title: "Push Notifications",
                details: "Add real-time push notifications for important updates",
                reach: 1000,
                reachUnit: "users",
                impact: 3,
                confidence: 0.9,
                effort: 3,
                effortUnit: "weeks",
                riceScore: 900,
                status: .new,
                retrospective: nil
            )
        )
        .padding()
    }
}
