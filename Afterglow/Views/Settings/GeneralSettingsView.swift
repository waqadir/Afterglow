import SwiftUI
import ServiceManagement

/// General preferences: launch at login, schedule, dark mode sync, etc.
struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState

    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("syncDarkMode") private var syncDarkMode = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true

    @State private var scheduleSelection: Int = 0 // 0=off, 1=solar, 2=custom
    @State private var customStart = Date()
    @State private var customEnd = Date()

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch Afterglow at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(newValue)
                    }
            }

            Section("Schedule") {
                Picker("Night Shift Schedule:", selection: $scheduleSelection) {
                    Text("Off").tag(0)
                    Text("Sunset to Sunrise").tag(1)
                    Text("Custom").tag(2)
                }
                .pickerStyle(.radioGroup)
                .onChange(of: scheduleSelection) { newValue in
                    applySchedule(newValue)
                }

                if scheduleSelection == 2 {
                    HStack {
                        DatePicker("From:", selection: $customStart, displayedComponents: .hourAndMinute)
                        DatePicker("To:", selection: $customEnd, displayedComponents: .hourAndMinute)
                    }
                    .onChange(of: customStart) { _ in applySchedule(2) }
                    .onChange(of: customEnd) { _ in applySchedule(2) }
                }
            }

            Section("Appearance") {
                Toggle("Sync Dark Mode with Night Shift schedule", isOn: $syncDarkMode)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadCurrentSchedule()
        }
    }

    private func loadCurrentSchedule() {
        switch appState.schedule {
        case .off:
            scheduleSelection = 0
        case .sunsetToSunrise:
            scheduleSelection = 1
        case .custom(let start, let end):
            scheduleSelection = 2
            customStart = start.date
            customEnd = end.date
        }
    }

    private func applySchedule(_ mode: Int) {
        switch mode {
        case 0:
            appState.nightShift.setSchedule(.off)
        case 1:
            appState.nightShift.setSchedule(.sunsetToSunrise)
        case 2:
            let start = ScheduleTime(from: customStart)
            let end = ScheduleTime(from: customEnd)
            appState.nightShift.setSchedule(.custom(start: start, end: end))
        default:
            break
        }
        appState.refreshState()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }
}
