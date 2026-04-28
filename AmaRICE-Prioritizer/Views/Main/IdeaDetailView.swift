import SwiftUI

struct IdeaDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: IdeaItem
    @State private var retrospectiveText: String
    @State private var isEditPresented = false
    @State private var keyboardHeight: CGFloat = 0
    let onSave: (IdeaItem) -> Void

    init(idea: IdeaItem, onSave: @escaping (IdeaItem) -> Void) {
        _draft = State(initialValue: idea)
        _retrospectiveText = State(initialValue: idea.retrospective ?? "")
        self.onSave = onSave
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: screenHeight * 0.016) {
                    summarySection
                    scoreSection
                    breakdownSection
                    if draft.status == .failed {
                        retrospectiveSection
                    }
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.07)
                .padding(.bottom, screenHeight * 0.03 + max(0, keyboardHeight - screenHeight * 0.04))
            }

            header
        }
        .fullScreenCover(isPresented: $isEditPresented) {
            IdeaEditView(idea: draft) { updated in
                draft = updated
                if draft.status != .failed {
                    retrospectiveText = ""
                }
            }
        }
        .gesture(
            TapGesture().onEnded { dismissKeyboard() },
            including: .gesture
        )
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
            guard let rect = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = rect.height
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }

    private var header: some View {
        HStack {
            Button {
                var updated = draft
                updated.retrospective = draft.status == .failed ? retrospectiveText.trimmingCharacters(in: .whitespacesAndNewlines) : nil
                onSave(updated)
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: screenHeight * 0.022, weight: .medium))
                    .foregroundStyle(.black)
            }

            Text("Idea Details")
                .font(.outfitMedium(size: screenHeight * 0.026))
                .foregroundStyle(.black)

            Spacer()

            Button {
                isEditPresented = true
            } label: {
                Image("editIdeaButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenHeight * 0.023, height: screenHeight * 0.023)
            }
        }
        .padding(.horizontal, screenHeight * 0.02)
        .padding(.top, screenHeight * 0.0)
        .padding(.bottom, screenHeight * 0.02)
        .background(.white)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text(draft.title)
                .font(.outfitMedium(size: screenHeight * 0.032))
                .foregroundStyle(.black)
            Text(draft.details.isEmpty ? "No description" : draft.details)
                .font(.outfitLight(size: screenHeight * 0.02))
                .foregroundStyle(.black.opacity(0.65))

            Text("Status")
                .font(.outfitMedium(size: screenHeight * 0.018))
                .foregroundStyle(.black.opacity(0.85))

            statusGrid
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.03)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var statusGrid: some View {
        let items = IdeaItem.Status.allCases
        return VStack(alignment: .leading, spacing: screenHeight * 0.009) {
            HStack(spacing: screenHeight * 0.011) {
                ForEach(items.prefix(3), id: \.self) { status in
                    statusButton(status)
                }
            }
            HStack(spacing: screenHeight * 0.011) {
                ForEach(items.suffix(2), id: \.self) { status in
                    statusButton(status)
                }
                Spacer()
            }
        }
    }

    private func statusButton(_ status: IdeaItem.Status) -> some View {
        Button {
            draft.status = status
            if draft.status != .failed {
                retrospectiveText = ""
            }
        } label: {
            Text(status.rawValue)
                .font(.outfitLight(size: screenHeight * 0.017))
                .foregroundStyle(draft.status == status ? .white : .black)
                .padding(.horizontal, screenHeight * 0.016)
                .padding(.vertical, screenHeight * 0.009)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.014)
                        .fill(draft.status == status ? Color(red: 0.07, green: 0.13, blue: 0.24) : Color.gray.opacity(0.08))
                )
        }
    }

    private var scoreSection: some View {
        VStack(spacing: screenHeight * 0.01) {
            Text("RICE Score")
                .font(.outfitLight(size: screenHeight * 0.02))
                .foregroundStyle(.white.opacity(0.8))
            Text("\(draft.riceScore)")
                .font(.outfitLight(size: screenHeight * 0.075))
                .foregroundStyle(.white)
            Text(priorityTitle)
                .font(.outfitLight(size: screenHeight * 0.017))
                .foregroundStyle(.white)
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.vertical, screenHeight * 0.008)
                .background(Capsule().fill(priorityColor))
        }
        .padding(.vertical, screenHeight * 0.032)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.022)
                .fill(Color(red: 0.09, green: 0.14, blue: 0.22))
        )
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            Text("RICE Breakdown")
                .font(.outfitMedium(size: screenHeight * 0.026))
                .foregroundStyle(.black)

            breakdownRow(title: "Reach", value: "\(formatNumber(draft.reach)) \(draft.reachUnit)", icon: "reachIcon", color: Color("appColor_1"))
            breakdownRow(title: "Impact", value: "\(formatNumber(draft.impact))x multiplier", icon: "impactIcon", color: Color("appColor_4"))
            breakdownRow(title: "Confidence", value: "\(Int((draft.confidence * 100).rounded()))%", icon: "confidenceIcon", color: Color("appColor_3"))
            breakdownRow(title: "Effort", value: "\(formatNumber(draft.effort)) \(draft.effortUnit)", icon: "effortIcon", color: Color("appColor_2"))

            VStack(alignment: .leading, spacing: screenHeight * 0.006) {
                Text("Calculation")
                    .font(.outfitLight(size: screenHeight * 0.016))
                    .foregroundStyle(.black.opacity(0.5))
                Text("(\(formatNumber(draft.reach)) × \(formatNumber(draft.impact)) × \(Int((draft.confidence * 100).rounded()))%) / \(formatNumber(max(draft.effort, 1))) = \(draft.riceScore)")
                    .font(.outfitLight(size: screenHeight * 0.022))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, screenHeight * 0.02)
            .padding(.vertical, screenHeight * 0.016)
            .background(RoundedRectangle(cornerRadius: screenHeight * 0.016).fill(Color.gray.opacity(0.08)))
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.03)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private func breakdownRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: screenHeight * 0.01) {
            RoundedRectangle(cornerRadius: screenHeight * 0.014)
                .fill(color.opacity(0.16))
                .frame(width: screenHeight * 0.045, height: screenHeight * 0.045)
                .overlay(
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.024, height: screenHeight * 0.024)
                )
            VStack(alignment: .leading, spacing: screenHeight * 0.002) {
                Text(title)
                    .font(.outfitLight(size: screenHeight * 0.016))
                    .foregroundStyle(.black.opacity(0.55))
                Text(value)
                    .font(.outfitLight(size: screenHeight * 0.028))
                    .foregroundStyle(.black.opacity(0.85))
            }
            Spacer()
        }
        .padding(.horizontal, screenHeight * 0.015)
        .padding(.vertical, screenHeight * 0.01)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.016).fill(color.opacity(0.06)))
    }

    private var retrospectiveSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text("Results & Retrospective")
                .font(.outfitMedium(size: screenHeight * 0.025))
                .foregroundStyle(.black)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $retrospectiveText)
                    .font(.outfitLight(size: screenHeight * 0.022))
                    .foregroundStyle(.black.opacity(0.9))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: screenHeight * 0.12)
                    .padding(.horizontal, screenHeight * 0.012)
                    .padding(.vertical, screenHeight * 0.01)

                if retrospectiveText.isEmpty {
                    Text("Describe what went wrong...")
                        .font(.outfitLight(size: screenHeight * 0.016))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(.leading, screenHeight * 0.016)
                        .padding(.top, screenHeight * 0.016)
                }
            }
            .background(RoundedRectangle(cornerRadius: screenHeight * 0.015).fill(Color.gray.opacity(0.06)))
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.03)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var priorityTitle: String {
        if draft.riceScore <= 100 { return "Low Priority" }
        if draft.riceScore <= 500 { return "Medium Priority" }
        return "High Priority"
    }

    private var priorityColor: Color {
        if draft.riceScore <= 100 { return Color("appColor_5") }
        if draft.riceScore <= 500 { return Color("appColor_2") }
        return Color("appColor_3")
    }

    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        let s = String(format: "%.2f", value)
        if s.hasSuffix("00") { return String(format: "%.0f", value) }
        if s.hasSuffix("0") { return String(format: "%.1f", value) }
        return s
    }
}

#Preview {
    IdeaDetailView(
        idea: IdeaItem(
            id: UUID(),
            createdAt: Date(),
            title: "Push Notifications",
            details: "Add real-time push notifications for important updates",
            reach: 10000,
            reachUnit: "users",
            impact: 3,
            confidence: 0.9,
            effort: 3,
            effortUnit: "weeks",
            riceScore: 9000,
            status: .failed,
            retrospective: "Low engagement with video content."
        ),
        onSave: { _ in }
    )
}
