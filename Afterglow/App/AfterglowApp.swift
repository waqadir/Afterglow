import SwiftUI

@main
struct AfterglowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isNightShiftEnabled ? "moon.fill" : "sun.max.fill")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Verify Night Shift hardware support
        guard CBBlueLightClient.supportsBlueLightReduction() else {
            let alert = NSAlert()
            alert.messageText = "Night Shift Not Supported"
            alert.informativeText = "This Mac does not support Night Shift. Afterglow requires Night Shift-compatible hardware."
            alert.alertStyle = .critical
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
