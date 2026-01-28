import Foundation

/// Represents a rule to disable Night Shift for a specific website domain or subdomain.
struct BrowserRule: Codable, Identifiable, Hashable {
    let id: UUID
    let host: String
    let type: RuleType
    var isEnabled: Bool

    enum RuleType: String, Codable {
        /// Applies to the entire registered domain (e.g., youtube.com).
        case domain
        /// Applies to a specific subdomain (e.g., music.youtube.com).
        case subdomain
    }

    init(
        host: String,
        type: RuleType,
        isEnabled: Bool = true
    ) {
        self.id = UUID()
        self.host = host
        self.type = type
        self.isEnabled = isEnabled
    }
}
