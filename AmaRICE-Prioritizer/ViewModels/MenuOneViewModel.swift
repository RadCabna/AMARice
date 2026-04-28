import Foundation

final class MenuOneViewModel: ObservableObject {
    enum ReachUnit: String, CaseIterable, Identifiable {
        case users = "users"
        case sessions = "sessions"
        case orders = "orders"

        var id: String { rawValue }
    }

    enum EffortUnit: String, CaseIterable, Identifiable {
        case days = "days"
        case weeks = "weeks"
        case sprints = "sprints"

        var id: String { rawValue }
    }

    enum ImpactLevel: String, CaseIterable, Identifiable {
        case minimal = "Minimal"
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case massive = "Massive"

        var id: String { rawValue }

        var multiplier: String {
            switch self {
            case .minimal: return "0.25x"
            case .low: return "0.5x"
            case .medium: return "1x"
            case .high: return "2x"
            case .massive: return "3x"
            }
        }

        var numericValue: Double {
            switch self {
            case .minimal: return 0.25
            case .low: return 0.5
            case .medium: return 1
            case .high: return 2
            case .massive: return 3
            }
        }
    }

    enum RicePriorityBand {
        case low
        case medium
        case high

        init(score: Double) {
            if score <= 100 {
                self = .low
            } else if score <= 500 {
                self = .medium
            } else {
                self = .high
            }
        }

        var title: String {
            switch self {
            case .low: return "Low Priority"
            case .medium: return "Medium Priority"
            case .high: return "High Priority"
            }
        }

        var backgroundAssetName: String {
            switch self {
            case .low: return "appColor_5"
            case .medium: return "appColor_2"
            case .high: return "appColor_3"
            }
        }
    }

    @Published var ideaName = ""
    @Published var ideaDescription = ""
    @Published var reachValue = "500"
    @Published var selectedReachUnit: ReachUnit = .users
    @Published var selectedImpact: ImpactLevel = .medium
    @Published var confidence: Double = 0.8
    @Published var effortValue = "2"
    @Published var selectedEffortUnit: EffortUnit = .weeks

    var canSave: Bool {
        !ideaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        riceScore != nil
    }

    var parsedReach: Double? {
        let trimmed = reachValue.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed)
    }

    var parsedEffort: Double? {
        let trimmed = effortValue.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed)
    }

    var riceScore: Double? {
        guard let reach = parsedReach,
              let effort = parsedEffort,
              effort > 0
        else { return nil }
        let impact = selectedImpact.numericValue
        let conf = confidence
        return (reach * impact * conf) / effort
    }

    var riceScoreDisplay: String {
        guard let score = riceScore, score.isFinite else { return "—" }
        return String(Int(score.rounded()))
    }

    var ricePriorityBand: RicePriorityBand? {
        guard let score = riceScore, score.isFinite, score >= 0 else { return nil }
        return RicePriorityBand(score: score)
    }

    var riceFormulaLine: String {
        guard let reach = parsedReach,
              let effort = parsedEffort,
              effort > 0
        else {
            return "—"
        }
        let impact = selectedImpact.numericValue
        let confPct = Int((confidence * 100).rounded())
        let reachStr = MenuOneViewModel.formatNumber(reach)
        let impactStr = MenuOneViewModel.formatNumber(impact)
        let effortStr = MenuOneViewModel.formatNumber(effort)
        let resultStr = riceScoreDisplay
        return "(\(reachStr) × \(impactStr) × \(confPct)%) / \(effortStr) = \(resultStr)"
    }

    private static func formatNumber(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        }
        let s = String(format: "%.2f", value)
        if s.hasSuffix("00") {
            return String(format: "%.0f", value)
        }
        if s.hasSuffix("0") {
            return String(format: "%.1f", value)
        }
        return s
    }

    func buildIdeaItem() -> IdeaItem? {
        guard let reach = parsedReach,
              let effort = parsedEffort,
              let score = riceScore
        else { return nil }

        return IdeaItem(
            id: UUID(),
            createdAt: Date(),
            title: ideaName.trimmingCharacters(in: .whitespacesAndNewlines),
            details: ideaDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            reach: reach,
            reachUnit: selectedReachUnit.rawValue,
            impact: selectedImpact.numericValue,
            confidence: confidence,
            effort: effort,
            effortUnit: selectedEffortUnit.rawValue,
            riceScore: Int(score.rounded()),
            status: .new,
            retrospective: nil
        )
    }

    func resetAfterSave() {
        ideaName = ""
        ideaDescription = ""
        reachValue = "500"
        selectedReachUnit = .users
        selectedImpact = .medium
        confidence = 0.8
        effortValue = "2"
        selectedEffortUnit = .weeks
    }
}
