import SwiftUI

struct MenuOneSectionHeaderView: View {
    let title: String
    let subtitle: String
    let color: Color
    let iconName: String

    var body: some View {
        HStack(spacing: screenHeight * 0.013) {
            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                .fill(color.opacity(0.1))
                .frame(width: screenHeight * 0.06, height: screenHeight * 0.06)
                .overlay {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.023, height: screenHeight * 0.023)
                }

            VStack(alignment: .leading, spacing: screenHeight * 0.003) {
                Text(title)
                    .font(.outfitMedium(size: screenHeight * 0.023))
                    .foregroundStyle(.black)

                Text(subtitle)
                    .font(.outfitLight(size: screenHeight * 0.018))
                    .foregroundStyle(.black.opacity(0.45))
            }

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color("bgColor").ignoresSafeArea()
        MenuOneSectionHeaderView(
            title: "Reach",
            subtitle: "How many people will this impact?",
            color: Color("appColor_1"),
            iconName: "reachIcon"
        )
        .padding()
    }
}
