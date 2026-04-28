import Foundation

final class MainContainerViewModel: ObservableObject {
    enum Tab: Int, CaseIterable {
        case menu1
        case menu2
        case menu3

        var onIcon: String {
            switch self {
            case .menu1: return "iconOn_1"
            case .menu2: return "iconOn_2"
            case .menu3: return "iconOn_3"
            }
        }

        var offIcon: String {
            switch self {
            case .menu1: return "iconOff_1"
            case .menu2: return "iconOff_2"
            case .menu3: return "iconOff_3"
            }
        }
    }

    @Published var selectedTab: Tab = .menu1
}
