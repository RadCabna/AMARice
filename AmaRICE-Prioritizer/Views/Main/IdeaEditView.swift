import SwiftUI

struct IdeaEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: IdeaItem
    @State private var keyboardHeight: CGFloat = 0
    let onSave: (IdeaItem) -> Void

    init(idea: IdeaItem, onSave: @escaping (IdeaItem) -> Void) {
        _draft = State(initialValue: idea)
        self.onSave = onSave
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: screenHeight * 0.02) {
                    firstSection
                    reachSection
                    impactSection
                    confidenceSection
                    effortSection
                    scoreSection
                    saveButton
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.07)
                .padding(.bottom, screenHeight * 0.03 + max(0, keyboardHeight - screenHeight * 0.04))
            }

            header
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
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: screenHeight * 0.022, weight: .medium))
                    .foregroundStyle(.black)
            }

            Text("Edit Idea")
                .font(.outfitMedium(size: screenHeight * 0.026))
                .foregroundStyle(.black)

            Spacer()
        }
        .padding(.horizontal, screenHeight * 0.02)
        .padding(.top, screenHeight * 0.0)
        .padding(.bottom, screenHeight * 0.02)
        .background(.white)
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var firstSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text("Idea Name")
                .font(.outfitLight(size: screenHeight * 0.019))
                .foregroundStyle(.black)

            textField("Idea Name", text: $draft.title, keyboard: .default)

            Text("Description")
                .font(.outfitLight(size: screenHeight * 0.019))
                .foregroundStyle(.black)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $draft.details)
                    .font(.outfitLight(size: screenHeight * 0.018))
                    .foregroundStyle(.black)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, screenHeight * 0.012)
                    .padding(.vertical, screenHeight * 0.01)
                    .frame(minHeight: screenHeight * 0.102, maxHeight: screenHeight * 0.102)

                if draft.details.isEmpty {
                    Text("Describe your idea...")
                        .font(.outfitLight(size: screenHeight * 0.016))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(.leading, screenHeight * 0.016)
                        .padding(.top, screenHeight * 0.016)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.015)
                    .fill(Color.gray.opacity(0.06))
            )
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.035)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var reachSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            MenuOneSectionHeaderView(
                title: "Reach",
                subtitle: "How many people will this impact?",
                color: Color("appColor_1"),
                iconName: "reachIcon"
            )
            textField("Reach", text: reachBinding, keyboard: .decimalPad)
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.035)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var impactSection: some View {
        let levels: [(String, Double)] = [("Minimal", 0.25), ("Low", 0.5), ("Medium", 1), ("High", 2), ("Massive", 3)]
        return VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            MenuOneSectionHeaderView(
                title: "Impact",
                subtitle: "How much will it help each person?",
                color: Color("appColor_4"),
                iconName: "impactIcon"
            )
            VStack(spacing: screenHeight * 0.011) {
                ForEach(levels, id: \.0) { level in
                    Button {
                        draft.impact = level.1
                    } label: {
                        HStack {
                            Text(level.0)
                                .font(.outfitLight(size: screenHeight * 0.016))
                                .foregroundStyle(draft.impact == level.1 ? .white : .black)
                            Spacer()
                            Text("\(formatNumber(level.1))x")
                                .font(.outfitLight(size: screenHeight * 0.015))
                                .foregroundStyle(draft.impact == level.1 ? .white : .black.opacity(0.55))
                        }
                        .padding(.horizontal, screenHeight * 0.017)
                        .padding(.vertical, screenHeight * 0.016)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                                .fill(draft.impact == level.1 ? Color("appColor_4") : Color.gray.opacity(0.12))
                        )
                    }
                }
            }
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.035)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            MenuOneSectionHeaderView(
                title: "Confidence",
                subtitle: "How sure are you about this?",
                color: Color("appColor_3"),
                iconName: "confidenceIcon"
            )
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int((draft.confidence * 100).rounded()))%")
                    .font(.outfitMedium(size: screenHeight * 0.036))
                    .foregroundStyle(Color("appColor_3"))
                Spacer()
                Text("High")
                    .font(.outfitLight(size: screenHeight * 0.016))
                    .foregroundStyle(.black.opacity(0.65))
            }
            ConfidenceSliderView(value: $draft.confidence, tintColor: Color("appColor_3"))
                .frame(height: screenHeight * 0.03)
            HStack {
                Text("Low")
                Spacer()
                Text("Medium")
                Spacer()
                Text("High")
            }
            .font(.outfitLight(size: screenHeight * 0.013))
            .foregroundStyle(.black.opacity(0.45))
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.035)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var effortSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            MenuOneSectionHeaderView(
                title: "Effort",
                subtitle: "How long will this take?",
                color: Color("appColor_2"),
                iconName: "effortIcon"
            )
            textField("Effort", text: effortBinding, keyboard: .decimalPad)
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.035)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var scoreSection: some View {
        VStack(spacing: screenHeight * 0.01) {
            Text("RICE Score")
                .font(.outfitLight(size: screenHeight * 0.02))
                .foregroundStyle(.white.opacity(0.8))
            Text("\(computedScore)")
                .font(.outfitLight(size: screenHeight * 0.075))
                .foregroundStyle(.white)
            Text(priorityTitle)
                .font(.outfitLight(size: screenHeight * 0.017))
                .foregroundStyle(.white)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.006)
                .background(Capsule().fill(priorityColor))
            VStack(spacing: screenHeight * 0.005) {
                Text("Formula")
                    .font(.outfitLight(size: screenHeight * 0.02))
                    .foregroundStyle(.white.opacity(0.7))
                Text("(\(formatNumber(draft.reach)) × \(formatNumber(draft.impact)) × \(Int((draft.confidence * 100).rounded()))%) / \(formatNumber(max(draft.effort, 1))) = \(computedScore)")
                    .font(.outfitLight(size: screenHeight * 0.018))
                    .foregroundStyle(.white)
            }
            .padding(.vertical, screenHeight * 0.025)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.02)
                    .fill(Color.white.opacity(0.1))
                    .padding(.horizontal, screenHeight * 0.025)
            )
        }
        .padding(.vertical, screenHeight * 0.032)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.022)
                .fill(Color(red: 0.09, green: 0.14, blue: 0.22))
        )
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var saveButton: some View {
        Button {
            draft.riceScore = computedScore
            onSave(draft)
            dismiss()
        } label: {
            HStack {
                Image(.saveIdeaIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.02)
                Text("Save Idea")
                    .font(.outfitMedium(size: screenHeight * 0.02))
                    .foregroundStyle(.white)
                    .padding(.vertical, screenHeight * 0.019)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.02)
                    .fill(Color("appColor_1"))
            )
        }
    }

    private func textField(_ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(placeholder)
                .font(.outfitLight(size: screenHeight * 0.016))
                .foregroundStyle(.black.opacity(0.4))
        )
        .font(.outfitLight(size: screenHeight * 0.018))
        .foregroundStyle(.black)
        .padding(.horizontal, screenHeight * 0.016)
        .frame(minHeight: screenHeight * 0.052)
        .keyboardType(keyboard)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                .fill(Color.gray.opacity(0.06))
        )
    }

    private var reachBinding: Binding<String> {
        Binding(
            get: { formatNumber(draft.reach) },
            set: { draft.reach = parseDouble($0) }
        )
    }

    private var effortBinding: Binding<String> {
        Binding(
            get: { formatNumber(draft.effort) },
            set: { draft.effort = max(parseDouble($0), 0) }
        )
    }

    private var computedScore: Int {
        guard draft.effort > 0 else { return 0 }
        return Int(((draft.reach * draft.impact * draft.confidence) / draft.effort).rounded())
    }

    private var priorityTitle: String {
        if computedScore <= 100 { return "Low Priority" }
        if computedScore <= 500 { return "Medium Priority" }
        return "High Priority"
    }

    private var priorityColor: Color {
        if computedScore <= 100 { return Color("appColor_5") }
        if computedScore <= 500 { return Color("appColor_2") }
        return Color("appColor_3")
    }

    private func parseDouble(_ value: String) -> Double {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        return Double(normalized) ?? 0
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
    IdeaEditView(
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
            status: .new,
            retrospective: nil
        ),
        onSave: { _ in }
    )
}
