import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

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
    @State private var hexInput: String = ""
    @State private var rgbInput: String = ""
    @State private var hslInput: String = ""
    @State private var lchInput: String = ""
    @State private var isUpdatingFormatFields = false
    @State private var hexInputInvalid = false
    @State private var rgbInputInvalid = false
    @State private var hslInputInvalid = false
    @State private var lchInputInvalid = false

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
                    colorPreview
                    Divider()
                    colorFormatTextFields
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
                    syncFormatFields(from: color)
                    colorPicker.pickedColor = nil
                }
                .onChange(of: colorPicker.lastError) { _, error in
                    if let error {
                        statusText = error
                    }
                }
                .onAppear {
                    syncFormatFields(from: selectedColor)
                }
                .onChange(of: selectedColor) { _, color in
                    syncFormatFields(from: color)
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
        let swatches: [(name: String, color: NSColor)] = ColorListData.standard.compactMap { entry in
            guard let color = NSColor(hex: entry.hex) else { return nil }
            return (name: entry.name, color: color)
        }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Palette")
                .font(.caption)
                .foregroundStyle(.secondary)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(swatches, id: \.name) { swatch in
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
                    }, selectedColor: $selectedColor
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
                    }, selectedColor: $selectedColor
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
                    }, selectedColor: $selectedColor
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
    
    private var colorPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Color Preview")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            CurrentColorPreviewView(
                color: currentColor(),
                onCopy: { color in
                    ClipboardManager.copy(ColorFormatter.hexString(color, uppercase: true, prefix: true))
                },
                onAdd: { color in
                    onAdd(color)
                }
            )
        }
    }
    
    private var colorFormatTextFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Color Formats")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                formatRow(label: "hex:", text: $hexInput, copyValue: hexValue, isInvalid: hexInputInvalid) {
                    applyHexInput()
                }
                formatRow(label: "rgb:", text: $rgbInput, copyValue: rgbValue, isInvalid: rgbInputInvalid) {
                    applyRGBInput()
                }
                formatRow(label: "hsl:", text: $hslInput, copyValue: hslValue, isInvalid: hslInputInvalid) {
                    applyHSLInput()
                }
                formatRow(label: "lch:", text: $lchInput, copyValue: lchValue, isInvalid: lchInputInvalid) {
                    applyLCHInput()
                }
            }

            if let message = formatValidationMessage {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }

    private func formatRow(label: String, text: Binding<String>, copyValue: String, isInvalid: Bool, onSubmit: @escaping () -> Void) -> some View {
        HStack {
            TextField(label, text: text)
                .textFieldStyle(.roundedBorder)
                .textSelection(.enabled)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isInvalid ? Color.red : Color.clear, lineWidth: 1)
                )
                .onSubmit(onSubmit)
            Button(action: {
                ClipboardManager.copy(copyValue)
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
            }
            .disabled(copyValue.isEmpty)
        }
    }

    private var formatValidationMessage: String? {
        if hexInputInvalid { return "Ungueltiges HEX-Format" }
        if rgbInputInvalid { return "Ungueltiges RGB-Format" }
        if hslInputInvalid { return "Ungueltiges HSL-Format" }
        if lchInputInvalid { return "Ungueltiges LCH-Format" }
        return nil
    }
    
    private var customColors: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Custom Colors")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Save") {
                    exportCustomColors()
                }
                .buttonStyle(.link)
                .font(.caption)

                Button("Load") {
                    importCustomColors()
                }
                .buttonStyle(.link)
                .font(.caption)
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
        syncFormatFields(from: color)
    }

    private func syncFormatFields(from color: NSColor?) {
        guard !isUpdatingFormatFields else { return }
        isUpdatingFormatFields = true
        defer { isUpdatingFormatFields = false }
        guard let color else {
            hexInput = ""
            rgbInput = ""
            hslInput = ""
            lchInput = ""
            hexInputInvalid = false
            rgbInputInvalid = false
            hslInputInvalid = false
            lchInputInvalid = false
            return
        }
        hexInput = formattedHex(for: color)
        rgbInput = formattedRGB(for: color)
        hslInput = formattedHSL(for: color)
        lchInput = formattedLCH(for: color)
        hexInputInvalid = false
        rgbInputInvalid = false
        hslInputInvalid = false
        lchInputInvalid = false
    }

    private func applyHexInput() {
        guard !isUpdatingFormatFields else { return }

        let normalized = hexInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = normalized.hasPrefix("#") ? String(normalized.dropFirst()) : normalized
        let validLength = candidate.count == 3 || candidate.count == 4 || candidate.count == 6 || candidate.count == 8
        let validChars = candidate.range(of: "^[0-9A-Fa-f]+$", options: .regularExpression) != nil

        guard validLength, validChars, let color = NSColor(hex: normalized) else {
            hexInputInvalid = true
            return
        }

        hexInputInvalid = false
        selectedColor = color
        syncFormatFields(from: color)
    }

    private func applyRGBInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseRGB(rgbInput) else {
            rgbInputInvalid = true
            return
        }
        rgbInputInvalid = false
        selectedColor = color
        syncFormatFields(from: color)
    }

    private func applyHSLInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseHSL(hslInput) else {
            hslInputInvalid = true
            return
        }
        hslInputInvalid = false
        selectedColor = color
        syncFormatFields(from: color)
    }

    private func applyLCHInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseLCH(lchInput) else {
            lchInputInvalid = true
            return
        }
        lchInputInvalid = false
        selectedColor = color
        syncFormatFields(from: color)
    }

    private func formattedHex(for color: NSColor) -> String {
        let alpha = color.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.hexStringWithAlpha(color, uppercase: hexUppercase, prefix: hexPrefix)
        }
        return ColorFormatter.hexString(color, uppercase: hexUppercase, prefix: hexPrefix)
    }

    private func formattedRGB(for color: NSColor) -> String {
        let alpha = color.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.rgbaString(color)
        }
        return ColorFormatter.rgbString(color)
    }

    private func formattedHSL(for color: NSColor) -> String {
        let alpha = color.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.hslaString(color)
        }
        return ColorFormatter.hslString(color)
    }

    private func formattedLCH(for color: NSColor) -> String {
        ColorFormatter.lchString(color)
    }

    private func parseRGB(_ text: String) -> NSColor? {
        let values = extractNumbers(from: text)
        if values.count == 3 {
            return NSColor(
                red: clamp01(values[0] / 255.0),
                green: clamp01(values[1] / 255.0),
                blue: clamp01(values[2] / 255.0),
                alpha: 1.0
            )
        }
        if values.count == 4 {
            return NSColor(
                red: clamp01(values[0] / 255.0),
                green: clamp01(values[1] / 255.0),
                blue: clamp01(values[2] / 255.0),
                alpha: clamp01(values[3])
            )
        }
        return nil
    }

    private func parseHSL(_ text: String) -> NSColor? {
        let values = extractNumbers(from: text)
        guard values.count == 3 || values.count == 4 else { return nil }
        let h = values[0].truncatingRemainder(dividingBy: 360.0)
        let s = clamp01(values[1] / 100.0)
        let l = clamp01(values[2] / 100.0)
        let alpha = values.count == 4 ? clamp01(values[3]) : 1.0

        let c = (1.0 - abs(2.0 * l - 1.0)) * s
        let x = c * (1.0 - abs((h / 60.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = l - c / 2.0

        let tuple: (CGFloat, CGFloat, CGFloat)
        switch h {
        case 0..<60: tuple = (c, x, 0)
        case 60..<120: tuple = (x, c, 0)
        case 120..<180: tuple = (0, c, x)
        case 180..<240: tuple = (0, x, c)
        case 240..<300: tuple = (x, 0, c)
        default: tuple = (c, 0, x)
        }

        return NSColor(
            red: clamp01(tuple.0 + m),
            green: clamp01(tuple.1 + m),
            blue: clamp01(tuple.2 + m),
            alpha: alpha
        )
    }

    private func parseLCH(_ text: String) -> NSColor? {
        let values = extractNumbers(from: text)
        guard values.count == 3 else { return nil }

        let l = values[0]
        let c = values[1]
        let hDeg = values[2]
        let hRad = hDeg * .pi / 180.0
        let a = c * cos(hRad)
        let b = c * sin(hRad)

        return ColorFormatter.labToSRGBColor(l: l, a: a, b: b)
    }

    private func extractNumbers(from text: String) -> [CGFloat] {
        let cleaned = text
            .lowercased()
            .replacingOccurrences(of: "rgba", with: "")
            .replacingOccurrences(of: "rgb", with: "")
            .replacingOccurrences(of: "hsla", with: "")
            .replacingOccurrences(of: "hsl", with: "")
            .replacingOccurrences(of: "lch", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "%", with: "")
        return cleaned
            .split(separator: ",")
            .compactMap { CGFloat(Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) ?? .nan) }
            .filter { !$0.isNaN }
    }

    private func clamp01(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.0), 1.0)
    }

    private func currentColor() -> NSColor {
        selectedColor ?? .white
    }

    private func onAdd(_ color: NSColor) {
        paletteStore.add(color: color)
    }

    private func exportCustomColors() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "MenuBarColorPicker-custom-colors.json"
        let response = panel.runModal()
        guard response == .OK, let url = panel.url else { return }
        if paletteStore.exportToJSON(url: url) {
            statusText = "Custom colors saved"
        } else {
            statusText = "Failed to save custom colors"
        }
    }

    private func importCustomColors() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        let response = panel.runModal()
        guard response == .OK, let url = panel.url else { return }
        if paletteStore.importFromJSON(url: url) {
            statusText = "Custom colors loaded"
        } else {
            statusText = "Failed to load custom colors"
        }
    }

    private var hexValue: String {
        guard let color = selectedColor else { return "" }
        return formattedHex(for: color)
    }

    private var rgbValue: String {
        guard let color = selectedColor else { return "" }
        return formattedRGB(for: color)
    }

    private var hslValue: String {
        guard let color = selectedColor else { return "" }
        return formattedHSL(for: color)
    }

    private var lchValue: String {
        guard let color = selectedColor else { return "" }
        return formattedLCH(for: color)
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
