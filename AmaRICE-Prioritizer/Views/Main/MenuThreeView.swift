import SwiftUI

struct MenuThreeView: View {
    @EnvironmentObject private var ideaStore: IdeaStoreViewModel
    @StateObject private var viewModel = MenuThreeViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: screenHeight * 0.014) {
                    summaryCards
                    statusDistributionSection
                    topIdeasSection
                    quickStatsSection
                    averageRiceSection
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.055)
                .padding(.bottom, screenHeight * 0.13)
            }

            header
        }
    }

    private var header: some View {
        HStack {
            Text("Insights & Analytics")
                .font(.outfitMedium(size: screenHeight * 0.025))
                .foregroundStyle(.black)
                .padding(.top, screenHeight * 0.012)
            Spacer()
        }
        .padding(.horizontal, screenHeight * 0.019)
        .frame(height: screenHeight * 0.027, alignment: .bottom)
        .padding(.vertical, screenHeight * 0.005)
        .background(.white)
    }

    private var summaryCards: some View {
        let successEver = viewModel.totalSuccessEver(from: ideaStore.successIdeaIDsEver)
        let totalCreatedEver = max(ideaStore.totalCreatedIdeasEver, 1)
        let successRate = viewModel.successConversionRate(totalCreatedEver: ideaStore.totalCreatedIdeasEver, successEver: successEver)

        return VStack(spacing: screenHeight * 0.012) {
            analyticsCard(
                title: "Total Ideas",
                value: "\(viewModel.totalIdeas(from: ideaStore.ideas))",
                accentColor: Color("appColor_1"),
                iconName: "reachIcon",
                lineStyle: .fullGradient,
                progress: 1
            )

            analyticsCard(
                title: "Implementations",
                value: "\(successEver)",
                accentColor: Color("appColor_4"),
                iconName: "impactIcon",
                lineStyle: .partial,
                progress: min(max(Double(successEver) / Double(totalCreatedEver), 0), 1)
            )

            analyticsCard(
                title: "Success Rate",
                value: "\(successRate)%",
                accentColor: Color("appColor_3"),
                iconName: "confidenceIcon",
                lineStyle: .partial,
                progress: min(max(Double(successRate) / 100, 0), 1)
            )
        }
    }

    private enum AnalyticsLineStyle {
        case fullGradient
        case partial
    }

    private func analyticsCard(title: String, value: String, accentColor: Color, iconName: String, lineStyle: AnalyticsLineStyle, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.007) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: screenHeight * 0.002) {
                    Text(title)
                        .font(.outfitLight(size: screenHeight * 0.012))
                        .foregroundStyle(.black.opacity(0.45))
                    Text(value)
                        .font(.outfitMedium(size: screenHeight * 0.03))
                        .foregroundStyle(.black.opacity(0.88))
                }
                Spacer()
                RoundedRectangle(cornerRadius: screenHeight * 0.016)
                    .fill(accentColor.opacity(0.12))
                    .frame(width: screenHeight * 0.045, height: screenHeight * 0.045)
                    .overlay(
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                    )
            }

            Capsule()
                .fill(Color.gray.opacity(0.12))
                .frame(height: screenHeight * 0.009)
                .overlay(alignment: .leading) {
                    if lineStyle == .fullGradient {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("appColor_1"), Color("appColor_4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: screenHeight * 0.009)
                    } else {
                        Capsule()
                            .fill(accentColor)
                            .frame(width: screenHeight * 0.36 * progress, height: screenHeight * 0.009)
                    }
                }
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.023)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var statusDistributionSection: some View {
        let allSlices = allStatusSlices
        let total = max(ideaStore.ideas.count, 1)
        return VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            Text("Status Distribution")
                .font(.outfitMedium(size: screenHeight * 0.022))
                .foregroundStyle(.black)

            HStack {
                Spacer()
                PieChartView(slices: allSlices)
                    .frame(width: screenHeight * 0.26, height: screenHeight * 0.26)
                Spacer()
            }
            .overlay {
                GeometryReader { proxy in
                    let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    let radius = min(proxy.size.width, proxy.size.height) * 0.22
                    ZStack {
                        ForEach(Array(allSlices.enumerated()), id: \.element.id) { index, slice in
                            if slice.count > 0 {
                                let start = pieAngle(at: index, slices: allSlices, total: total)
                                let end = pieAngle(at: index + 1, slices: allSlices, total: total)
                                let mid = Angle.degrees((start.degrees + end.degrees) / 2)
                                let x = center.x + CGFloat(cos(mid.radians)) * (radius + screenHeight * 0.115)
                                let y = center.y + CGFloat(sin(mid.radians)) * (radius + screenHeight * 0.115)
                                VStack(spacing: screenHeight * 0.001) {
                                    Text(slice.status.rawValue)
                                        .font(.outfitLight(size: screenHeight * 0.014))
                                        .foregroundStyle(slice.color)
                                    Text("\(viewModel.statusPercent(for: slice.count, total: total))%")
                                        .font(.outfitLight(size: screenHeight * 0.014))
                                        .foregroundStyle(slice.color)
                                }
                                    .position(x: x, y: y)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, screenHeight*0.05)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: screenHeight * 0.01) {
                ForEach(allSlices) { slice in
                    HStack(spacing: screenHeight * 0.007) {
                        RoundedRectangle(cornerRadius: screenHeight * 0.006)
                            .fill(slice.color)
                            .frame(width: screenHeight * 0.023, height: screenHeight * 0.023)
                        VStack(alignment: .leading, spacing: screenHeight * 0.001) {
                            Text(slice.status.rawValue)
                                .font(.outfitLight(size: screenHeight * 0.018))
                                .foregroundStyle(.black.opacity(0.75))
                            Text("\(slice.count) ideas")
                                .font(.outfitLight(size: screenHeight * 0.016))
                                .foregroundStyle(.black.opacity(0.55))
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.023)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var topIdeasSection: some View {
        let topIdeas = viewModel.topIdeas(from: ideaStore.ideas, limit: 10)
        return VStack(alignment: .leading, spacing: screenHeight * 0.01) {
            Text("Top Ideas by RICE Score")
                .font(.outfitMedium(size: screenHeight * 0.022))
                .foregroundStyle(.black)

            if topIdeas.isEmpty {
                Text("No ideas yet")
                    .font(.outfitLight(size: screenHeight * 0.018))
                    .foregroundStyle(.black.opacity(0.45))
            } else {
                ForEach(Array(topIdeas.enumerated()), id: \.element.id) { index, idea in
                    HStack(alignment: .top, spacing: screenHeight * 0.007) {
                        Text("\(index + 1).")
                            .font(.outfitLight(size: screenHeight * 0.016))
                            .foregroundStyle(.black.opacity(0.72))
                        Text(idea.title)
                            .font(.outfitLight(size: screenHeight * 0.016))
                            .foregroundStyle(.black.opacity(0.82))
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.023)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            Text("Quick Stats")
                .font(.outfitMedium(size: screenHeight * 0.022))
                .foregroundStyle(.black)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: screenHeight * 0.014) {
                quickStatItem(
                    title: "New Ideas",
                    value: "\(viewModel.count(for: .new, in: ideaStore.ideas))",
                    color: Color("appColor_4"),
                    iconName: "confidenceIcon"
                )
                quickStatItem(
                    title: "In Progress",
                    value: "\(viewModel.count(for: .inProgress, in: ideaStore.ideas))",
                    color: Color("appColor_2"),
                    iconName: "reachIcon"
                )
                quickStatItem(
                    title: "Completed",
                    value: "\(viewModel.count(for: .success, in: ideaStore.ideas))",
                    color: Color("appColor_3"),
                    iconName: "impactIcon"
                )
                quickStatItem(
                    title: "Failed",
                    value: "\(viewModel.count(for: .failed, in: ideaStore.ideas))",
                    color: Color("appColor_5"),
                    iconName: "effortIcon"
                )
            }
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.023)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private func quickStatItem(title: String, value: String, color: Color, iconName: String) -> some View {
        VStack(spacing: screenHeight * 0.008) {
            RoundedRectangle(cornerRadius: screenHeight * 0.016)
                .fill(color.opacity(0.12))
                .frame(width: screenHeight * 0.045, height: screenHeight * 0.045)
                .overlay(
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                )
            Text(value)
                .font(.outfitMedium(size: screenHeight * 0.028))
                .foregroundStyle(.black.opacity(0.88))
            Text(title)
                .font(.outfitLight(size: screenHeight * 0.014))
                .foregroundStyle(.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    private var averageRiceSection: some View {
        VStack(spacing: screenHeight * 0.006) {
            Text("Average RICE Score")
                .font(.outfitLight(size: screenHeight * 0.014))
                .foregroundStyle(.white.opacity(0.7))
            Text("\(viewModel.averageRiceScore(from: ideaStore.ideas))")
                .font(.outfitMedium(size: screenHeight * 0.046))
                .foregroundStyle(.white)
            Text("Across \(viewModel.totalIdeas(from: ideaStore.ideas)) ideas")
                .font(.outfitLight(size: screenHeight * 0.014))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.vertical, screenHeight * 0.024)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                .fill(Color(red: 0.09, green: 0.14, blue: 0.22))
        )
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var allStatusSlices: [MenuThreeViewModel.StatusSlice] {
        [
            MenuThreeViewModel.StatusSlice(
                status: .inProgress,
                count: viewModel.count(for: .inProgress, in: ideaStore.ideas),
                color: Color("appColor_2")
            ),
            MenuThreeViewModel.StatusSlice(
                status: .new,
                count: viewModel.count(for: .new, in: ideaStore.ideas),
                color: Color("appColor_4")
            ),
            MenuThreeViewModel.StatusSlice(
                status: .success,
                count: viewModel.count(for: .success, in: ideaStore.ideas),
                color: Color("appColor_3")
            ),
            MenuThreeViewModel.StatusSlice(
                status: .failed,
                count: viewModel.count(for: .failed, in: ideaStore.ideas),
                color: Color("appColor_5")
            )
        ]
    }

    private func pieAngle(at index: Int, slices: [MenuThreeViewModel.StatusSlice], total: Int) -> Angle {
        let consumed = slices.prefix(index).reduce(0) { $0 + $1.count }
        return .degrees(Double(consumed) / Double(total) * 360 - 90)
    }
}

private struct PieChartView: View {
    let slices: [MenuThreeViewModel.StatusSlice]

    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(origin: .zero, size: geometry.size)
            let total = slices.reduce(0) { $0 + $1.count }

            ZStack {
                if total == 0 {
                    Circle()
                        .stroke(Color("appColor_3"), lineWidth: 4)
                } else {
                    ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                        let start = angle(at: index, total: total)
                        let end = angle(at: index + 1, total: total)
                        PieSliceShape(startAngle: start, endAngle: end)
                            .fill(slice.color)
                            .overlay(
                                PieSliceShape(startAngle: start, endAngle: end)
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                }
            }
            .frame(width: rect.width, height: rect.height)
        }
    }

    private func angle(at index: Int, total: Int) -> Angle {
        let consumed = slices.prefix(index).reduce(0) { $0 + $1.count }
        return .degrees(Double(consumed) / Double(total) * 360 - 90)
    }
}

private struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        MenuThreeView()
            .environmentObject(IdeaStoreViewModel())
    }
}
