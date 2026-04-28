import SwiftUI

struct OnboardingSlideView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            VStack(spacing: screenHeight * 0.008) {
                Text(page.title)
                    .font(.outfitMedium(size: screenHeight * 0.028))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.outfitLight(size: screenHeight * 0.019))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, screenHeight * 0.028)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * page.imageHeightRatio)
                .padding(.horizontal, page.imageHorizontalPadding)
                .shadow(color: .black.opacity(0.16), radius: screenHeight * 0.019, x: 0, y: 8)

            if !page.checklist.isEmpty {
                VStack(alignment: .leading, spacing: screenHeight * 0.009) {
                    ForEach(Array(page.checklist.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: screenHeight * 0.009) {
                            if page.usesNumberedChecklist {
                                Circle()
                                    .fill(Color("appColor_1"))
                                    .frame(width: screenHeight * 0.035, height: screenHeight * 0.035)
                                    .overlay {
                                        Text("\(index + 1)")
                                            .font(.outfitLight(size: screenHeight * 0.019))
                                            .foregroundStyle(.white)
                                    }
                            } else {
                                Circle()
                                    .fill(Color("appColor_1"))
                                    .frame(width: screenHeight * 0.009, height: screenHeight * 0.009)
                                    .padding(.top, screenHeight * 0.007)
                            }

                            Text(item)
                                .font(.outfitLight(size: page.usesNumberedChecklist ? screenHeight * 0.022 : screenHeight * 0.016))
                                .foregroundStyle(.black.opacity(0.85))
                                .padding(.top, page.usesNumberedChecklist ? screenHeight * 0.001 : 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, screenHeight * 0.038)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        OnboardingSlideView(
            page: OnboardingPage(
                title: "How It Works",
                subtitle: "Simple, fast, effective",
                imageName: "onboardingImage_3",
                imageHeightRatio: 0.40,
                imageHorizontalPadding: 24,
                checklist: [
                    "Add your idea",
                    "Enter RICE values",
                    "Get instant score"
                ],
                usesNumberedChecklist: true
            )
        )
    }
}
