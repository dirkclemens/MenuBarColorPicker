import SwiftUI

struct ColorListView: View {
    enum ListMode: String, CaseIterable, Identifiable {
        case standard
        case developer
        case webSafe
        case cssNamed
        case ralClassic

        var id: String { rawValue }

        var label: String {
            switch self {
            case .standard: return "Std."
            case .developer: return "Dev"
            case .webSafe: return "Web"
            case .cssNamed: return "CSS"
            case .ralClassic: return "Ind."
            }
        }
    }

    struct NamedColor: Identifiable {
        let id = UUID()
        let name: String
        let color: NSColor
    }

    var onSelect: (NSColor) -> Void
    var onAdd: (NSColor) -> Void

    @State private var mode: ListMode = .developer

    var body: some View {
        VStack(spacing: 10) {
            Picker("", selection: $mode) {
                ForEach(ListMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            List(currentList) { item in
                HStack(spacing: 8) {
                    SwatchView(color: item.color, title: item.name) {
                        let color = item.color
                        onSelect(item.color)
                        ClipboardManager.copy(ColorFormatter.hexString(color, uppercase: true, prefix: true))
                    }
                    .frame(width: 20, height: 20)
                    Text(item.name)
                        .font(.caption)
 
                    Spacer()

                    Button() {
                        onAdd(item.color)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(item.color)
                }
            }
            .listStyle(.plain)
            .frame(height: 220)
        }
    }

    private var currentList: [NamedColor] {
        switch mode {
        case .standard:
            return standardColors
        case .developer:
            return developerColors
        case .webSafe:
            return webSafeColors
        case .cssNamed:
            return cssNamedColors
        case .ralClassic:
            return ralClassicColors
        }
    }

    private var developerColors: [NamedColor] {
        [
            NamedColor(name: "labelColor", color: .labelColor),
            NamedColor(name: "secondaryLabelColor", color: .secondaryLabelColor),
            NamedColor(name: "tertiaryLabelColor", color: .tertiaryLabelColor),
            NamedColor(name: "quaternaryLabelColor", color: .quaternaryLabelColor),
            NamedColor(name: "textColor", color: .textColor),
            NamedColor(name: "placeholderTextColor", color: .placeholderTextColor),
            NamedColor(name: "selectedTextColor", color: .selectedTextColor),
            NamedColor(name: "textBackgroundColor", color: .textBackgroundColor),
            NamedColor(name: "selectedTextBackgroundColor", color: .selectedTextBackgroundColor),
            NamedColor(name: "controlColor", color: .controlColor),
            NamedColor(name: "controlTextColor", color: .controlTextColor),
            NamedColor(name: "selectedControlColor", color: .selectedControlColor),
            NamedColor(name: "selectedControlTextColor", color: .selectedControlTextColor),
            NamedColor(name: "disabledControlTextColor", color: .disabledControlTextColor),
            NamedColor(name: "windowBackgroundColor", color: .windowBackgroundColor),
            NamedColor(name: "windowFrameTextColor", color: .windowFrameTextColor),
            NamedColor(name: "gridColor", color: .gridColor),
            NamedColor(name: "separatorColor", color: .separatorColor),
            NamedColor(name: "headerTextColor", color: .headerTextColor),
            NamedColor(name: "linkColor", color: .linkColor),
            NamedColor(name: "systemRedColor", color: .systemRed),
            NamedColor(name: "systemGreenColor", color: .systemGreen),
            NamedColor(name: "systemBlueColor", color: .systemBlue),
            NamedColor(name: "systemOrangeColor", color: .systemOrange),
            NamedColor(name: "systemYellowColor", color: .systemYellow),
            NamedColor(name: "systemPinkColor", color: .systemPink),
            NamedColor(name: "systemPurpleColor", color: .systemPurple),
            NamedColor(name: "systemTealColor", color: .systemTeal),
            NamedColor(name: "systemIndigoColor", color: .systemIndigo),
            NamedColor(name: "systemBrownColor", color: .systemBrown),
            NamedColor(name: "systemGrayColor", color: .systemGray),
            NamedColor(name: "systemGray2Color", color: NSColor.systemGray.withAlphaComponent(0.85)),
            NamedColor(name: "systemGray3Color", color: NSColor.systemGray.withAlphaComponent(0.7)),
            NamedColor(name: "systemGray4Color", color: NSColor.systemGray.withAlphaComponent(0.55)),
            NamedColor(name: "systemGray5Color", color: NSColor.systemGray.withAlphaComponent(0.4)),
            NamedColor(name: "systemGray6Color", color: NSColor.systemGray.withAlphaComponent(0.25))
        ]
    }

    private var webSafeColors: [NamedColor] {
        var list: [NamedColor] = []
        let steps: [Int] = [0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]
        for r in steps {
            for g in steps {
                for b in steps {
                    let name = String(format: "#%02X%02X%02X", r, g, b)
                    let color = NSColor(red: CGFloat(r) / 255.0,
                                        green: CGFloat(g) / 255.0,
                                        blue: CGFloat(b) / 255.0,
                                        alpha: 1.0)
                    list.append(NamedColor(name: name, color: color))
                }
            }
        }
        return list
    }

    
    private var standardColors: [NamedColor] {
        namedColors(from: ColorListData.standard, includeHex: false)
    }
    
    private var cssNamedColors: [NamedColor] {
        namedColors(from: ColorListData.cssNamed, includeHex: false)
    }

    private var ralClassicColors: [NamedColor] {
        namedColors(from: ColorListData.ralClassic, includeHex: false)
    }

    private func namedColors(from entries: [ColorListData.Entry], includeHex: Bool) -> [NamedColor] {
        entries.compactMap { entry in
            guard let color = NSColor(hex: entry.hex) else { return nil }
            let name = includeHex ? "\(entry.name) (\(entry.hex))" : entry.name
            return NamedColor(name: name, color: color)
        }
    }
}
