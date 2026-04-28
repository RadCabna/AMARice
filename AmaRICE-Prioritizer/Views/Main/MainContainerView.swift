import SwiftUI

struct MainContainerView: View {
    @StateObject private var viewModel = MainContainerViewModel()
    @StateObject private var ideaStore = IdeaStoreViewModel()

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

            VStack(spacing: 0) {
                if viewModel.selectedTab == .menu1 {
                    topHeader
                }
                Spacer()
                BottomBarView(selectedTab: $viewModel.selectedTab)
                    .padding(.bottom, screenHeight * 0.015)
            }
            .ignoresSafeArea(edges: .top)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }

    private var topHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text(viewModel.selectedTab == .menu1 ? "New Idea" : "Menu")
                    .font(.outfitMedium(size: screenHeight * 0.025))
                    .foregroundStyle(.black)
                    .padding(.top, screenHeight * 0.012)
                Spacer()
            }
            .padding(.horizontal, screenHeight * 0.019)
            .frame(height: screenHeight * 0.095, alignment: .bottom)
            .padding(.vertical, screenHeight * 0.008)
            .background(.white)
        }
    }
}

#Preview {
    NavigationStack {
        MainContainerView()
    }
}
