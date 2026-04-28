import SwiftUI

struct ConfidenceSliderView: View {
    @Binding var value: Double
    let tintColor: Color

    var body: some View {
        GeometryReader { geometry in
            let thumbSize = screenHeight * 0.025
            let trackHeight = screenHeight * 0.010
            let clamped = min(max(value, 0), 1)
            let width = max(geometry.size.width, 1)
            let range = max(width - thumbSize, 1)
            let x = CGFloat(clamped) * range

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(tintColor)
                    .frame(width: x + thumbSize * 0.5, height: trackHeight)

                Circle()
                    .fill(.white)
                    .overlay(
                        Circle()
                            .stroke(tintColor, lineWidth: 2)
                    )
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: x)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let location = min(max(gesture.location.x, thumbSize * 0.5), width - thumbSize * 0.5)
                        let progress = (location - thumbSize * 0.5) / range
                        value = min(max(progress, 0), 1)
                    }
            )
        }
        .frame(height: screenHeight * 0.03)
    }
}

#Preview {
    VStack {
        ConfidenceSliderView(
            value: .constant(0.8),
            tintColor: Color("appColor_3")
        )
    }
    .padding()
}
