import Foundation

final class IdeaStoreViewModel: ObservableObject {
    @Published private(set) var ideas: [IdeaItem] = []
    @Published private(set) var totalCreatedIdeasEver: Int = 0
    @Published private(set) var successIdeaIDsEver: Set<String> = []

    private let defaultsKey = "saved_ideas_v1"
    private let totalCreatedKey = "saved_ideas_total_created_v1"
    private let successIDsKey = "saved_ideas_success_ids_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        loadIdeas()
    }

    func addIdea(_ idea: IdeaItem) {
        ideas.insert(idea, at: 0)
        totalCreatedIdeasEver += 1
        registerSuccessIfNeeded(for: idea)
        persistIdeas()
    }

    func updateIdeaStatus(id: UUID, status: IdeaItem.Status) {
        guard let index = ideas.firstIndex(where: { $0.id == id }) else { return }
        ideas[index].status = status
        registerSuccessIfNeeded(for: ideas[index])
        persistIdeas()
    }

    func updateIdea(_ idea: IdeaItem) {
        guard let index = ideas.firstIndex(where: { $0.id == idea.id }) else { return }
        ideas[index] = idea
        registerSuccessIfNeeded(for: idea)
        persistIdeas()
    }

    func deleteIdea(id: UUID) {
        ideas.removeAll { $0.id == id }
        persistIdeas()
    }

    private func loadIdeas() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? decoder.decode([IdeaItem].self, from: data)
        else { return }
        ideas = decoded

        let savedTotal = UserDefaults.standard.integer(forKey: totalCreatedKey)
        totalCreatedIdeasEver = max(savedTotal, ideas.count)

        if let savedIDs = UserDefaults.standard.array(forKey: successIDsKey) as? [String] {
            successIdeaIDsEver = Set(savedIDs)
        } else {
            successIdeaIDsEver = Set(ideas.filter { $0.status == .success }.map { $0.id.uuidString })
        }
    }

    private func persistIdeas() {
        guard let encoded = try? encoder.encode(ideas) else { return }
        UserDefaults.standard.set(encoded, forKey: defaultsKey)
        UserDefaults.standard.set(totalCreatedIdeasEver, forKey: totalCreatedKey)
        UserDefaults.standard.set(Array(successIdeaIDsEver), forKey: successIDsKey)
    }

    private func registerSuccessIfNeeded(for idea: IdeaItem) {
        guard idea.status == .success else { return }
        successIdeaIDsEver.insert(idea.id.uuidString)
    }
}
