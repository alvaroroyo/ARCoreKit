import SwiftUI

public extension View {
    func resignAllFocus() {
        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .endEditing(true)
    }
}
