import AppKit
import ScreenCaptureKit
import SwiftUI
import Combine

@MainActor
final class ColorPickerManager: ObservableObject {
    @Published private(set) var isActive: Bool = false
    @Published var pickedColor: NSColor?
    @Published var lastError: String?

    private let magnifier = MagnifierWindowController()
    private var timer: Timer?
    private var globalClickMonitor: Any?
    private var localClickMonitor: Any?
    private var lastImage: CGImage?
    private var isCaptureInFlight = false

    private let sampleSize: CGFloat = 28.0
    private let updateInterval: TimeInterval = 1.0 / 30.0

    func toggle() {
        isActive ? stop() : start()
    }

    func start() {
        guard !isActive else { return }
        isActive = true
        lastError = nil
        NSCursor.hide()
        magnifier.show()
        startTracking()
    }

    func stop() {
        guard isActive else { return }
        isActive = false
        stopTracking()
        magnifier.hide()
        NSCursor.unhide()
    }

    private func startTracking() {
        timer = Timer.scheduledTimer(timeInterval: updateInterval,
                                     target: self,
                                     selector: #selector(handleTimerTick(_:)),
                                     userInfo: nil,
                                     repeats: true)

        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] _ in
            Task { @MainActor in
                self?.finishPick(at: NSEvent.mouseLocation)
            }
        }

        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] event in
            Task { @MainActor in
                self?.finishPick(at: NSEvent.mouseLocation)
            }
            return event
        }
    }

    private func stopTracking() {
        timer?.invalidate()
        timer = nil
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
        if let monitor = localClickMonitor {
            NSEvent.removeMonitor(monitor)
            localClickMonitor = nil
        }
        lastImage = nil
    }

    @objc private func handleTimerTick(_ timer: Timer) {
        updateMagnifier()
    }

    private func updateMagnifier() {
        let uiPoint = NSEvent.mouseLocation
        let cgPoint = CGEvent(source: nil)?.location
        let capturePoint = cgPoint.map { NSPoint(x: $0.x, y: $0.y) } ?? uiPoint
        captureImage(at: capturePoint) { [weak self] image in
            guard let self else { return }
            self.lastImage = image
            if let screen = NSScreen.screens.first(where: { $0.frame.contains(uiPoint) }) ?? NSScreen.main {
                self.magnifier.update(image: image, at: uiPoint, in: screen)
            }
            if image == nil {
                self.lastError = "Screen capture failed. Check Screen Recording permission."
            }
        }
    }

    private func finishPick(at point: NSPoint) {
        if let image = lastImage, let color = sampleCenterColor(from: image) {
            pickedColor = color
            stop()
            return
        }

        captureImage(at: point) { [weak self] image in
            guard let self else { return }
            guard let image else {
                self.lastError = "Screen capture failed. Check Screen Recording permission."
                self.stop()
                return
            }
            if let color = self.sampleCenterColor(from: image) {
                self.pickedColor = color
            }
            self.stop()
        }
    }

    private func captureImage(at point: NSPoint, completion: @escaping (CGImage?) -> Void) {
        guard !isCaptureInFlight else { return }
        isCaptureInFlight = true

        let rect = captureRect(for: point)

        SCScreenshotManager.captureImage(in: rect) { [weak self] image, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.isCaptureInFlight = false
                if let error {
                    self.lastError = error.localizedDescription
                }
                completion(image)
            }
        }
    }

    private func captureRect(for point: NSPoint) -> CGRect {
        let size = CGSize(width: sampleSize, height: sampleSize)
        return CGRect(origin: CGPoint(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0), size: size)
    }

    private func sampleCenterColor(from image: CGImage) -> NSColor? {
        let x = image.width / 2
        let y = image.height / 2
        let rect = CGRect(x: x, y: y, width: 1, height: 1)
        guard let cropped = image.cropping(to: rect) else { return nil }

        var pixel = [UInt8](repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &pixel,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        context.interpolationQuality = .none
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        let r = CGFloat(pixel[0]) / 255.0
        let g = CGFloat(pixel[1]) / 255.0
        let b = CGFloat(pixel[2]) / 255.0
        let a = CGFloat(pixel[3]) / 255.0
        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
}

