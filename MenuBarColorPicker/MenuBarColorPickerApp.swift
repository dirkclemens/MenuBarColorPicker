//
//  MenuBarColorPickerApp.swift
//

import SwiftUI
import Combine

@main
struct MenuBarColorPickerApp: App {
    @StateObject private var paletteStore = PaletteStore()
    @StateObject private var colorPicker = ColorPickerManager()
    @StateObject private var loginItemManager = LoginItemManager()
    
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true

    init() {
        let showDockIcon = UserDefaults.standard.bool(forKey: "showDockIcon")
        DockIconManager.apply(showDockIcon: showDockIcon)
    }

    var body: some Scene {
        MenuBarExtra("Color Picker", systemImage: "paintpalette") {//}, isInserted: $showMenuBarExtra) {
            MenuBarContentView()
                .environmentObject(paletteStore)
                .environmentObject(colorPicker)
                .environmentObject(loginItemManager)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(paletteStore)
                .environmentObject(colorPicker)
                .environmentObject(loginItemManager)
        }
    }
}

