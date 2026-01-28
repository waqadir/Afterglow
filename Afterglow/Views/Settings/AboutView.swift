import SwiftUI

/// About pane showing app information and credits.
struct AboutView: View {
    private let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }()

    private let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sunset.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Afterglow")
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(appVersion) (\(buildNumber))")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("A modern Night Shift companion for macOS.\nMore control over your display's warmth.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)

            Divider()

            Link("View on GitHub",
                 destination: URL(string: "https://github.com/waqadir/Afterglow")!)
                .font(.caption)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
