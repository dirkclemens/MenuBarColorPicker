import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var colorPicker: ColorPickerManager
    @EnvironmentObject private var loginItemManager: LoginItemManager

    @AppStorage("hexUppercase") private var hexUppercase = true
    @AppStorage("hexPrefix") private var hexPrefix = true
    @AppStorage("showDockIcon") private var showDockIcon = false

    var body: some View {
        Form {
            Section("Clipboard Format") {
                Toggle("Hex uppercase", isOn: $hexUppercase)
                Toggle("Hex with # prefix", isOn: $hexPrefix)
            }

            Section("App") {
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

            Section("Color Picker") {
                Text("Uses screen capture to sample the pixel under the magnifier.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let error = colorPicker.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(16)
        .frame(width: 360)
        .onAppear {
            DockIconManager.apply(showDockIcon: showDockIcon)
        }
    }
}
