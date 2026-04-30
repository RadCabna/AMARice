import SwiftUI

struct SwipeIdeaCardRowView: View {
    let idea: IdeaItem
    let onOpen: () -> Void
    let onDelete: () -> Void
    let onSetInProgress: () -> Void

    @State private var offsetX: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0
    @State private var isHorizontalDragActive = false

    private var revealWidth: CGFloat { screenWidth * 0.43 }
    private var settleThreshold: CGFloat { revealWidth * 0.45 }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                let rowWidth = proxy.size.width
                let visibleCardWidth = max(0, rowWidth - abs(offsetX))

                HStack(spacing: 0) {
                    ZStack {
                        Color("appColor_3")
                        Text("In Progress")
                            .font(.outfitLight(size: screenHeight * 0.028))
                            .foregroundStyle(.white)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSetInProgress()
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            offsetX = 0
                        }
                    }

                    ZStack {
                        Color.red
                        Text("Delete")
                            .font(.outfitLight(size: screenHeight * 0.028))
                            .foregroundStyle(.white)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onDelete()
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            offsetX = 0
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.02))

                MenuTwoIdeaCardView(idea: idea)
                    .offset(x: offsetX)

                if offsetX == 0 {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: rowWidth, height: proxy.size.height)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onOpen()
                        }
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: visibleCardWidth, height: proxy.size.height)
                        .contentShape(Rectangle())
                        .offset(x: offsetX > 0 ? offsetX : 0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                offsetX = 0
                            }
                        }
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        if !isHorizontalDragActive {
                            let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                            if isHorizontal {
                                isHorizontalDragActive = true
                            } else {
                                return
                            }
                        }

                        if dragStartOffset == 0 {
                            dragStartOffset = offsetX
                        }
                        let candidate = dragStartOffset + value.translation.width
                        offsetX = min(max(candidate, -revealWidth), revealWidth)
                    }
                    .onEnded { value in
                        guard isHorizontalDragActive else { return }
                        let candidate = dragStartOffset + value.translation.width
                        dragStartOffset = 0
                        isHorizontalDragActive = false
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            if candidate > settleThreshold {
                                offsetX = revealWidth
                            } else if candidate < -settleThreshold {
                                offsetX = -revealWidth
                            } else {
                                offsetX = 0
                            }
                        }
                    }
            )
        }
        .frame(height: screenHeight * 0.17)
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        SwipeIdeaCardRowView(
            idea: IdeaItem(
                id: UUID(),
                createdAt: Date(),
                title: "Video Tutorials",
                details: "Create in-app video tutorials for new users",
                reach: 20,
                reachUnit: "users",
                impact: 1,
                confidence: 0.5,
                effort: 5,
                effortUnit: "weeks",
                riceScore: 200,
                status: .failed,
                retrospective: nil
            ),
            onOpen: {},
            onDelete: {},
            onSetInProgress: {}
        )
        .padding()
    }
}
