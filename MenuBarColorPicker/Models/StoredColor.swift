import SwiftUI

struct StoredColor: Identifiable, Codable, Equatable {
    let id: UUID
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(id: UUID = UUID(), color: NSColor) {
        let c = color.srgb
        self.id = id
        self.red = Double(c.redComponent)
        self.green = Double(c.greenComponent)
        self.blue = Double(c.blueComponent)
        self.alpha = Double(c.alphaComponent)
    }

    var nsColor: NSColor {
        NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
