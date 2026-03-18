import AppKit
import Foundation
import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var paletteStore: PaletteStore
    @EnvironmentObject private var colorPicker: ColorPickerManager
    @EnvironmentObject private var loginItemManager: LoginItemManager

    @AppStorage("hexUppercase") private var hexUppercase = true
    @AppStorage("hexPrefix") private var hexPrefix = true
    @AppStorage("showDockIcon") private var showDockIcon = false
    
    @State private var statusText: String = " "
    @State private var paletteMode: PaletteMode = .spectrum
    @State private var selectedColor: NSColor?
    @State private var lastCopiedFormat: String?

    private enum Page: Int, CaseIterable {
        case main
        case settings
    }
    @State private var page: Page = .main

    private let columns = Array(repeating: GridItem(.fixed(20), spacing: 4), count: 10)

    var body: some View {
        ZStack {
            if page == .main {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    paletteSwitcher
                    Divider()
                    colorValueCopyText
                    Divider()
                    customColors
                    Divider()
                    footerButtons
                }
                .padding(12)
                .frame(width: 260)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onChange(of: colorPicker.pickedColor) { _, color in
                    guard let color else { return }
                    paletteStore.add(color: color)
                    selectedColor = color
                    colorPicker.pickedColor = nil
                }
                .onChange(of: colorPicker.lastError) { _, error in
                    if let error {
                        statusText = error
                    }
                }
            }
            
            if page == .settings {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    SettingsView()
                    Divider()
                    footerButtons
                }
                .padding(12)
                .frame(width: 260)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: page)
    }

    private var header: some View {
        HStack {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 16, weight: .semibold))
            Text("MenuBar Color Picker")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
        }
    }

    private var paletteGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Palette")
                .font(.caption)
                .foregroundStyle(.secondary)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(PaletteCatalog.colors) { swatch in
                    SwatchView(color: swatch.color, title: swatch.name) {
                        selectColor(swatch.color)
                    }
                    .contextMenu {
                        formatContextMenu(for: swatch.color, name: swatch.name, allowRemove: false, remove: nil)
                    }
                }
            }
        }
    }

    private var colorWheelPalette: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color Wheel")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Spacer()
                ColorWheelView(
                    onSelect: { color in
                        selectColor(color)
                    },
                    onAdd: { color in
                        paletteStore.add(color: color)
                    }
                )
                Spacer()
            }
        }
    }

    private var colorSpectrumPalette: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color Spectrum")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Spacer()
                ColorSpectrumView(
                    onSelect: { color in
                        selectColor(color)
                    },
                    onAdd: { color in
                        paletteStore.add(color: color)
                    }
                )
                Spacer()
            }
        }
    }

    private var colorListPalette: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color List")
                .font(.caption)
                .foregroundStyle(.secondary)
            ColorListView(
                onSelect: { color in
                    selectColor(color)
                },
                onAdd: { color in
                    paletteStore.add(color: color)
                }
            )
        }
    }

    private var colorSliderPalette: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color Sliders")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack() {
                Spacer()
                ColorSliderView(
                    onSelect: { color in
                        selectColor(color)
                    },
                    onAdd: { color in
                        paletteStore.add(color: color)
                    }
                )
                Spacer()
            }
        }
    }

    private var paletteSwitcher: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(){
                Spacer()
                
                Picker("Palette View", selection: $paletteMode) {
                    ForEach(PaletteMode.allCases) { mode in
                        Label(mode.label, systemImage: mode.iconName)
                            .labelStyle(.iconOnly)
                            .help(mode.label)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                
                Spacer()
                
                Button() {
                    colorPicker.toggle()
                } label: {
                    Image(systemName: colorPicker.isActive ? "eyedropper" : "eyedropper.full")
                }
                .buttonStyle(.plain)
            }
            switch paletteMode {
            case .swatches:
                paletteGrid
            case .wheel:
                colorWheelPalette
            case .spectrum:
                colorSpectrumPalette
            case .sliders:
                colorSliderPalette
            case .list:
                colorListPalette
            }
        }
    }

    private var colorValueCopyText: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Color Formats")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                formatRow(label: "hex:", value: hexValue) {
                    ClipboardManager.copy(hexValue)
                }
                formatRow(label: "rgb:", value: rgbValue) {
                    ClipboardManager.copy(rgbValue)
                }
                formatRow(label: "hsl:", value: hslValue) {
                    ClipboardManager.copy(hslValue)
                }
                formatRow(label: "lch:", value: lchValue) {
                    ClipboardManager.copy(lchValue)
                }
            }
        }
    }
    
    private var customColors: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Custom Colors")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !paletteStore.customColors.isEmpty {
                    Button("Clear") {
                        paletteStore.clear()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<paletteStore.maxSlots, id: \.self) { index in
                    if index < paletteStore.customColors.count {
                        let stored = paletteStore.customColors[index]
                        SwatchView(color: stored.nsColor, title: "Custom \(index + 1)") {
                            selectColor(stored.nsColor)
                        }
                        .contextMenu {
                            formatContextMenu(for: stored.nsColor, name: "Custom \(index + 1)", allowRemove: true) {
                                paletteStore.remove(id: stored.id)
                            }
                        }
                    } else {
                        PlaceholderSwatchView(title: "")
                    }
                }
            }
        }
    }

    private var footerButtons: some View {
        HStack {
//            SettingsLink {
//                Image(systemName: "gear")
//                    .font(.system(size: 12))
//            }
            if (page == .settings) {
                Button(action: {
                    goToPreviousPage()
                }) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.system(size: 12))
                }
            } else {
                
                Button(action: {
                    goToNextPage()
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 12))
                }
            }
            
            Spacer()
            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "power")
                    .font(.system(size: 12))
            }
            .foregroundColor(.secondary)
            .help(NSLocalizedString("QuitMenuTitle", comment: ""))
        }
        .font(.caption)
    }

    private func goToPreviousPage() {
        guard let previous = Page(rawValue: page.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            page = previous
        }
    }

    private func goToNextPage() {
        guard let next = Page(rawValue: page.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            page = next
        }
    }
    
    private func selectColor(_ color: NSColor) {
        selectedColor = color
    }

    private var hexValue: String {
        guard let color = selectedColor else { return "" }
        let alpha = color.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.hexStringWithAlpha(color, uppercase: hexUppercase, prefix: hexPrefix)
        }
        return ColorFormatter.hexString(color, uppercase: hexUppercase, prefix: hexPrefix)
    }

    private var rgbValue: String {
        guard let color = selectedColor else { return "" }
        let alpha = color.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.rgbaString(color)
        }
        return ColorFormatter.rgbString(color)
    }

    private var hslValue: String {
        guard let color = selectedColor else { return "" }
        let alpha = color.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.hslaString(color)
        }
        return ColorFormatter.hslString(color)
    }

    private var lchValue: String {
        guard let color = selectedColor else { return "" }
        return ColorFormatter.lchString(color)
    }

    private func formatRow(label: String, value: String, copyAction: @escaping () -> Void) -> some View {
        HStack {
            TextField(label, text: .constant(value))
                .textFieldStyle(.roundedBorder)
                .disabled(true)
                .textSelection(.enabled)
            Button(action: copyAction) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
            }
            .disabled(value.isEmpty)
        }
    }

    @ViewBuilder
    private func formatContextMenu(for color: NSColor, name: String, allowRemove: Bool, remove: (() -> Void)?) -> some View {
        Button("Copy Hex") {
            let alpha = color.srgb.alphaComponent
            let value = alpha < 0.999
                ? ColorFormatter.hexStringWithAlpha(color, uppercase: hexUppercase, prefix: hexPrefix)
                : ColorFormatter.hexString(color, uppercase: hexUppercase, prefix: hexPrefix)
            ClipboardManager.copy(value)
            statusText = "\(name): \(value) copied"
        }
        Button("Copy RGB") {
            let alpha = color.srgb.alphaComponent
            let value = alpha < 0.999 ? ColorFormatter.rgbaString(color) : ColorFormatter.rgbString(color)
            ClipboardManager.copy(value)
            statusText = "\(name): \(value) copied"
        }
        Button("Copy HSL") {
            let alpha = color.srgb.alphaComponent
            let value = alpha < 0.999 ? ColorFormatter.hslaString(color) : ColorFormatter.hslString(color)
            ClipboardManager.copy(value)
            statusText = "\(name): \(value) copied"
        }
        if allowRemove, let remove {
            Divider()
            Button("Remove") {
                remove()
            }
        }
    }
}
