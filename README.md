# MenuBarColorPicker

A macOS SwiftUI `MenuBarExtra` app that offers a curated color palette plus custom colors and can copy colors to the clipboard in multiple formats.

---

## Screenshot

![screenshot](./screenshot.png)

---

## Features
- Fancy color palette in the menu bar window
- Copy in `Hex`, `RGB(A)`, `HSL(A)`, `HSB`, `CMYK`, `LAB`, `LCH`
- Configurable hex format: `#` on/off, `uppercase/lowercase`
- Dock icon on/off
- Launch at login
- Color picker with round loupe and on-screen color selection
- Persistent list of custom colors (30 slots)
- Additional color lists: Developer, Web Safe, CSS Named Colors, RAL Classic (approximated)
- Editable format fields (input in all formats supported)
- Per-format on/off switches for performance optimization

## Requirements
- macOS 14+ (Screen Recording permission is required for the color picker)
- Xcode 15+ (SwiftUI, MenuBarExtra)

## Build & Run
1. Open the project in Xcode (`MenuBarColorPicker.xcodeproj`)
2. Build & Run

## Usage
- Click a swatch: selects the color.
- Under `Color Formats`, view values and copy to the clipboard via the copy button.
- Switch palette views via the icon toggles (Swatches, Color Wheel, Spectrum, Slider, Color List).
- Start the color picker: choose a color, which is added to custom colors and copied to the clipboard.
- Open settings via `Settings`.

## Settings
- `Hex uppercase`: Uppercase or lowercase.
- `Hex with # prefix`: Adds a `#` prefix.
- `Color Formats`: Show/hide per format (HEX, RGB, HSL, HSB, CMYK, LAB, LCH).
- `Show Dock icon`: Dock icon on/off.
- `Launch at login`: Autostart at login.

## Color Picker Note
The color picker uses Screen Recording to read the screen. macOS may require permission for this. In some setups, Input Monitoring is also required for global clicks.

## Persistence
Custom colors are stored as JSON in `UserDefaults`. The UI shows fixed placeholders when fewer than 30 colors exist.

## TODO
- [x] Set up MenuBarExtra app structure with Settings Scene
- [x] Fancy palette UI with format selection and clipboard copy
- [x] Configure and apply hex options (prefix/uppercase)
- [x] Dock icon toggle
- [x] Autostart toggle (Login Item)
- [x] Implement color picker with round loupe and on-screen color selection
- [x] Persistent list of custom colors including placeholders
- [x] Expand documentation with functional details
