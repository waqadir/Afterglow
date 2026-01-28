import SwiftUI

/// The main menu bar popover content displayed when the user clicks the status item.
struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Night Shift Toggle
            nightShiftSection

            Divider()
                .padding(.vertical, 4)

            // Color Temperature Slider
            ColorTemperatureSlider(
                value: Binding(
                    get: { appState.colorTemperature },
                    set: { appState.setColorTemperature($0) }
                ),
                isEnabled: appState.isNightShiftEnabled
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Schedule description
            if appState.schedule.isScheduled {
                Text(scheduleDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }

            Divider()
                .padding(.vertical, 4)

            // True Tone (if supported)
            if appState.isTrueToneSupported {
                trueToneSection

                Divider()
                    .padding(.vertical, 4)
            }

            // Per-app disable
            if let app = appState.currentApp {
                appRuleSection(app: app)

                Divider()
                    .padding(.vertical, 4)
            }

            // Disable timer section
            disableTimerSection

            Divider()
                .padding(.vertical, 4)

            // Bottom actions
            bottomSection
        }
        .padding(.vertical, 8)
        .frame(width: 280)
    }

    // MARK: - Sections

    private var nightShiftSection: some View {
        Toggle(isOn: Binding(
            get: { appState.isNightShiftEnabled },
            set: { _ in appState.toggleNightShift() }
        )) {
            Label("Night Shift", systemImage: "moon.fill")
        }
        .toggleStyle(.switch)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var trueToneSection: some View {
        Toggle(isOn: Binding(
            get: { appState.isTrueToneEnabled },
            set: { _ in appState.toggleTrueTone() }
        )) {
            Label("True Tone", systemImage: "sun.max.trianglebadge.exclamationmark")
        }
        .toggleStyle(.switch)
        .disabled(!appState.isTrueToneAvailable)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private func appRuleSection(app: RunningApp) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                appState.rules.toggleAppRule(
                    bundleIdentifier: app.id,
                    appName: app.name
                )
                appState.refreshState()
            } label: {
                HStack {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    Text(appState.isDisabledForCurrentApp
                         ? "Enable for \(app.name)"
                         : "Disable for \(app.name)")
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private var disableTimerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let timer = appState.activeDisableTimer {
                HStack {
                    Text("Disabled — \(timer.remainingTimeFormatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Cancel") {
                        appState.cancelDisableTimer()
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            } else {
                Button("Disable for 1 Hour") {
                    appState.disableForOneHour()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)

                Button("Disable for Custom Time…") {
                    // TODO: Show custom time picker
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            SettingsLink {
                Text("Settings…")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)

            Button("Quit Afterglow") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Computed

    private var scheduleDescription: String {
        switch appState.schedule {
        case .off:
            return ""
        case .sunsetToSunrise:
            return appState.isNightShiftEnabled
                ? "On until sunrise"
                : "Scheduled: Sunset to Sunrise"
        case .custom(let start, let end):
            return appState.isNightShiftEnabled
                ? "On until \(end.formatted)"
                : "Scheduled: \(start.formatted) to \(end.formatted)"
        }
    }
}
