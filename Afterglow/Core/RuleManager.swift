import Foundation

/// Manages per-app and per-website Night Shift disable rules.
/// Rules persist across launches via UserDefaults.
final class RuleManager: ObservableObject {
    @Published var appRules: [AppRule] = []
    @Published var browserRules: [BrowserRule] = []

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let appRules = "afterglow.appRules"
        static let browserRules = "afterglow.browserRules"
    }

    init() {
        loadRules()
    }

    // MARK: - App Rules

    func isAppDisabled(bundleIdentifier: String) -> Bool {
        appRules.contains { $0.bundleIdentifier == bundleIdentifier && $0.isEnabled }
    }

    func addAppRule(_ rule: AppRule) {
        if let index = appRules.firstIndex(where: { $0.bundleIdentifier == rule.bundleIdentifier }) {
            appRules[index] = rule
        } else {
            appRules.append(rule)
        }
        saveRules()
    }

    func removeAppRule(bundleIdentifier: String) {
        appRules.removeAll { $0.bundleIdentifier == bundleIdentifier }
        saveRules()
    }

    func toggleAppRule(bundleIdentifier: String, appName: String) {
        if let index = appRules.firstIndex(where: { $0.bundleIdentifier == bundleIdentifier }) {
            appRules[index].isEnabled.toggle()
            saveRules()
        } else {
            addAppRule(AppRule(bundleIdentifier: bundleIdentifier, appName: appName))
        }
    }

    // MARK: - Browser Rules

    func isDomainDisabled(_ domain: String) -> Bool {
        browserRules.contains { $0.host == domain && $0.type == .domain && $0.isEnabled }
    }

    func isSubdomainDisabled(_ subdomain: String) -> Bool {
        browserRules.contains { $0.host == subdomain && $0.type == .subdomain && $0.isEnabled }
    }

    func addBrowserRule(_ rule: BrowserRule) {
        if let index = browserRules.firstIndex(where: { $0.host == rule.host && $0.type == rule.type }) {
            browserRules[index] = rule
        } else {
            browserRules.append(rule)
        }
        saveRules()
    }

    func removeBrowserRule(host: String, type: BrowserRule.RuleType) {
        browserRules.removeAll { $0.host == host && $0.type == type }
        saveRules()
    }

    func toggleDomainRule(host: String) {
        if let index = browserRules.firstIndex(where: { $0.host == host && $0.type == .domain }) {
            browserRules[index].isEnabled.toggle()
            saveRules()
        } else {
            addBrowserRule(BrowserRule(host: host, type: .domain))
        }
    }

    // MARK: - Persistence

    private func loadRules() {
        if let data = defaults.data(forKey: Keys.appRules),
           let rules = try? JSONDecoder().decode([AppRule].self, from: data) {
            appRules = rules
        }
        if let data = defaults.data(forKey: Keys.browserRules),
           let rules = try? JSONDecoder().decode([BrowserRule].self, from: data) {
            browserRules = rules
        }
    }

    private func saveRules() {
        if let data = try? JSONEncoder().encode(appRules) {
            defaults.set(data, forKey: Keys.appRules)
        }
        if let data = try? JSONEncoder().encode(browserRules) {
            defaults.set(data, forKey: Keys.browserRules)
        }
    }
}
