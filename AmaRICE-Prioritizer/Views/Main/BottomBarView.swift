import SwiftUI

struct BottomBarView: View {
    @Binding var selectedTab: MainContainerViewModel.Tab

    var body: some View {
        HStack(spacing: screenHeight * 0.019) {
            ForEach(MainContainerViewModel.Tab.allCases, id: \.rawValue) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Image(selectedTab == tab ? tab.onIcon : tab.offIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.045, height: screenHeight * 0.045)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, screenHeight * 0.012)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight*0.025)
                                .fill(selectedTab == tab ? selectedTabColor : .clear)
                        )
                }
            }
        }
        .padding(.horizontal, screenHeight * 0.016)
        .padding(.vertical, screenHeight * 0.012)
        .background(
            RoundedRectangle(cornerRadius: screenHeight*0.025)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.08), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
        .padding(.horizontal, screenHeight * 0.019)
    }

    private var selectedTabColor: Color {
        switch selectedTab {
        case .menu1:
            return Color("appColor_3")
        case .menu2:
            return Color("appColor_2")
        case .menu3:
            return Color("appColor_1")
        }
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        VStack {
            Spacer()
            BottomBarView(selectedTab: .constant(.menu1))
        }
    }
}
