import SwiftUI

struct MenuTwoView: View {
    @EnvironmentObject private var ideaStore: IdeaStoreViewModel
    @StateObject private var viewModel = MenuTwoViewModel()
    @State private var topPanelMeasuredHeight: CGFloat = 0
    @State private var suppressTopInsetAnimationOnce = true
    @State private var selectedIdea: IdeaItem?
    @State private var ideaPendingDelete: IdeaItem?

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: screenHeight * 0.014) {
                    ideasList
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, topPanelMeasuredHeight + screenHeight * 0.02)
                .padding(.bottom, screenHeight * 0.13)
            }

            topPanel
                .animation(.easeInOut(duration: 0.22), value: viewModel.isFilterExpanded)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                applyTopPanelHeight(proxy.size.height)
                            }
                            .onChange(of: proxy.size.height) { _, newValue in
                                applyTopPanelHeight(newValue)
                            }
                    }
                )
        }
        .onAppear {
            suppressTopInsetAnimationOnce = true
        }
        .gesture(
            TapGesture().onEnded { dismissKeyboard() },
            including: .gesture
        )
        .fullScreenCover(item: $selectedIdea) { idea in
            IdeaDetailView(idea: idea) { updated in
                ideaStore.updateIdea(updated)
            }
        }
        .alert(
            "Delete idea?",
            isPresented: Binding(
                get: { ideaPendingDelete != nil },
                set: { if !$0 { ideaPendingDelete = nil } }
            ),
            presenting: ideaPendingDelete
        ) { idea in
            Button("Delete", role: .destructive) {
                ideaStore.deleteIdea(id: idea.id)
                ideaPendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                ideaPendingDelete = nil
            }
        } message: { _ in
            Text("This action cannot be undone.")
        }
    }

    private func applyTopPanelHeight(_ newValue: CGFloat) {
        guard newValue > 0 else { return }
        if suppressTopInsetAnimationOnce {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                topPanelMeasuredHeight = newValue
            }
            suppressTopInsetAnimationOnce = false
            return
        }
        guard abs(newValue - topPanelMeasuredHeight) > 0.5 else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            topPanelMeasuredHeight = newValue
        }
    }

    private var topPanel: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: screenHeight * 0.014) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: screenHeight * 0.003) {
                        Text("Ideas Backlog")
                            .font(.outfitMedium(size: screenHeight * 0.025))
                            .foregroundStyle(.black)
                        Text("\(ideaStore.ideas.count) ideas")
                            .font(.outfitLight(size: screenHeight * 0.018))
                            .foregroundStyle(.black.opacity(0.6))
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            viewModel.isFilterExpanded.toggle()
                        }
                    } label: {
                        Image("filterIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.028, height: screenHeight * 0.028)
                            .padding(.top, screenHeight * 0.012)
                    }
                }

                if viewModel.isFilterExpanded {
                    filterPanel
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, screenHeight * 0.02)
            .padding(.bottom, screenHeight * 0.02)
            .background(.white)
            .shadow(color: .black.opacity(0.09), radius: screenHeight * 0.005, x: 0, y: screenHeight * 0.003)
        }
    }

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            HStack(spacing: screenHeight * 0.009) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.black.opacity(0.45))
                TextField(
                    "",
                    text: $viewModel.searchText,
                    prompt: Text("Search ideas...")
                        .foregroundStyle(.black.opacity(0.35))
                )
                .font(.outfitLight(size: screenHeight * 0.018))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, screenHeight * 0.018)
            .frame(height: screenHeight * 0.05)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.018)
                    .fill(Color.gray.opacity(0.08))
            )

            HStack(alignment: .center, spacing: screenHeight * 0.012) {
                Text("Filter:")
                    .font(.outfitLight(size: screenHeight * 0.019))
                    .foregroundStyle(.black.opacity(0.65))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: screenHeight * 0.01) {
                        ForEach(MenuTwoViewModel.StatusFilter.allCases) { status in
                            Button {
                                viewModel.selectedStatus = status
                            } label: {
                                Text(status.rawValue)
                                    .font(.outfitLight(size: screenHeight * 0.017))
                                    .foregroundStyle(viewModel.selectedStatus == status ? .white : .black.opacity(0.8))
                                    .padding(.horizontal, screenHeight * 0.015)
                                    .padding(.vertical, screenHeight * 0.008)
                                    .background(
                                        RoundedRectangle(cornerRadius: screenHeight * 0.014)
                                            .fill(viewModel.selectedStatus == status ? Color(red: 0.07, green: 0.13, blue: 0.24) : Color.gray.opacity(0.08))
                                    )
                            }
                        }
                    }
                }
            }

            HStack(alignment: .center, spacing: screenHeight * 0.012) {
                Text("Sort by:")
                    .font(.outfitLight(size: screenHeight * 0.019))
                    .foregroundStyle(.black.opacity(0.65))

                HStack(spacing: screenHeight * 0.01) {
                    ForEach(MenuTwoViewModel.SortOption.allCases) { option in
                        Button {
                            viewModel.selectedSort = option
                        } label: {
                            Text(option.rawValue)
                                .font(.outfitLight(size: screenHeight * 0.017))
                                .foregroundStyle(viewModel.selectedSort == option ? .white : .black.opacity(0.8))
                                .padding(.horizontal, screenHeight * 0.018)
                                .padding(.vertical, screenHeight * 0.009)
                                .background(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.014)
                                        .fill(viewModel.selectedSort == option ? Color(red: 0.07, green: 0.13, blue: 0.24) : Color.gray.opacity(0.08))
                                )
                        }
                    }
                }
            }
        }
    }

    private var ideasList: some View {
        let ideas = viewModel.filteredIdeas(from: ideaStore.ideas)
        return VStack(spacing: screenHeight * 0.014) {
            if ideas.isEmpty {
                Text("No ideas yet")
                    .font(.outfitLight(size: screenHeight * 0.022))
                    .foregroundStyle(.black.opacity(0.45))
                    .frame(maxWidth: .infinity)
                    .padding(.top, screenHeight * 0.06)
            } else {
                ForEach(ideas) { idea in
                    SwipeIdeaCardRowView(
                        idea: idea,
                        onOpen: {
                            selectedIdea = idea
                        },
                        onDelete: {
                            ideaPendingDelete = idea
                        },
                        onSetInProgress: {
                            ideaStore.updateIdeaStatus(id: idea.id, status: .inProgress)
                        }
                    )
                }
            }
        }
    }

}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        MenuTwoView()
            .environmentObject(IdeaStoreViewModel())
    }
}
