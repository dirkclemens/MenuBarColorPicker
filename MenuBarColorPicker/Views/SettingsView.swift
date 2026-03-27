import SwiftUI

struct SettingsView: View {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clipboard Format")
                .font(.headline)
            Toggle("Hex uppercase", isOn: $hexUppercase)
            Toggle("Hex with # prefix", isOn: $hexPrefix)

            Divider()

            Text("Color Formats")
                .font(.headline)
            Toggle("HEX", isOn: $showFormatHex)
            Toggle("RGB", isOn: $showFormatRGB)
            Toggle("HSL", isOn: $showFormatHSL)
            Toggle("HSB", isOn: $showFormatHSB)
            Toggle("CMYK", isOn: $showFormatCMYK)
            Toggle("LAB", isOn: $showFormatLAB)
            Toggle("LCH", isOn: $showFormatLCH)
            
            Divider()
            
            Text("App")
                .font(.headline)
            Toggle("Show Dock icon", isOn: $showDockIcon)
                .onChange(of: showDockIcon) { _, value in
                    DockIconManager.apply(showDockIcon: value)
                }
            Toggle("Launch at login", isOn: Binding(
                get: { loginItemManager.isEnabled },
                set: { loginItemManager.setEnabled($0) }
            ))
            if let error = loginItemManager.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .onAppear {
            DockIconManager.apply(showDockIcon: showDockIcon)
        }
    }
}
