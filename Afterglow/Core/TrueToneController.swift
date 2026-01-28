import Foundation

/// Controls True Tone display via the private CoreBrightness framework.
final class TrueToneController {
    private let client = CBTrueToneClient()

    var isSupported: Bool {
        client.supported()
    }

    var isAvailable: Bool {
        client.available()
    }

    var isEnabled: Bool {
        client.enabled()
    }

    func setEnabled(_ enabled: Bool) {
        client.setEnabled(enabled)
    }
}
