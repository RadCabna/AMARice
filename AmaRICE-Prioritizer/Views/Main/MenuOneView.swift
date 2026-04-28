import SwiftUI

struct MenuOneView: View {
    private enum InputField: Hashable {
        case ideaName
        case description
    }

    let onSaved: () -> Void
    @EnvironmentObject private var ideaStore: IdeaStoreViewModel
    @StateObject private var viewModel = MenuOneViewModel()
    @State private var keyboardHeight: CGFloat = 0
    @State private var showIdeaNameError = false
    @State private var showDescriptionError = false
    @FocusState private var focusedField: InputField?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: screenHeight * 0.02) {
                    firstSection
                        .id("firstSection")
                    reachSection
                    impactSection
                    confidenceSection
                    effortSection
                    scoreSection
                    saveButton(proxy: proxy)
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.06)
                .padding(.bottom, screenHeight * 0.13 + max(0, keyboardHeight - screenHeight * 0.04))
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

    private var firstSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text("Idea Name")
                .font(.outfitLight(size: screenHeight * 0.019))
                .foregroundStyle(.black)

            textField("Add dark mode", text: $viewModel.ideaName, minHeight: screenHeight * 0.052)
                .focused($focusedField, equals: .ideaName)
            if showIdeaNameError {
                Text("Please fill in Idea Name")
                    .font(.outfitLight(size: screenHeight * 0.014))
                    .foregroundStyle(.red)
            }

            Text("Description")
                .font(.outfitLight(size: screenHeight * 0.019))
                .foregroundStyle(.black)

            descriptionField("Describe your idea...", text: $viewModel.ideaDescription)
                .focused($focusedField, equals: .description)
            if showDescriptionError {
                Text("Please fill in Description")
                    .font(.outfitLight(size: screenHeight * 0.014))
                    .foregroundStyle(.red)
            }
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

            textField("500", text: $viewModel.reachValue, minHeight: screenHeight * 0.052)
                .keyboardType(.numberPad)

            MenuOneSegmentedControlView(
                items: MenuOneViewModel.ReachUnit.allCases,
                selected: $viewModel.selectedReachUnit,
                accentColor: Color("appColor_1")
            )
        }
        .padding(.horizontal, screenHeight * 0.03)
        .padding(.vertical, screenHeight * 0.035)
        .background(RoundedRectangle(cornerRadius: screenHeight * 0.02).fill(.white))
        .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
    }

    private var impactSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            MenuOneSectionHeaderView(
                title: "Impact",
                subtitle: "How much will it help each person?",
                color: Color("appColor_4"),
                iconName: "impactIcon"
            )

            VStack(spacing: screenHeight * 0.011) {
                ForEach(MenuOneViewModel.ImpactLevel.allCases) { level in
                    Button {
                        viewModel.selectedImpact = level
                    } label: {
                        HStack {
                            Text(level.rawValue)
                                .font(.outfitLight(size: screenHeight * 0.016))
                                .foregroundStyle(viewModel.selectedImpact == level ? .white : .black)

                            Spacer()

                            Text(level.multiplier)
                                .font(.outfitLight(size: screenHeight * 0.015))
                                .foregroundStyle(viewModel.selectedImpact == level ? .white : .black.opacity(0.55))
                        }
                        .padding(.horizontal, screenHeight * 0.017)
                        .padding(.vertical, screenHeight * 0.016)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                                .fill(viewModel.selectedImpact == level ? Color("appColor_4") : Color.gray.opacity(0.12))
                        )
                    }
                }
                .padding(.vertical, screenHeight * 0.002)
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
                Text("\(Int(viewModel.confidence * 100))%")
                    .font(.outfitMedium(size: screenHeight * 0.036))
                    .foregroundStyle(Color("appColor_3"))
                Spacer()
                Text("High")
                    .font(.outfitLight(size: screenHeight * 0.016))
                    .foregroundStyle(.black.opacity(0.65))
            }

            ConfidenceSliderView(
                value: $viewModel.confidence,
                tintColor: Color("appColor_3")
            )
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

            textField("2", text: $viewModel.effortValue, minHeight: screenHeight * 0.052)
                .keyboardType(.numberPad)

            MenuOneSegmentedControlView(
                items: MenuOneViewModel.EffortUnit.allCases,
                selected: $viewModel.selectedEffortUnit,
                accentColor: Color("appColor_2")
            )
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

            Text(viewModel.riceScoreDisplay)
                .font(.outfitLight(size: screenHeight * 0.075))
                .foregroundStyle(.white)

            Text(viewModel.ricePriorityBand?.title ?? "—")
                .font(.outfitLight(size: screenHeight * 0.017))
                .foregroundStyle(.white)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.006)
                .background(
                    Capsule()
                        .fill(Color(viewModel.ricePriorityBand?.backgroundAssetName ?? "appColor_5"))
                )
                .padding(.bottom)

            VStack(spacing: screenHeight * 0.005) {
                Text("Formula")
                    .font(.outfitLight(size: screenHeight * 0.02))
                    .foregroundStyle(.white.opacity(0.7))
                Text(viewModel.riceFormulaLine)
                    .font(.outfitLight(size: screenHeight * 0.018))
                    .foregroundStyle(.white)
            }
            .padding(.vertical, screenHeight * 0.025)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.02)
                    .fill(Color(.white).opacity(0.1))
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

    private func saveButton(proxy: ScrollViewProxy) -> some View {
        Button {
            validateRequiredFields()
            if showIdeaNameError || showDescriptionError {
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo("firstSection", anchor: .top)
                }
                if showIdeaNameError {
                    focusedField = .ideaName
                } else if showDescriptionError {
                    focusedField = .description
                }
                return
            }

            guard let idea = viewModel.buildIdeaItem() else { return }
            ideaStore.addIdea(idea)
            viewModel.resetAfterSave()
            showIdeaNameError = false
            showDescriptionError = false
            focusedField = nil
            onSaved()
        } label: {
            HStack {
                Image(.saveIdeaIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.02)
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

    private func textField(_ placeholder: String, text: Binding<String>, minHeight: CGFloat) -> some View {
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
        .frame(minHeight: minHeight)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                .fill(Color.gray.opacity(0.06))
        )
    }

    private func descriptionField(_ placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: text)
                .font(.outfitLight(size: screenHeight * 0.018))
                .foregroundStyle(.black)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.01)
                .frame(minHeight: screenHeight * 0.102, maxHeight: screenHeight * 0.102)

            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.outfitLight(size: screenHeight * 0.016))
                    .foregroundStyle(.black.opacity(0.4))
                    .padding(.leading, screenHeight * 0.016)
                    .padding(.top, screenHeight * 0.016)
                    .allowsHitTesting(false)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                .fill(Color.gray.opacity(0.06))
        )
    }

    private func validateRequiredFields() {
        showIdeaNameError = viewModel.ideaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        showDescriptionError = viewModel.ideaDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        MenuOneView(onSaved: {})
    }
}
