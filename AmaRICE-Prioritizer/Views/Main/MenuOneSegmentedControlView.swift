import SwiftUI

struct MenuOneSegmentedControlView<Item: Identifiable & Hashable>: View where Item: RawRepresentable, Item.RawValue == String {
    let items: [Item]
    @Binding var selected: Item
    let accentColor: Color

    var body: some View {
        HStack(spacing: screenHeight * 0.011) {
            ForEach(items, id: \.self) { item in
                Button {
                    selected = item
                } label: {
                    Text(item.rawValue)
                        .font(.outfitMedium(size: screenHeight * 0.017))
                        .foregroundStyle(selected == item ? .white : .black.opacity(0.7))
                        .padding(.horizontal, screenHeight * 0.018)
                        .padding(.vertical, screenHeight * 0.014)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.016)
                                .fill(selected == item ? accentColor : Color.gray.opacity(0.12))
                        )
                }
            }
        }
    }
}

#Preview {
    MenuOneSegmentedControlView(
        items: MenuOneViewModel.ReachUnit.allCases,
        selected: .constant(.users),
        accentColor: Color("appColor_1")
    )
    .padding()
}
