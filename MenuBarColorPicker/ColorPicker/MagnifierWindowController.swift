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

//    func update(image: CGImage?, displayPoint: NSPoint, eventPoint: NSPoint) {
    func update(image: CGImage?, at: NSPoint, in screen: NSScreen) {
        magnifierView.image = image
        magnifierView.toolTip = String(format: "%.1f, %.1f", at.x, at.y)
        let frame = screen.visibleFrame
//        let edgeMargin: CGFloat = 16.0
//        let offset = CGPoint(x: size.width / 2.0 + edgeMargin, y: size.height / 2.0 + edgeMargin)
        let offset = CGPoint(x: 0, y: 0)
        let centers = [
            CGPoint(x: at.x + offset.x, y: at.y + offset.y),
            CGPoint(x: at.x - offset.x, y: at.y + offset.y),
            CGPoint(x: at.x + offset.x, y: at.y - offset.y),
            CGPoint(x: at.x - offset.x, y: at.y - offset.y)
        ]

        for center in centers {
            let candidate = CGRect(origin: CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0), size: size)
            if frame.contains(candidate) {
                panel.setFrameOrigin(candidate.origin)
                return
            }
        }


        var origin = CGPoint(x: at.x + offset.x - size.width / 2.0, y: at.y + offset.y - size.height / 2.0)
        origin.x = min(max(origin.x, frame.minX), frame.maxX - size.width)
        origin.y = min(max(origin.y, frame.minY), frame.maxY - size.height)
        panel.setFrameOrigin(origin)
    }
}
