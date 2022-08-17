import Foundation
import SwiftUI

extension Backport where Content: View {
    @ViewBuilder func scrollDismissesKeyboard() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }
}
