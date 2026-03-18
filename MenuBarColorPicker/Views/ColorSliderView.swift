import SwiftUI

struct ColorSliderView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case rgb
        case hsb
        case gray

        var id: String { rawValue }

        var label: String {
            switch self {
            case .rgb: return "RGB"
            case .hsb: return "HSB"
            case .gray: return "Gray"
            }
        }
    }

    var onSelect: (NSColor) -> Void
    var onAdd: (NSColor) -> Void
    @Binding var selectedColor: NSColor?
    
    @State private var mode: Mode = .rgb

    @State private var r: Double = 1.0
    @State private var g: Double = 0.0
    @State private var b: Double = 0.0

    @State private var h: Double = 0.0
    @State private var s: Double = 1.0
    @State private var br: Double = 1.0

    @State private var gray: Double = 0.5
    @State private var opacity: Double = 1.0

    private let squareSize: CGFloat = 160
    private let sliderHeight: CGFloat = 16
    private let cornerRadius: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                    )
                VStack(spacing: 10) {
                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch mode {
                    case .rgb:
                        rgbSliders
                    case .hsb:
                        hsbSliders
                    case .gray:
                        graySliders
                    }
                    opacitySlider
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            syncFromSelectedColor()
        }
        .onChange(of: selectedColor) { _, _ in
            syncFromSelectedColor()
        }
    }

    private func syncFromSelectedColor() {
        guard let color = selectedColor?.usingColorSpace(.deviceRGB) else { return }

        var rr: CGFloat = 0
        var gg: CGFloat = 0
        var bb: CGFloat = 0
        var aa: CGFloat = 0
        color.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)

        r = Double(rr)
        g = Double(gg)
        b = Double(bb)
        opacity = Double(aa)

        var hh: CGFloat = 0
        var ss: CGFloat = 0
        var brr: CGFloat = 0
        color.getHue(&hh, saturation: &ss, brightness: &brr, alpha: nil)
        h = Double(hh)
        s = Double(ss)
        br = Double(brr)

        gray = Double((rr + gg + bb) / 3.0)
    }

    private var rgbSliders: some View {
        VStack(spacing: 6) {
            gradientSliderRow(label: "R", value: $r, gradient: Gradient(colors: [Color(red: 0, green: g, blue: b), Color(red: 1, green: g, blue: b)]))
            gradientSliderRow(label: "G", value: $g, gradient: Gradient(colors: [Color(red: r, green: 0, blue: b), Color(red: r, green: 1, blue: b)]))
            gradientSliderRow(label: "B", value: $b, gradient: Gradient(colors: [Color(red: r, green: g, blue: 0), Color(red: r, green: g, blue: 1)]))
        }
        .onChange(of: r) { _, _ in onSelect(currentColor()) }
        .onChange(of: g) { _, _ in onSelect(currentColor()) }
        .onChange(of: b) { _, _ in onSelect(currentColor()) }
    }

    private var hsbSliders: some View {
        VStack(spacing: 6) {
            gradientSliderRow(label: "H", value: $h, gradient: Gradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .pink, .red]))
            gradientSliderRow(label: "S", value: $s, gradient: Gradient(colors: [
                Color(hue: h, saturation: 0, brightness: br),
                Color(hue: h, saturation: 1, brightness: br)
            ]))
            gradientSliderRow(label: "B", value: $br, gradient: Gradient(colors: [
                Color(hue: h, saturation: s, brightness: 0),
                Color(hue: h, saturation: s, brightness: 1)
            ]))
        }
        .onChange(of: h) { _, _ in onSelect(currentColor()) }
        .onChange(of: s) { _, _ in onSelect(currentColor()) }
        .onChange(of: br) { _, _ in onSelect(currentColor()) }
    }

    private var graySliders: some View {
        VStack(spacing: 6) {
            gradientSliderRow(label: "G", value: $gray, gradient: Gradient(colors: [.black, .white]))
        }
        .onChange(of: gray) { _, _ in onSelect(currentColor()) }
    }

    private var opacitySlider: some View {
        gradientSliderRow(label: "A", value: $opacity, gradient: Gradient(colors: [
            currentSwiftUIColor().opacity(0.0),
            currentSwiftUIColor().opacity(1.0)
        ]))
            .onChange(of: opacity) { _, _ in onSelect(currentColor()) }
    }

    private func sliderRow(label: String, value: Binding<Double>, tint: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .frame(width: 18, alignment: .leading)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: sliderHeight / 2, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
                sliderThumb(x: value.wrappedValue)
            }
            .frame(width: squareSize, height: sliderHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value.wrappedValue = sliderValue(from: gesture.location.x, width: squareSize)
                    }
            )
        }
    }

    private func gradientSliderRow(label: String, value: Binding<Double>, gradient: Gradient) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .frame(width: 18, alignment: .leading)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: sliderHeight / 2, style: .continuous)
                    .fill(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing))
                sliderThumb(x: value.wrappedValue)
            }
            .frame(width: squareSize, height: sliderHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value.wrappedValue = sliderValue(from: gesture.location.x, width: squareSize)
                    }
            )
        }
    }

    private func sliderThumb(x: Double) -> some View {
        let thumbSize: CGFloat = 16
        let track = squareSize - thumbSize
        return Circle()
            .stroke(Color.white, lineWidth: 2)
            .background(Circle().fill(currentSwiftUIColor()))
            .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
            .frame(width: thumbSize, height: thumbSize)
            .offset(x: CGFloat(x) * track, y: 0)
    }

    private func sliderValue(from locationX: CGFloat, width: CGFloat) -> Double {
        let thumbSize: CGFloat = 16
        let track = width - thumbSize
        let x = min(max(locationX - thumbSize / 2, 0), track)
        if track <= 0 { return 0 }
        return Double(x / track)
    }

    private func currentSwiftUIColor() -> Color {
        Color(nsColor: currentColor())
    }

    private func currentColor() -> NSColor {
        switch mode {
        case .rgb:
            return NSColor(red: r, green: g, blue: b, alpha: opacity)
        case .hsb:
            return NSColor(calibratedHue: h, saturation: s, brightness: br, alpha: opacity)
        case .gray:
            return NSColor(white: gray, alpha: opacity)
        }
    }
}
