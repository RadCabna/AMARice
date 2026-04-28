import SwiftUI
import UIKit

extension View {
    var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
