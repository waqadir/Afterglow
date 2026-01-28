import Foundation
import ScriptingBridge

/// Detects the current URL from supported browsers using ScriptingBridge.
/// Used by the rule system to enable per-website Night Shift control.
final class BrowserManager {
    /// Bundle identifiers of supported browsers.
    enum SupportedBrowser: String, CaseIterable {
        case safari = "com.apple.Safari"
        case safariPreview = "com.apple.SafariTechnologyPreview"
        case chrome = "com.google.Chrome"
        case chromeCanary = "com.google.Chrome.canary"
        case chromium = "org.chromium.Chromium"
        case edge = "com.microsoft.edgemac"
        case edgeBeta = "com.microsoft.edgemac.Beta"
        case brave = "com.brave.Browser"
        case braveBeta = "com.brave.Browser.beta"
        case opera = "com.operasoftware.Opera"
        case operaBeta = "com.operasoftware.OperaNext"
        case vivaldi = "com.vivaldi.Vivaldi"
        case arc = "company.thebrowser.Browser"

        var displayName: String {
            switch self {
            case .safari: return "Safari"
            case .safariPreview: return "Safari Technology Preview"
            case .chrome: return "Google Chrome"
            case .chromeCanary: return "Google Chrome Canary"
            case .chromium: return "Chromium"
            case .edge: return "Microsoft Edge"
            case .edgeBeta: return "Microsoft Edge Beta"
            case .brave: return "Brave Browser"
            case .braveBeta: return "Brave Browser Beta"
            case .opera: return "Opera"
            case .operaBeta: return "Opera Beta"
            case .vivaldi: return "Vivaldi"
            case .arc: return "Arc"
            }
        }
    }

    /// Returns the currently active URL from the frontmost browser, if any.
    func currentURL(for bundleIdentifier: String) -> URL? {
        guard let browser = SupportedBrowser(rawValue: bundleIdentifier) else {
            return nil
        }

        // ScriptingBridge access to get active tab URL
        guard let app: AnyObject = SBApplication(bundleIdentifier: bundleIdentifier) else {
            return nil
        }

        let urlString: String?

        switch browser {
        case .safari, .safariPreview:
            urlString = safariCurrentURL(app: app)
        default:
            // Chromium-based browsers share the same scripting model
            urlString = chromiumCurrentURL(app: app)
        }

        guard let string = urlString else { return nil }
        return URL(string: string)
    }

    /// Checks if a given bundle identifier belongs to a supported browser.
    func isSupportedBrowser(_ bundleIdentifier: String) -> Bool {
        SupportedBrowser(rawValue: bundleIdentifier) != nil
    }

    /// Extracts the registered domain from a URL (e.g., "mail.google.com" -> "google.com").
    func registeredDomain(from url: URL) -> String? {
        guard let host = url.host else { return nil }
        let components = host.split(separator: ".")
        guard components.count >= 2 else { return host }
        return components.suffix(2).joined(separator: ".")
    }

    /// Extracts the full subdomain from a URL.
    func subdomain(from url: URL) -> String? {
        url.host
    }

    // MARK: - Private Browser Access

    private func safariCurrentURL(app: AnyObject) -> String? {
        // Safari exposes windows > currentTab > URL
        guard let windows = app.value(forKey: "windows") as? NSArray,
              let firstWindow = windows.firstObject as? NSObject,
              let currentTab = firstWindow.value(forKey: "currentTab") as? NSObject,
              let url = currentTab.value(forKey: "URL") as? String else {
            return nil
        }
        return url
    }

    private func chromiumCurrentURL(app: AnyObject) -> String? {
        // Chromium-based browsers: windows > activeTab > URL
        guard let windows = app.value(forKey: "windows") as? NSArray,
              let firstWindow = windows.firstObject as? NSObject,
              let activeTab = firstWindow.value(forKey: "activeTab") as? NSObject,
              let url = activeTab.value(forKey: "URL") as? String else {
            return nil
        }
        return url
    }
}
