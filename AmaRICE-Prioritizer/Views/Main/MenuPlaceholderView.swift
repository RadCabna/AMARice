import SwiftUI

struct MenuPlaceholderView: View {
    let title: String

    var body: some View {
        ZStack {
            Color("bgColor").ignoresSafeArea()
            Text(title)
                .font(.outfitMedium(size: screenHeight * 0.028))
                .foregroundStyle(.black.opacity(0.7))
        }
    }
}

#Preview {
    MenuPlaceholderView(title: "Menu 2")
}
