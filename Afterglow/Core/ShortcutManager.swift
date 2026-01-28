import Foundation
import Carbon.HIToolbox
import Cocoa

/// Manages global keyboard shortcuts for Afterglow actions.
/// Uses Carbon's RegisterEventHotKey API for system-wide hotkey registration.
final class ShortcutManager: ObservableObject {
    struct Shortcut: Codable, Equatable {
        let keyCode: UInt32
        let modifiers: UInt32

        var displayString: String {
            var parts: [String] = []
            if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
            if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
            if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
            if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }

            if let keyString = KeyCodeMapping.string(for: keyCode) {
                parts.append(keyString)
            }

            return parts.joined()
        }
    }

    enum Action: String, CaseIterable, Codable {
        case toggleNightShift
        case increaseTemperature
        case decreaseTemperature
        case disableForCurrentApp
        case disableForDomain
        case disableForHour
        case toggleTrueTone
        case toggleDarkMode

        var displayName: String {
            switch self {
            case .toggleNightShift: return "Toggle Night Shift"
            case .increaseTemperature: return "Increase Color Temperature"
            case .decreaseTemperature: return "Decrease Color Temperature"
            case .disableForCurrentApp: return "Disable for Current App"
            case .disableForDomain: return "Disable for Current Domain"
            case .disableForHour: return "Disable for One Hour"
            case .toggleTrueTone: return "Toggle True Tone"
            case .toggleDarkMode: return "Toggle Dark Mode"
            }
        }
    }

    @Published var bindings: [Action: Shortcut] = [:]

    /// Callback triggered when a shortcut action fires.
    var onAction: ((Action) -> Void)?

    private var hotKeyRefs: [Action: EventHotKeyRef] = [:]
    private let defaults = UserDefaults.standard
    private static let defaultsKey = "afterglow.shortcuts"

    init() {
        loadBindings()
    }

    func setShortcut(_ shortcut: Shortcut?, for action: Action) {
        // Unregister existing
        if let ref = hotKeyRefs[action] {
            UnregisterEventHotKey(ref)
            hotKeyRefs[action] = nil
        }

        if let shortcut = shortcut {
            bindings[action] = shortcut
            registerHotKey(shortcut, for: action)
        } else {
            bindings[action] = nil
        }

        saveBindings()
    }

    func registerAll() {
        for (action, shortcut) in bindings {
            registerHotKey(shortcut, for: action)
        }
    }

    func unregisterAll() {
        for (action, ref) in hotKeyRefs {
            UnregisterEventHotKey(ref)
            hotKeyRefs[action] = nil
        }
    }

    // MARK: - Private

    private func registerHotKey(_ shortcut: Shortcut, for action: Action) {
        let hotKeyID = EventHotKeyID(
            signature: OSType(0x4147_4C57), // "AGLW" - Afterglow
            id: UInt32(action.hashValue & 0xFFFF)
        )

        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr, let ref = hotKeyRef {
            hotKeyRefs[action] = ref
        }
    }

    private func loadBindings() {
        guard let data = defaults.data(forKey: Self.defaultsKey),
              let decoded = try? JSONDecoder().decode([String: Shortcut].self, from: data) else {
            return
        }
        for (key, shortcut) in decoded {
            if let action = Action(rawValue: key) {
                bindings[action] = shortcut
            }
        }
    }

    private func saveBindings() {
        let encoded = bindings.reduce(into: [String: Shortcut]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }
        if let data = try? JSONEncoder().encode(encoded) {
            defaults.set(data, forKey: Self.defaultsKey)
        }
    }
}

// MARK: - Key Code Mapping

private enum KeyCodeMapping {
    static func string(for keyCode: UInt32) -> String? {
        let mapping: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P",
            36: "↩", 37: "L", 38: "J", 39: "'", 40: "K", 41: ";",
            42: "\\", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
            48: "⇥", 49: "Space", 50: "`",
            96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8",
            101: "F9", 103: "F11", 105: "F13", 107: "F14",
            109: "F10", 111: "F12", 113: "F15",
            115: "Home", 116: "PgUp", 117: "⌫", 118: "F4",
            119: "End", 120: "F2", 121: "PgDn", 122: "F1",
            123: "←", 124: "→", 125: "↓", 126: "↑",
        ]
        return mapping[keyCode]
    }
}
