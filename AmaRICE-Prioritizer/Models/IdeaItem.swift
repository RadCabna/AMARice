import Foundation

struct IdeaItem: Identifiable, Codable, Equatable {
    enum Status: String, Codable, CaseIterable, Identifiable {
        case new = "New"
        case inProgress = "In Progress"
        case success = "Success"
        case failed = "Failed"
        case archived = "Archived"

        var id: String { rawValue }
    }

    let id: UUID
    let createdAt: Date
    var title: String
    var details: String
    var reach: Double
    var reachUnit: String
    var impact: Double
    var confidence: Double
    var effort: Double
    var effortUnit: String
    var riceScore: Int
    var status: Status
    var retrospective: String?
}
