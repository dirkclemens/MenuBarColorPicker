//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuBarContentView()
            .environmentObject(PaletteStore())
            .environmentObject(ColorPickerManager())
            .environmentObject(LoginItemManager())
    }
}
