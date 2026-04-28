import Foundation

final class MenuTwoViewModel: ObservableObject {
    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case new = "New"
        case inProgress = "In Progress"
        case success = "Success"
        case failed = "Failed"
        case archived = "Archived"

        var id: String { rawValue }
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case riceScore = "RICE Score"
        case recent = "Recent"

        var id: String { rawValue }
    }

    @Published var isFilterExpanded = false
    @Published var searchText = ""
    @Published var selectedStatus: StatusFilter = .all
    @Published var selectedSort: SortOption = .riceScore

    func filteredIdeas(from ideas: [IdeaItem]) -> [IdeaItem] {
        var output = ideas

        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = searchText.lowercased()
            output = output.filter { $0.title.lowercased().contains(q) }
        }

        if selectedStatus != .all {
            output = output.filter { $0.status.rawValue == selectedStatus.rawValue }
        }

        switch selectedSort {
        case .riceScore:
            output.sort {
                if $0.riceScore == $1.riceScore {
                    return $0.createdAt > $1.createdAt
                }
                return $0.riceScore > $1.riceScore
            }
        case .recent:
            output.sort {
                if $0.createdAt == $1.createdAt {
                    return $0.riceScore > $1.riceScore
                }
                return $0.createdAt > $1.createdAt
            }
        }

        return output
    }
}
