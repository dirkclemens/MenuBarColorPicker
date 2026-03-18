import AppKit

final class MagnifierView: NSView {
    var image: CGImage? {
        didSet { needsDisplay = true }
    }

    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        context.saveGState()
        context.addEllipse(in: bounds)
        context.clip()

        if let image = image {
            context.interpolationQuality = .none
            context.draw(image, in: bounds)
        } else {
            context.setFillColor(NSColor.black.withAlphaComponent(0.15).cgColor)
            context.fill(bounds)
        }

        context.restoreGState()

        context.setStrokeColor(NSColor.white.withAlphaComponent(0.85).cgColor)
        context.setLineWidth(3.0)
        context.addEllipse(in: bounds.insetBy(dx: 1.5, dy: 1.5))
        context.strokePath()

        context.setStrokeColor(NSColor.black.withAlphaComponent(0.25).cgColor)
        context.setLineWidth(1.0)
        context.addEllipse(in: bounds.insetBy(dx: 4.0, dy: 4.0))
        context.strokePath()

        let dotRadius: CGFloat = 3.0
        context.setFillColor(NSColor.white.cgColor)
        context.addEllipse(in: CGRect(x: center.x - dotRadius, y: center.y - dotRadius, width: dotRadius * 2.0, height: dotRadius * 2.0))
        context.fillPath()
    }
}
