import Foundation
import SwiftUI

final class MenuThreeViewModel: ObservableObject {
    struct StatusSlice: Identifiable {
        let id = UUID()
        let status: IdeaItem.Status
        let count: Int
        let color: Color
    }

    func totalIdeas(from ideas: [IdeaItem]) -> Int {
        ideas.count
    }

    func inProgressCount(from ideas: [IdeaItem]) -> Int {
        ideas.filter { $0.status == .inProgress }.count
    }

    func totalSuccessEver(from successIDsEver: Set<String>) -> Int {
        successIDsEver.count
    }

    func successConversionRate(totalCreatedEver: Int, successEver: Int) -> Int {
        guard totalCreatedEver > 0 else { return 0 }
        return Int((Double(successEver) / Double(totalCreatedEver) * 100).rounded())
    }

    func averageRiceScore(from ideas: [IdeaItem]) -> Int {
        guard !ideas.isEmpty else { return 0 }
        let total = ideas.reduce(0) { $0 + $1.riceScore }
        return Int((Double(total) / Double(ideas.count)).rounded())
    }

    func topIdeas(from ideas: [IdeaItem], limit: Int = 10) -> [IdeaItem] {
        Array(
            ideas.sorted {
                if $0.riceScore == $1.riceScore {
                    return $0.createdAt > $1.createdAt
                }
                return $0.riceScore > $1.riceScore
            }
            .prefix(limit)
        )
    }

    func count(for status: IdeaItem.Status, in ideas: [IdeaItem]) -> Int {
        ideas.filter { $0.status == status }.count
    }

    func statusSlices(from ideas: [IdeaItem]) -> [StatusSlice] {
        let mappings: [(IdeaItem.Status, Color)] = [
            (.inProgress, Color("appColor_2")),
            (.new, Color("appColor_4")),
            (.success, Color("appColor_3")),
            (.failed, Color("appColor_5"))
        ]

        return mappings.compactMap { status, color in
            let count = count(for: status, in: ideas)
            guard count > 0 else { return nil }
            return StatusSlice(status: status, count: count, color: color)
        }
    }

    func statusPercent(for count: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(count) / Double(total) * 100).rounded())
    }
}
