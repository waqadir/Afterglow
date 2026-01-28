import SwiftUI

/// Keyboard shortcuts preferences.
struct ShortcutsSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("Global Keyboard Shortcuts") {
                ForEach(ShortcutManager.Action.allCases, id: \.self) { action in
                    ShortcutRow(
                        action: action,
                        shortcut: appState.shortcuts.bindings[action],
                        onSet: { shortcut in
                            appState.shortcuts.setShortcut(shortcut, for: action)
                        },
                        onClear: {
                            appState.shortcuts.setShortcut(nil, for: action)
                        }
                    )
                }
            }

            Section {
                Text("Click a shortcut field and press your desired key combination to set it.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

/// A single shortcut configuration row.
struct ShortcutRow: View {
    let action: ShortcutManager.Action
    let shortcut: ShortcutManager.Shortcut?
    let onSet: (ShortcutManager.Shortcut) -> Void
    let onClear: () -> Void

    @State private var isRecording = false

    var body: some View {
        HStack {
            Text(action.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                if isRecording {
                    isRecording = false
                } else {
                    isRecording = true
                }
            } label: {
                if isRecording {
                    Text("Press keys…")
                        .foregroundColor(.accentColor)
                        .frame(width: 120)
                } else if let shortcut = shortcut {
                    Text(shortcut.displayString)
                        .frame(width: 120)
                } else {
                    Text("Click to set")
                        .foregroundColor(.secondary)
                        .frame(width: 120)
                }
            }
            .buttonStyle(.bordered)

            if shortcut != nil {
                Button {
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
