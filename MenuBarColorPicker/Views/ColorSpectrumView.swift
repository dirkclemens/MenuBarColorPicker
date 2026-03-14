import SwiftUI

struct ColorSpectrumView: View {
    var onSelect: (NSColor) -> Void
    var onAdd: (NSColor) -> Void
    
    @State private var hue: Double = 0.55
    @State private var saturation: Double = 0.7
    @State private var brightness: Double = 0.9
    @State private var alpha: Double = 1.0
    
    private let squareSize: CGFloat = 190
    private let sliderHeight: CGFloat = 16
    private let cornerRadius: CGFloat = 10
    
    @State private var cx: Double = 0.0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                    )
                VStack(spacing: 10) {
                    saturationBrightnessSquare
                    hueSlider
                    alphaSlider
                }
                .padding(10)
            }
            .frame(width: squareSize + 20, height: squareSize + 70)
            
            HStack(spacing: 8) {
                SwatchView(color: currentColor(), title: "Current Color") {}
                    .frame(width: 32, height: 32)
                Button() {
                    let color = currentColor()
                    onSelect(color)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption2)
                }
                .frame(width: 32, height: 32)
                Button() {
                    let color = currentColor()
                    onAdd(color)
                } label: {
                    Image(systemName: "plus.circle")
                }
                .frame(width: 32, height: 32)
            }
            .font(.caption)
        }
    }
    
    private var saturationBrightnessSquare: some View {
        ZStack {
            Rectangle()
                .fill(Color(hue: hue, saturation: 1, brightness: 1))
                .overlay(
                    LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing)
                )
                .overlay(
                    LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 2, style: .continuous))
            
            GeometryReader { proxy in
                let x = CGFloat(saturation) * proxy.size.width
                let y = (1.0 - CGFloat(brightness)) * proxy.size.height
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                    .frame(width: 18, height: 18)
                    .position(x: x, y: y)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let clampedX = max(0, min(value.location.x / squareSize, 1))
                    let clampedY = max(0, min(value.location.y / squareSize, 1))
                    saturation = clampedX
                    brightness = 1.0 - clampedY
                    cx = clampedX
                }
                .onEnded { _ in
                    onSelect(currentColor())
                }
        )
    }
    
    private var hueSlider: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: sliderHeight / 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            .red, .yellow, .green, .cyan, .blue, .purple, .pink, .red
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            sliderThumb(x: hue)
        }
        .frame(width: squareSize, height: sliderHeight)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    hue = sliderValue(from: value.location.x, width: squareSize)
                }
                .onEnded { _ in
                    onSelect(currentColor())
                }
        )
    }
    
    private var alphaSlider: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: sliderHeight / 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            currentSwiftUIColor().opacity(0.0),
                            currentSwiftUIColor().opacity(1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            sliderThumb(x: alpha)
        }
        .frame(width: squareSize, height: sliderHeight)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    alpha = sliderValue(from: value.location.x, width: squareSize)
                }
                .onEnded { _ in
                    onSelect(currentColor())
                }
        )
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
    
    private func currentColor() -> NSColor {
        NSColor(calibratedHue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    private func currentSwiftUIColor() -> Color {
        Color(nsColor: currentColor())
    }
    
    private func baseSwiftUIColor() -> Color {
        Color(nsColor: NSColor(calibratedHue: hue, saturation: cx, brightness: 1.0, alpha: 1.0))
    }
}
