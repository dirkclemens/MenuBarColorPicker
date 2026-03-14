import SwiftUI
import Combine

@MainActor
final class PaletteStore: ObservableObject {
    private let storageKey = "customColors"
    let maxSlots = 20

    @Published private(set) var customColors: [StoredColor] = []

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

}
