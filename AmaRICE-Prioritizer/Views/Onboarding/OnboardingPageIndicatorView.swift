import SwiftUI

struct OnboardingPageIndicatorView: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: screenHeight * 0.007) {
            ForEach(0..<total, id: \.self) { index in
                RoundedRectangle(cornerRadius: screenHeight * 0.005)
                    .fill(index == current ? Color("appColor_1") : Color.gray.opacity(0.45))
                    .frame(width: index == current ? screenHeight * 0.024 : screenHeight * 0.007, height: screenHeight * 0.007)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: current)
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        OnboardingPageIndicatorView(total: 5, current: 1)
    }
}
