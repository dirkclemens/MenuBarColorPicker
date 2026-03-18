import SwiftUI

struct ColorWheelView: View {
    var onSelect: (NSColor) -> Void
    var onAdd: (NSColor) -> Void

    @State private var hue: Double = 0.55
    @State private var saturation: Double = 0.7
    @State private var brightness: Double = 1.0
    @State private var opacity: Double = 0.5

    private let wheelSize: CGFloat = 190
    private let sliderHeight: CGFloat = 16
    private let cornerRadius: CGFloat = 10
    
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
                    colorWheelSurface
                    hueSlider
                    alphaSlider
                }
                .padding(10)
            }
            .frame(width: wheelSize + 20, height: wheelSize + 70)

            HStack(spacing: 8) {
                SwatchView(color: currentColor(), title: "Current Color") {
                    let color = currentColor()
                    ClipboardManager.copy(ColorFormatter.hexString(color, uppercase: true, prefix: true))
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

    private var colorWheelSurface: some View {
        ZStack {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2

                let segments = 360
                for i in 0..<segments {
                    let angle = Double(i) / Double(segments) * 2.0 * .pi
                    let start = angle
                    let end = angle + (2.0 * .pi / Double(segments))

                    var path = Path()
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
                    path.closeSubpath()

                    let hue = Double(i) / Double(segments)
                    let color = Color(hue: hue, saturation: 1.0, brightness: 1.0)
                    context.fill(path, with: .color(color))
                }

                let inner = Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
                context.clip(to: inner)

                let gradient = Gradient(colors: [Color.white, Color.clear])
                context.fill(inner, with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius))

                context.stroke(inner, with: .color(Color.black.opacity(0.08)), lineWidth: 1)
            }

            wheelMarker
        }
        .frame(width: wheelSize, height: wheelSize)
        .drawingGroup()
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateColor(from: value.location)
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
        .frame(width: wheelSize, height: sliderHeight)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    hue = sliderValue(from: value.location.x, width: wheelSize)
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
            sliderThumb(x: opacity)
        }
        .frame(width: wheelSize, height: sliderHeight)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    opacity = sliderValue(from: value.location.x, width: wheelSize)
                }
                .onEnded { _ in
                    onSelect(currentColor())
                }
        )
    }
    
    private var wheelMarker: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = min(proxy.size.width, proxy.size.height) / 2
            let angle = hue * 2.0 * .pi
            let r = saturation * radius
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r

            Circle()
                .stroke(Color.black.opacity(0.35), lineWidth: 1)
                .background(
                    ZStack {
                        Circle().fill(currentSwiftUIColor())
                            .frame(width: 8, height: 8)
                    }
                )
                .frame(width: 18, height: 18)
                .position(x: x, y: y)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }
    
    private func updateColor(from location: CGPoint) {
        let center = CGPoint(x: wheelSize / 2, y: wheelSize / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let radius = sqrt(dx * dx + dy * dy)
        let maxRadius = wheelSize / 2
        let clampedRadius = min(radius, maxRadius)

        var angle = atan2(dy, dx)
        if angle < 0 { angle += 2 * .pi }

        hue = Double(angle / (2 * .pi))
        saturation = Double(clampedRadius / maxRadius)
        brightness = 1.0
    }

    private func sliderThumb(x: Double) -> some View {
        let thumbSize: CGFloat = 16
        let track = wheelSize - thumbSize
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
        NSColor(calibratedHue: hue, saturation: saturation, brightness: brightness, alpha: opacity)
    }
    
    private func currentSwiftUIColor() -> Color {
        Color(nsColor: currentColor())
    }

}
