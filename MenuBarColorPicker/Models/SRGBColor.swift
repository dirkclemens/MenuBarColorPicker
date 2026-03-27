import AppKit

struct SRGBColor: Equatable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init?(_ color: NSColor) {
        let c = color.srgb
        r = Double(c.redComponent)
        g = Double(c.greenComponent)
        b = Double(c.blueComponent)
        a = Double(c.alphaComponent)
    }

    var nsColor: NSColor {
        NSColor(red: r, green: g, blue: b, alpha: a)
    }

    func clamped() -> SRGBColor {
        SRGBColor(
            r: SRGBColor.clamp01(r),
            g: SRGBColor.clamp01(g),
            b: SRGBColor.clamp01(b),
            a: SRGBColor.clamp01(a)
        )
    }

    static func fromCMYK(c: Double, m: Double, y: Double, k: Double, alpha: Double = 1.0) -> SRGBColor {
        let cVal = clamp01(c)
        let mVal = clamp01(m)
        let yVal = clamp01(y)
        let kVal = clamp01(k)
        let r = (1.0 - cVal) * (1.0 - kVal)
        let g = (1.0 - mVal) * (1.0 - kVal)
        let b = (1.0 - yVal) * (1.0 - kVal)
        return SRGBColor(r: r, g: g, b: b, a: clamp01(alpha))
    }

    static func fromHSB(h: Double, s: Double, b: Double, alpha: Double = 1.0) -> SRGBColor {
        let color = NSColor(calibratedHue: clamp01(h), saturation: clamp01(s), brightness: clamp01(b), alpha: clamp01(alpha))
        return SRGBColor(color) ?? SRGBColor(r: 0, g: 0, b: 0, a: clamp01(alpha))
    }

    static func clamp01(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }
}
