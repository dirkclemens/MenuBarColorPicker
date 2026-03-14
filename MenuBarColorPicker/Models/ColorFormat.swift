import Foundation
import SwiftUI

enum ColorFormat: String, CaseIterable, Identifiable {
    case hex
    case rgb
    case hsl

    var id: String { rawValue }

    var label: String {
        rawValue.uppercased()
    }
}

enum ColorFormatter {
    static func format(_ color: NSColor, format: ColorFormat, hexUppercase: Bool, hexPrefix: Bool) -> String {
        switch format {
        case .hex:
            return hexString(color, uppercase: hexUppercase, prefix: hexPrefix)
        case .rgb:
            return rgbString(color)
        case .hsl:
            return hslString(color)
        }
    }

    static func hexString(_ color: NSColor, uppercase: Bool, prefix: Bool) -> String {
        let c = color.srgb
        let r = Int((c.redComponent * 255.0).rounded())
        let g = Int((c.greenComponent * 255.0).rounded())
        let b = Int((c.blueComponent * 255.0).rounded())
        let format = uppercase ? "%02X%02X%02X" : "%02x%02x%02x"
        let hex = String(format: format, r, g, b)
        return prefix ? "#\(hex)" : hex
    }

    static func hexStringWithAlpha(_ color: NSColor, uppercase: Bool, prefix: Bool) -> String {
        let c = color.srgb
        let r = Int((c.redComponent * 255.0).rounded())
        let g = Int((c.greenComponent * 255.0).rounded())
        let b = Int((c.blueComponent * 255.0).rounded())
        let a = Int((c.alphaComponent * 255.0).rounded())
        let format = uppercase ? "%02X%02X%02X%02X" : "%02x%02x%02x%02x"
        let hex = String(format: format, r, g, b, a)
        return prefix ? "#\(hex)" : hex
    }

    static func rgbString(_ color: NSColor) -> String {
        let c = color.srgb
        let r = Int((c.redComponent * 255.0).rounded())
        let g = Int((c.greenComponent * 255.0).rounded())
        let b = Int((c.blueComponent * 255.0).rounded())
        return "rgb(\(r), \(g), \(b))"
    }

    static func rgbaString(_ color: NSColor) -> String {
        let c = color.srgb
        let r = Int((c.redComponent * 255.0).rounded())
        let g = Int((c.greenComponent * 255.0).rounded())
        let b = Int((c.blueComponent * 255.0).rounded())
        let a = Double(c.alphaComponent)
        return String(format: "rgba(%d, %d, %d, %.2f)", r, g, b, a)
    }

    static func hslString(_ color: NSColor) -> String {
        let c = color.srgb
        let hsl = rgbToHsl(r: c.redComponent, g: c.greenComponent, b: c.blueComponent)
        let h = Int(hsl.h.rounded())
        let s = Int((hsl.s * 100.0).rounded())
        let l = Int((hsl.l * 100.0).rounded())
        return "hsl(\(h), \(s)%, \(l)%)"
    }

    static func hslaString(_ color: NSColor) -> String {
        let c = color.srgb
        let hsl = rgbToHsl(r: c.redComponent, g: c.greenComponent, b: c.blueComponent)
        let h = Int(hsl.h.rounded())
        let s = Int((hsl.s * 100.0).rounded())
        let l = Int((hsl.l * 100.0).rounded())
        let a = Double(c.alphaComponent)
        return String(format: "hsla(%d, %d%%, %d%%, %.2f)", h, s, l, a)
    }

    static func lchString(_ color: NSColor) -> String {
        let c = color.srgb
        let xyz = rgbToXyz(r: c.redComponent, g: c.greenComponent, b: c.blueComponent)
        let lab = xyzToLab(x: xyz.x, y: xyz.y, z: xyz.z)
        let cVal = sqrt(lab.a * lab.a + lab.b * lab.b)
        var h = atan2(lab.b, lab.a) * 180.0 / .pi
        if h < 0 { h += 360.0 }
        return String(format: "lch(%.1f, %.1f, %.1f)", lab.l, cVal, h)
    }

    private static func rgbToHsl(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, l: CGFloat) {
        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let l = (maxVal + minVal) / 2.0

        if maxVal == minVal {
            return (0, 0, l)
        }

        let d = maxVal - minVal
        let s = l > 0.5 ? d / (2.0 - maxVal - minVal) : d / (maxVal + minVal)
        var h: CGFloat = 0.0

        if maxVal == r {
            h = (g - b) / d + (g < b ? 6.0 : 0.0)
        } else if maxVal == g {
            h = (b - r) / d + 2.0
        } else {
            h = (r - g) / d + 4.0
        }

        h /= 6.0
        return (h * 360.0, s, l)
    }

    private static func rgbToXyz(r: CGFloat, g: CGFloat, b: CGFloat) -> (x: Double, y: Double, z: Double) {
        func pivot(_ v: CGFloat) -> Double {
            let v = Double(v)
            return v > 0.04045 ? pow((v + 0.055) / 1.055, 2.4) : (v / 12.92)
        }
        let r = pivot(r)
        let g = pivot(g)
        let b = pivot(b)
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505
        return (x, y, z)
    }

    private static func xyzToLab(x: Double, y: Double, z: Double) -> (l: Double, a: Double, b: Double) {
        let xr = x / 0.95047
        let yr = y / 1.00000
        let zr = z / 1.08883

        func f(_ t: Double) -> Double {
            return t > 0.008856 ? pow(t, 1.0 / 3.0) : (7.787 * t + 16.0 / 116.0)
        }

        let fx = f(xr)
        let fy = f(yr)
        let fz = f(zr)

        let l = 116.0 * fy - 16.0
        let a = 500.0 * (fx - fy)
        let b = 200.0 * (fy - fz)
        return (l, a, b)
    }
}

extension NSColor {
    var srgb: NSColor {
        usingColorSpace(.sRGB) ?? self
    }

    convenience init?(hex: String) {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        guard !hexString.isEmpty else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&value) else { return nil }

        let r: UInt64
        let g: UInt64
        let b: UInt64
        let a: UInt64

        switch hexString.count {
        case 3:
            r = ((value >> 8) & 0xF) * 17
            g = ((value >> 4) & 0xF) * 17
            b = (value & 0xF) * 17
            a = 0xFF
        case 4:
            r = ((value >> 12) & 0xF) * 17
            g = ((value >> 8) & 0xF) * 17
            b = ((value >> 4) & 0xF) * 17
            a = (value & 0xF) * 17
        case 6:
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            a = 0xFF
        case 8:
            r = (value >> 24) & 0xFF
            g = (value >> 16) & 0xFF
            b = (value >> 8) & 0xFF
            a = value & 0xFF
        default:
            return nil
        }

        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(a) / 255.0)
    }
}
