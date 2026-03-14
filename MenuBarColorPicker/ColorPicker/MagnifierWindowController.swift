import AppKit

final class MagnifierWindowController {
    private let panel: NSPanel
    private let magnifierView: MagnifierView
    private let size = CGSize(width: 140, height: 140)

    init() {
        magnifierView = MagnifierView(frame: CGRect(origin: .zero, size: size))
        panel = NSPanel(contentRect: CGRect(origin: .zero, size: size),
                        styleMask: [.borderless, .nonactivatingPanel],
                        backing: .buffered,
                        defer: false)
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.contentView = magnifierView
    }

    func show() {
        panel.orderFrontRegardless()
    }

    func hide() {
        panel.orderOut(nil)
    }

    func update(image: CGImage?, at point: NSPoint) {
        magnifierView.image = image
        magnifierView.toolTip = String(format: "mouse: %.1f, %.1f", point.x, point.y)
        let origin = NSPoint(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0)
        panel.setFrameOrigin(origin)
    }
}
