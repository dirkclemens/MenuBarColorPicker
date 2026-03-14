import SwiftUI

struct PaletteColor: Identifiable {
    let id = UUID()
    let name: String
    let color: NSColor
}

enum PaletteCatalog {
    static let colors: [PaletteColor] = [
        // Grayscale: black to white
        PaletteColor(name: "Black", color: NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
        PaletteColor(name: "Charcoal", color: NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)),
        PaletteColor(name: "Graphite", color: NSColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)),
        PaletteColor(name: "Slate", color: NSColor(red: 0.35, green: 0.36, blue: 0.38, alpha: 1.0)),
        PaletteColor(name: "Gray", color: NSColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)),
        PaletteColor(name: "Silver", color: NSColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.0)),
        PaletteColor(name: "Light Gray", color: NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)),
        PaletteColor(name: "Cloud", color: NSColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)),
        PaletteColor(name: "Snow", color: NSColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)),
        PaletteColor(name: "White", color: NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),

        // Reds
        PaletteColor(name: "Deep Red", color: NSColor(red: 0.60, green: 0.08, blue: 0.10, alpha: 1.0)),
        PaletteColor(name: "Crimson", color: NSColor(red: 0.78, green: 0.12, blue: 0.16, alpha: 1.0)),
        PaletteColor(name: "Red", color: NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)),
        PaletteColor(name: "Tomato", color: NSColor(red: 0.98, green: 0.32, blue: 0.25, alpha: 1.0)),
        PaletteColor(name: "Coral", color: NSColor(red: 0.98, green: 0.38, blue: 0.32, alpha: 1.0)),
        PaletteColor(name: "Salmon", color: NSColor(red: 0.98, green: 0.50, blue: 0.45, alpha: 1.0)),

        // Oranges
        PaletteColor(name: "Rust", color: NSColor(red: 0.82, green: 0.32, blue: 0.12, alpha: 1.0)),
        PaletteColor(name: "Orange", color: NSColor(red: 0.98, green: 0.45, blue: 0.12, alpha: 1.0)),
        PaletteColor(name: "Tangerine", color: NSColor(red: 0.98, green: 0.55, blue: 0.18, alpha: 1.0)),
        PaletteColor(name: "Apricot", color: NSColor(red: 0.98, green: 0.64, blue: 0.38, alpha: 1.0)),

        // Yellows
        PaletteColor(name: "Amber", color: NSColor(red: 0.98, green: 0.70, blue: 0.12, alpha: 1.0)),
        PaletteColor(name: "Gold", color: NSColor(red: 0.85, green: 0.72, blue: 0.18, alpha: 1.0)),
        PaletteColor(name: "Yellow", color: NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)),
        PaletteColor(name: "Lemon", color: NSColor(red: 0.98, green: 0.94, blue: 0.35, alpha: 1.0)),

        // Yellow-Greens
        PaletteColor(name: "Olive", color: NSColor(red: 0.40, green: 0.44, blue: 0.20, alpha: 1.0)),
        PaletteColor(name: "Chartreuse", color: NSColor(red: 0.50, green: 0.80, blue: 0.20, alpha: 1.0)),
        PaletteColor(name: "Lime", color: NSColor(red: 0.62, green: 0.86, blue: 0.26, alpha: 1.0)),

        // Greens
        PaletteColor(name: "Green", color: NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)),
        PaletteColor(name: "Forest", color: NSColor(red: 0.10, green: 0.35, blue: 0.20, alpha: 1.0)),
        PaletteColor(name: "Emerald", color: NSColor(red: 0.05, green: 0.60, blue: 0.42, alpha: 1.0)),

        // Green-Cyans
        PaletteColor(name: "Mint", color: NSColor(red: 0.20, green: 0.76, blue: 0.57, alpha: 1.0)),
        PaletteColor(name: "Seafoam", color: NSColor(red: 0.40, green: 0.84, blue: 0.70, alpha: 1.0)),

        // Cyans
        PaletteColor(name: "Teal", color: NSColor(red: 0.10, green: 0.65, blue: 0.62, alpha: 1.0)),
        PaletteColor(name: "Cyan", color: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)),
        PaletteColor(name: "Aqua", color: NSColor(red: 0.20, green: 0.85, blue: 0.95, alpha: 1.0)),

        // Blues
        PaletteColor(name: "Sky", color: NSColor(red: 0.24, green: 0.58, blue: 0.92, alpha: 1.0)),
        PaletteColor(name: "Blue", color: NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)),
        PaletteColor(name: "Royal", color: NSColor(red: 0.20, green: 0.28, blue: 0.78, alpha: 1.0)),
        PaletteColor(name: "Navy", color: NSColor(red: 0.10, green: 0.15, blue: 0.30, alpha: 1.0)),
        PaletteColor(name: "Ice", color: NSColor(red: 0.80, green: 0.92, blue: 0.98, alpha: 1.0)),

        // Purples
        PaletteColor(name: "Indigo", color: NSColor(red: 0.30, green: 0.33, blue: 0.86, alpha: 1.0)),
        PaletteColor(name: "Violet", color: NSColor(red: 0.56, green: 0.36, blue: 0.92, alpha: 1.0)),
        PaletteColor(name: "Purple", color: NSColor(red: 0.64, green: 0.30, blue: 0.82, alpha: 1.0)),

        // Magentas & Pinks
        PaletteColor(name: "Magenta", color: NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)),
        PaletteColor(name: "Hot Pink", color: NSColor(red: 0.95, green: 0.20, blue: 0.60, alpha: 1.0)),
        PaletteColor(name: "Pink", color: NSColor(red: 0.95, green: 0.33, blue: 0.54, alpha: 1.0)),

        // Neutrals / Browns
        PaletteColor(name: "Cocoa", color: NSColor(red: 0.45, green: 0.32, blue: 0.25, alpha: 1.0)),
        PaletteColor(name: "Brown", color: NSColor(red: 0.55, green: 0.38, blue: 0.29, alpha: 1.0)),
        PaletteColor(name: "Sand", color: NSColor(red: 0.78, green: 0.70, blue: 0.55, alpha: 1.0)),
        PaletteColor(name: "Steel", color: NSColor(red: 0.32, green: 0.40, blue: 0.52, alpha: 1.0))
    ]
}
