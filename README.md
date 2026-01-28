# Afterglow <img src="docs/images/icon.png" width="28" height="28" align="top" />

> A macOS menu bar app that gives you more control over Night Shift.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)

---

Afterglow was built to expand the capabilities of Night Shift on macOS. It puts fine-grained control right in your menu bar — disable Night Shift for specific apps, websites, or custom time periods with a single click.

<!-- screenshot placeholder: replace with actual screenshot -->
<!-- ![Afterglow Screenshot](docs/images/screenshot.png) -->

## Features

- **Per-App Control** — Automatically disable Night Shift when a specific app is frontmost or running
- **Per-Website Control** — Turn off Night Shift for individual domains or subdomains (Safari, Chrome, Arc, Edge, Brave, Vivaldi, Opera, and more)
- **Color Temperature Slider** — Fine-tune the warmth of your display directly from the menu bar
- **Custom Schedules** — Set your own start and end times beyond the built-in Sunset to Sunrise option
- **Timed Disable** — Quickly disable Night Shift for one hour or a custom duration
- **True Tone Control** — Toggle True Tone from the same menu (on supported hardware)
- **Dark Mode Sync** — Automatically match Dark Mode to your Night Shift schedule
- **Global Keyboard Shortcuts** — Assign hotkeys for any Afterglow action
- **Launch at Login** — Start automatically when you log in via native `SMAppService`

## Requirements

- macOS 13.0 (Ventura) or later
- A Mac that supports Night Shift ([check compatibility](https://support.apple.com/en-us/102191))

## Install

### Download

Download the latest release from the [Releases](https://github.com/waqarqadir/Afterglow/releases) page.

1. Open the `.dmg` file
2. Drag **Afterglow** to your Applications folder
3. Launch Afterglow — it will appear in your menu bar

### Build from Source

```bash
git clone https://github.com/waqarqadir/Afterglow.git
cd Afterglow
open Afterglow.xcodeproj
```

Build and run with **Cmd+R** in Xcode 15+.

## How It Works

Afterglow uses Apple's private `CoreBrightness` framework to control Night Shift and True Tone at a system level — the same APIs that System Settings uses. This allows per-app and per-website overrides that aren't possible through the standard UI.

Browser URL detection uses ScriptingBridge to read the active tab from supported browsers. This requires granting Afterglow permission to automate your browser when prompted.

## Supported Browsers

| Browser | Supported |
|---------|-----------|
| Safari | Yes |
| Google Chrome | Yes |
| Arc | Yes |
| Microsoft Edge | Yes |
| Brave | Yes |
| Vivaldi | Yes |
| Opera | Yes |
| Chromium | Yes |

## Architecture

Afterglow is built with SwiftUI and targets macOS 13+. The app uses `MenuBarExtra` for the status item, native `Settings` scene for preferences, and has zero third-party dependencies.

```
Afterglow/
├── App/          → Entry point, app state
├── Core/         → Night Shift, True Tone, rules, browser, shortcuts
├── Views/        → Menu bar UI, settings tabs
├── Models/       → Data types (rules, schedules, timers)
├── PrivateAPI/   → CoreBrightness ObjC headers
├── Extensions/   → Notification names
└── Resources/    → Assets, Info.plist, entitlements
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

## License

[GPL-3.0](LICENSE)
