import SwiftUI

enum PaletteMode: String, CaseIterable, Identifiable {
    case swatches
    case wheel
    case spectrum
    case sliders
    case list

    var id: String { rawValue }

    var label: String {
        switch self {
        case .swatches: return "Swatches"
        case .wheel: return "Wheel"
        case .spectrum: return "Spectrum"
        case .sliders: return "Sliders"
        case .list: return "List"
        }
    }

    var iconName: String {
        switch self {
        case .swatches: return "square.grid.3x3"
        case .wheel: return "circle.hexagongrid.fill"
        case .spectrum: return "square"
        case .sliders: return "switch.2"
        case .list: return "swatchpalette"
        }
    }
}
