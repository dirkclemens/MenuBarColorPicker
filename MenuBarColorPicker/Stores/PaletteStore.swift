import SwiftUI
import Combine

@MainActor
final class PaletteStore: ObservableObject {
    private let storageKey = "customColors"
    let maxSlots = 30

    @Published private(set) var customColors: [StoredColor] = []

    // Default export/import file on Desktop
    private var desktopJSONURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("MenuBarColorPicker-custom-colors.json")
    }
    
    init() {
        load()
    }

    func add(color: NSColor) {
        var updated = customColors
        if updated.count >= maxSlots {
            updated.removeFirst()
        }
        updated.append(StoredColor(color: color))
        customColors = updated
        persist()
    }

    func remove(id: UUID) {
        customColors.removeAll { $0.id == id }
        persist()
    }

    func clear() {
        customColors = []
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        guard let decoded = try? JSONDecoder().decode([StoredColor].self, from: data) else { return }
        customColors = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(customColors) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    @discardableResult
    func exportToJSON(url: URL) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(customColors) else { return false }

        do {
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            NSLog("Failed to export colors to JSON: \(error.localizedDescription)")
            return false
        }
    }

    @discardableResult
    func importFromJSON(url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([StoredColor].self, from: data)
            customColors = Array(decoded.suffix(maxSlots))
            persist()
            return true
        } catch {
            NSLog("Failed to import colors from JSON: \(error.localizedDescription)")
            return false
        }
    }

}
