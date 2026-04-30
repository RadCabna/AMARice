import SwiftUI

struct MainContainerView: View {
    @StateObject private var viewModel = MainContainerViewModel()
    @StateObject private var ideaStore = IdeaStoreViewModel()
    
    private var topHeaderHeight: CGFloat {
        min(max(screenWidth * 0.14, 64), 84)
    }
    
    private var topHeaderFontSize: CGFloat {
        min(max(screenWidth * 0.055, 20), 28)
    }

    var body: some View {
        ZStack {
            Color("bgColor").ignoresSafeArea()

            Group {
                switch viewModel.selectedTab {
                case .menu1:
                    MenuOneView {
                        viewModel.selectedTab = .menu2
                    }
                case .menu2:
                    MenuTwoView()
                case .menu3:
                    MenuThreeView()
                }
            }
            .environmentObject(ideaStore)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if viewModel.selectedTab == .menu1 {
                topHeader
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBarView(selectedTab: $viewModel.selectedTab)
                .padding(.bottom, screenHeight * 0.015)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }

    private var topHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text(viewModel.selectedTab == .menu1 ? "New Idea" : "Menu")
                    .font(.outfitMedium(size: topHeaderFontSize))
                    .foregroundStyle(.black)
                    .padding(.bottom)
                Spacer()
            }
            .padding(.horizontal, screenHeight * 0.019)
            .frame(height: topHeaderHeight, alignment: .bottom)
            .padding(.bottom, screenHeight * 0.004)
            .background(.white)
            .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
        }
    }
}

#Preview {
    NavigationStack {
        MainContainerView()
    }
}
