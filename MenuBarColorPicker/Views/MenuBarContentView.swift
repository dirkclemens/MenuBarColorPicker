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
    @AppStorage("showFormatHex") private var showFormatHex = true
    @AppStorage("showFormatRGB") private var showFormatRGB = true
    @AppStorage("showFormatHSL") private var showFormatHSL = true
    @AppStorage("showFormatHSB") private var showFormatHSB = true
    @AppStorage("showFormatCMYK") private var showFormatCMYK = true
    @AppStorage("showFormatLAB") private var showFormatLAB = true
    @AppStorage("showFormatLCH") private var showFormatLCH = true
    
    @State private var statusText: String = " "
    @State private var paletteMode: PaletteMode = .spectrum
    @State private var selectedColor: SRGBColor?
    @State private var lastCopiedFormat: String?
    @State private var hexInput: String = ""
    @State private var rgbInput: String = ""
    @State private var hslInput: String = ""
    @State private var hsbInput: String = ""
    @State private var cmykInput: String = ""
    @State private var labInput: String = ""
    @State private var lchInput: String = ""
    @State private var isUpdatingFormatFields = false
    @State private var isSyncScheduled = false
    @State private var hexInputInvalid = false
    @State private var rgbInputInvalid = false
    @State private var hslInputInvalid = false
    @State private var hsbInputInvalid = false
    @State private var cmykInputInvalid = false
    @State private var labInputInvalid = false
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
                .frame(width: 280)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onChange(of: colorPicker.pickedColor) { _, color in
                    guard let color else { return }
                    paletteStore.add(color: color)
                    setSelectedColor(SRGBColor(color))
                    scheduleFormatSync()
                    colorPicker.pickedColor = nil
                }
                .onChange(of: colorPicker.lastError) { _, error in
                    if let error {
                        statusText = error
                    }
                }
                .onAppear {
                    scheduleFormatSync()
                }
                .onChange(of: selectedColor) { _, _ in scheduleFormatSync() }
            }
            
            if page == .settings {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    SettingsView()
                    Divider()
                    footerButtons
                }
                .padding(12)
                .frame(width: 200)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: page)
        .onChange(of: showFormatHex) { _, _ in scheduleFormatSync() }
        .onChange(of: showFormatRGB) { _, _ in scheduleFormatSync() }
        .onChange(of: showFormatHSL) { _, _ in scheduleFormatSync() }
        .onChange(of: showFormatHSB) { _, _ in scheduleFormatSync() }
        .onChange(of: showFormatCMYK) { _, _ in scheduleFormatSync() }
        .onChange(of: showFormatLAB) { _, _ in scheduleFormatSync() }
        .onChange(of: showFormatLCH) { _, _ in scheduleFormatSync() }
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
                        paletteStore.add(color: color.nsColor)
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
                        paletteStore.add(color: color.nsColor)
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
                        paletteStore.add(color: color.nsColor)
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
            
            HStack {
                Button() {
                    colorPicker.toggle()
                } label: {
                    Image(systemName: colorPicker.isActive ? "eyedropper" : "eyedropper.full")
                }
//                .buttonStyle(.plain)
                
                Spacer()
                
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
    }
    
    private var colorFormatTextFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Color Formats")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                if showFormatHex {
                    formatRow(label: "hex:", text: $hexInput, copyValue: hexValue, isInvalid: hexInputInvalid) {
                        applyHexInput()
                    }
                }
                if showFormatRGB {
                    formatRow(label: "rgb:", text: $rgbInput, copyValue: rgbValue, isInvalid: rgbInputInvalid) {
                        applyRGBInput()
                    }
                }
                if showFormatHSL {
                    formatRow(label: "hsl:", text: $hslInput, copyValue: hslValue, isInvalid: hslInputInvalid) {
                        applyHSLInput()
                    }
                }
                if showFormatHSB {
                    formatRow(label: "hsb:", text: $hsbInput, copyValue: hsbValue, isInvalid: hsbInputInvalid) {
                        applyHSBInput()
                    }
                }
                if showFormatCMYK {
                    formatRow(label: "cmyk:", text: $cmykInput, copyValue: cmykValue, isInvalid: cmykInputInvalid) {
                        applyCMYKInput()
                    }
                }
                if showFormatLAB {
                    formatRow(label: "lab:", text: $labInput, copyValue: labValue, isInvalid: labInputInvalid) {
                        applyLABInput()
                    }
                }
                if showFormatLCH {
                    formatRow(label: "lch:", text: $lchInput, copyValue: lchValue, isInvalid: lchInputInvalid) {
                        applyLCHInput()
                    }
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
        if showFormatHex, hexInputInvalid { return "Ungueltiges HEX-Format" }
        if showFormatRGB, rgbInputInvalid { return "Ungueltiges RGB-Format" }
        if showFormatHSL, hslInputInvalid { return "Ungueltiges HSL-Format" }
        if showFormatHSB, hsbInputInvalid { return "Ungueltiges HSB-Format" }
        if showFormatCMYK, cmykInputInvalid { return "Ungueltiges CMYK-Format" }
        if showFormatLAB, labInputInvalid { return "Ungueltiges LAB-Format" }
        if showFormatLCH, lchInputInvalid { return "Ungueltiges LCH-Format" }
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
        setSelectedColor(SRGBColor(color))
        scheduleFormatSync()
    }

    private func selectColor(_ color: SRGBColor) {
        setSelectedColor(color)
        scheduleFormatSync()
    }

    private func setSelectedColor(_ color: SRGBColor?) {
        selectedColor = color?.clamped()
    }

    private func scheduleFormatSync() {
        guard !isSyncScheduled else { return }
        isSyncScheduled = true
        DispatchQueue.main.async {
            isSyncScheduled = false
            syncFormatFields(from: selectedColor)
        }
    }

    private func syncFormatFields(from color: SRGBColor?) {
        guard !isUpdatingFormatFields else { return }
        isUpdatingFormatFields = true
        defer { isUpdatingFormatFields = false }
        guard let color else {
            if showFormatHex { hexInput = ""; hexInputInvalid = false }
            if showFormatRGB { rgbInput = ""; rgbInputInvalid = false }
            if showFormatHSL { hslInput = ""; hslInputInvalid = false }
            if showFormatHSB { hsbInput = ""; hsbInputInvalid = false }
            if showFormatCMYK { cmykInput = ""; cmykInputInvalid = false }
            if showFormatLAB { labInput = ""; labInputInvalid = false }
            if showFormatLCH { lchInput = ""; lchInputInvalid = false }
            return
        }
        if showFormatHex { hexInput = formattedHex(for: color); hexInputInvalid = false } else { hexInput = "" }
        if showFormatRGB { rgbInput = formattedRGB(for: color); rgbInputInvalid = false } else { rgbInput = "" }
        if showFormatHSL { hslInput = formattedHSL(for: color); hslInputInvalid = false } else { hslInput = "" }
        if showFormatHSB { hsbInput = formattedHSB(for: color); hsbInputInvalid = false } else { hsbInput = "" }
        if showFormatCMYK { cmykInput = formattedCMYK(for: color); cmykInputInvalid = false } else { cmykInput = "" }
        if showFormatLAB { labInput = formattedLAB(for: color); labInputInvalid = false } else { labInput = "" }
        if showFormatLCH { lchInput = formattedLCH(for: color); lchInputInvalid = false } else { lchInput = "" }
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
        setSelectedColor(SRGBColor(color))
        syncFormatFields(from: selectedColor)
    }

    private func applyRGBInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseRGB(rgbInput) else {
            rgbInputInvalid = true
            return
        }
        rgbInputInvalid = false
        setSelectedColor(color)
        syncFormatFields(from: selectedColor)
    }

    private func applyHSLInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseHSL(hslInput) else {
            hslInputInvalid = true
            return
        }
        hslInputInvalid = false
        setSelectedColor(color)
        syncFormatFields(from: selectedColor)
    }

    private func applyLCHInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseLCH(lchInput) else {
            lchInputInvalid = true
            return
        }
        lchInputInvalid = false
        setSelectedColor(color)
        syncFormatFields(from: selectedColor)
    }

    private func applyHSBInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseHSB(hsbInput) else {
            hsbInputInvalid = true
            return
        }
        hsbInputInvalid = false
        setSelectedColor(color)
        syncFormatFields(from: selectedColor)
    }

    private func applyCMYKInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseCMYK(cmykInput) else {
            cmykInputInvalid = true
            return
        }
        cmykInputInvalid = false
        setSelectedColor(color)
        syncFormatFields(from: selectedColor)
    }

    private func applyLABInput() {
        guard !isUpdatingFormatFields else { return }
        guard let color = parseLAB(labInput) else {
            labInputInvalid = true
            return
        }
        labInputInvalid = false
        setSelectedColor(color)
        syncFormatFields(from: selectedColor)
    }

    private func formattedHex(for color: SRGBColor) -> String {
        let nsColor = color.nsColor
        let alpha = nsColor.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.hexStringWithAlpha(nsColor, uppercase: hexUppercase, prefix: hexPrefix)
        }
        return ColorFormatter.hexString(nsColor, uppercase: hexUppercase, prefix: hexPrefix)
    }

    private func formattedRGB(for color: SRGBColor) -> String {
        let nsColor = color.nsColor
        let alpha = nsColor.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.rgbaString(nsColor)
        }
        return ColorFormatter.rgbString(nsColor)
    }

    private func formattedHSL(for color: SRGBColor) -> String {
        let nsColor = color.nsColor
        let alpha = nsColor.srgb.alphaComponent
        if alpha < 0.999 {
            return ColorFormatter.hslaString(nsColor)
        }
        return ColorFormatter.hslString(nsColor)
    }

    private func formattedHSB(for color: SRGBColor) -> String {
        let c = color.nsColor.srgb
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        c.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let hDeg = Int((h * 360.0).rounded())
        let sPct = Int((s * 100.0).rounded())
        let bPct = Int((b * 100.0).rounded())
        return "hsb(\(hDeg), \(sPct)%, \(bPct)%)"
    }

    private func formattedCMYK(for color: SRGBColor) -> String {
        let c = color.nsColor.srgb
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        let k = 1.0 - max(r, max(g, b))
        let denom = max(1.0 - k, 0.0001)
        let cVal = (1.0 - r - k) / denom
        let mVal = (1.0 - g - k) / denom
        let yVal = (1.0 - b - k) / denom
        let cPct = Int((clamp01(cVal) * 100.0).rounded())
        let mPct = Int((clamp01(mVal) * 100.0).rounded())
        let yPct = Int((clamp01(yVal) * 100.0).rounded())
        let kPct = Int((clamp01(k) * 100.0).rounded())
        return "cmyk(\(cPct)%, \(mPct)%, \(yPct)%, \(kPct)%)"
    }

    private func formattedLAB(for color: SRGBColor) -> String {
        ColorFormatter.labString(color.nsColor)
    }

    private func formattedLCH(for color: SRGBColor) -> String {
        ColorFormatter.lchString(color.nsColor)
    }

    private func parseRGB(_ text: String) -> SRGBColor? {
        let values = extractNumbers(from: text)
        if values.count == 3 {
            return SRGBColor(
                r: Double(clamp01(values[0] / 255.0)),
                g: Double(clamp01(values[1] / 255.0)),
                b: Double(clamp01(values[2] / 255.0)),
                a: 1.0
            )
        }
        if values.count == 4 {
            return SRGBColor(
                r: Double(clamp01(values[0] / 255.0)),
                g: Double(clamp01(values[1] / 255.0)),
                b: Double(clamp01(values[2] / 255.0)),
                a: Double(clamp01(values[3]))
            )
        }
        return nil
    }

    private func parseHSL(_ text: String) -> SRGBColor? {
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

        return SRGBColor(
            r: Double(clamp01(tuple.0 + m)),
            g: Double(clamp01(tuple.1 + m)),
            b: Double(clamp01(tuple.2 + m)),
            a: Double(alpha)
        )
    }

    private func parseLCH(_ text: String) -> SRGBColor? {
        let values = extractNumbers(from: text)
        guard values.count == 3 else { return nil }

        let l = values[0]
        let c = values[1]
        let hDeg = values[2]
        let hRad = hDeg * .pi / 180.0
        let a = c * cos(hRad)
        let b = c * sin(hRad)

        guard let base = ColorFormatter.labToSRGBColor(l: l, a: a, b: b) else { return nil }
        return SRGBColor(base)
    }

    private func parseHSB(_ text: String) -> SRGBColor? {
        let values = extractNumbers(from: text)
        guard values.count == 3 || values.count == 4 else { return nil }
        var h = values[0]
        var s = values[1]
        var br = values[2]
        let alpha = values.count == 4 ? values[3] : 1.0

        if h <= 1.0, s <= 1.0, br <= 1.0 {
            h = h * 360.0
        }
        if s > 1.0 { s = s / 100.0 }
        if br > 1.0 { br = br / 100.0 }

        let hue = clamp01(h / 360.0)
        let sat = clamp01(s)
        let bri = clamp01(br)
        let a = clamp01(alpha > 1.0 ? alpha / 100.0 : alpha)

        return SRGBColor.fromHSB(
            h: Double(hue),
            s: Double(sat),
            b: Double(bri),
            alpha: Double(a)
        )
    }

    private func parseCMYK(_ text: String) -> SRGBColor? {
        let values = extractNumbers(from: text)
        guard values.count == 4 || values.count == 5 else { return nil }
        var c = values[0]
        var m = values[1]
        var y = values[2]
        var k = values[3]
        let alpha = values.count == 5 ? values[4] : 1.0

        if c > 1.0 { c = c / 100.0 }
        if m > 1.0 { m = m / 100.0 }
        if y > 1.0 { y = y / 100.0 }
        if k > 1.0 { k = k / 100.0 }

        let a = clamp01(alpha > 1.0 ? alpha / 100.0 : alpha)

        return SRGBColor.fromCMYK(
            c: Double(clamp01(c)),
            m: Double(clamp01(m)),
            y: Double(clamp01(y)),
            k: Double(clamp01(k)),
            alpha: Double(a)
        )
    }

    private func parseLAB(_ text: String) -> SRGBColor? {
        let values = extractNumbers(from: text)
        guard values.count == 3 || values.count == 4 else { return nil }
        let l = values[0]
        let aVal = values[1]
        let bVal = values[2]
        let alpha = values.count == 4 ? values[3] : 1.0
        guard let base = ColorFormatter.labToSRGBColor(l: l, a: aVal, b: bVal) else { return nil }
        let withAlpha = base.withAlphaComponent(clamp01(alpha > 1.0 ? alpha / 100.0 : alpha))
        return SRGBColor(withAlpha)
    }

    private func extractNumbers(from text: String) -> [CGFloat] {
        let cleaned = text
            .lowercased()
            .replacingOccurrences(of: "rgba", with: "")
            .replacingOccurrences(of: "rgb", with: "")
            .replacingOccurrences(of: "hsla", with: "")
            .replacingOccurrences(of: "hsl", with: "")
            .replacingOccurrences(of: "hsba", with: "")
            .replacingOccurrences(of: "hsb", with: "")
            .replacingOccurrences(of: "cmyk", with: "")
            .replacingOccurrences(of: "laba", with: "")
            .replacingOccurrences(of: "lab", with: "")
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
        selectedColor?.nsColor ?? .white
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
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.json]
            panel.canChooseFiles = true
            panel.canChooseDirectories = false // nur Dateien auswählbar!
            panel.allowsMultipleSelection = false
            let response = panel.runModal()
            guard response == .OK, let url = panel.url else { return }
            if paletteStore.importFromJSON(url: url) {
                statusText = "Custom colors loaded"
            } else {
                statusText = "Failed to load custom colors"
            }
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

    private var hsbValue: String {
        guard let color = selectedColor else { return "" }
        return formattedHSB(for: color)
    }

    private var cmykValue: String {
        guard let color = selectedColor else { return "" }
        return formattedCMYK(for: color)
    }

    private var labValue: String {
        guard let color = selectedColor else { return "" }
        return formattedLAB(for: color)
    }

    private var lchValue: String {
        guard let color = selectedColor else { return "" }
        return formattedLCH(for: color)
    }

    @ViewBuilder
    private func formatContextMenu(for color: NSColor, name: String, allowRemove: Bool, remove: (() -> Void)?) -> some View {
        if showFormatHex {
            Button("Copy Hex") {
                let alpha = color.srgb.alphaComponent
                let value = alpha < 0.999
                    ? ColorFormatter.hexStringWithAlpha(color, uppercase: hexUppercase, prefix: hexPrefix)
                    : ColorFormatter.hexString(color, uppercase: hexUppercase, prefix: hexPrefix)
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if showFormatRGB {
            Button("Copy RGB") {
                let alpha = color.srgb.alphaComponent
                let value = alpha < 0.999 ? ColorFormatter.rgbaString(color) : ColorFormatter.rgbString(color)
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if showFormatHSL {
            Button("Copy HSL") {
                let alpha = color.srgb.alphaComponent
                let value = alpha < 0.999 ? ColorFormatter.hslaString(color) : ColorFormatter.hslString(color)
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if showFormatHSB {
            Button("Copy HSB") {
                let value = formattedHSB(for: SRGBColor(color) ?? SRGBColor(r: 0, g: 0, b: 0))
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if showFormatCMYK {
            Button("Copy CMYK") {
                let value = formattedCMYK(for: SRGBColor(color) ?? SRGBColor(r: 0, g: 0, b: 0))
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if showFormatLAB {
            Button("Copy LAB") {
                let value = formattedLAB(for: SRGBColor(color) ?? SRGBColor(r: 0, g: 0, b: 0))
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if showFormatLCH {
            Button("Copy LCH") {
                let value = formattedLCH(for: SRGBColor(color) ?? SRGBColor(r: 0, g: 0, b: 0))
                ClipboardManager.copy(value)
                statusText = "\(name): \(value) copied"
            }
        }
        if allowRemove, let remove {
            Divider()
            Button("Remove") {
                remove()
            }
        }
    }
}
