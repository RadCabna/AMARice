import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, screenHeight * 0.024)
                    .padding(.top, screenHeight * 0.015)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingSlideView(page: page)
                            .tag(index)
                            .padding(.top, screenHeight * 0.006)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: screenHeight * 0.02) {
                    OnboardingPageIndicatorView(
                        total: viewModel.pages.count,
                        current: viewModel.currentPage
                    )

                    HStack {
                        Button("Back") {
                            withAnimation {
                                viewModel.goBack()
                            }
                        }
                        .font(.outfitLight(size: screenHeight * 0.019))
                        .foregroundStyle(.black.opacity(viewModel.currentPage == 0 ? 0 : 0.9))
                        .disabled(viewModel.currentPage == 0)

                        Spacer()

                        Button {
                            withAnimation {
                                if viewModel.isLastPage {
                                    onFinish()
                                } else {
                                    viewModel.goNext()
                                }
                            }
                        } label: {
                            HStack(spacing: screenHeight * 0.009) {
                                Text(viewModel.isLastPage ? "Get Started" : "Next")
                                Image(systemName: "arrow.right")
                            }
                            .font(.outfitMedium(size: screenHeight * 0.019))
                            .foregroundStyle(.white)
                            .padding(.horizontal, screenHeight * 0.026)
                            .padding(.vertical, screenHeight * 0.014)
                            .background(Color("appColor_1"))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, screenHeight * 0.028)
                }
                .padding(.bottom, screenHeight * 0.04)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Button("Skip") {
                onFinish()
            }
            .font(.outfitLight(size: screenHeight * 0.016))
            .foregroundStyle(.black)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView(onFinish: {})
    }
}
