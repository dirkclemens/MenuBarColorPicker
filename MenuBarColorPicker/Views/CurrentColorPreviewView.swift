import AppKit
import SwiftUI

struct CurrentColorPreviewView: View {
    let color: NSColor
    let onCopy: (NSColor) -> Void
    let onAdd: (NSColor) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            SwatchView(color: color, title: "Current Color", width: 128, height: 20) {
                onCopy(color)
            }
            .frame(width: 128, height: 32)
            Spacer()
            Button {
                onAdd(color)
            } label: {
                Image(systemName: "plus.circle")
            }
            .frame(width: 32, height: 32)
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
