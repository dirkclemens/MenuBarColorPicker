import SwiftUI

struct SwatchView: View {
    let color: NSColor
    let title: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    @State private var isHovering = false

    init(
        color: NSColor,
        title: String,
        width: CGFloat = 20,
        height: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.color = color
        self.title = title
        self.width = width
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: color))
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            }
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(isHovering ? 0.2 : 0.14), radius: isHovering ? 4 : 3, x: 0, y: 2)
            .scaleEffect(isHovering ? 1.03 : 1.0)
            .animation(.easeOut(duration: 0.12), value: isHovering)
            .accessibilityLabel(Text(title))
            .help(title)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct PlaceholderSwatchView: View {
    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.secondary.opacity(0.5))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.secondary)
        }
        .help(title)
        .frame(width: 20, height: 20)
    }
}
