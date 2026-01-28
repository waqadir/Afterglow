import XCTest
@testable import Afterglow

final class AfterglowTests: XCTestCase {

    // MARK: - AppRule Tests

    func testAppRuleCreation() {
        let rule = AppRule(bundleIdentifier: "com.example.app", appName: "Example")
        XCTAssertEqual(rule.bundleIdentifier, "com.example.app")
        XCTAssertEqual(rule.appName, "Example")
        XCTAssertTrue(rule.isEnabled)
        XCTAssertEqual(rule.mode, .whenFrontmost)
    }

    func testAppRuleIdentity() {
        let rule = AppRule(bundleIdentifier: "com.example.app", appName: "Example")
        XCTAssertEqual(rule.id, "com.example.app")
    }

    // MARK: - BrowserRule Tests

    func testBrowserRuleCreation() {
        let rule = BrowserRule(host: "youtube.com", type: .domain)
        XCTAssertEqual(rule.host, "youtube.com")
        XCTAssertEqual(rule.type, .domain)
        XCTAssertTrue(rule.isEnabled)
    }

    // MARK: - NightShiftSchedule Tests

    func testScheduleDisplayName() {
        XCTAssertEqual(NightShiftSchedule.off.displayName, "Off")
        XCTAssertEqual(NightShiftSchedule.sunsetToSunrise.displayName, "Sunset to Sunrise")

        let start = ScheduleTime(hour: 22, minute: 0)
        let end = ScheduleTime(hour: 7, minute: 0)
        XCTAssertEqual(NightShiftSchedule.custom(start: start, end: end).displayName, "10:00 PM to 7:00 AM")
    }

    func testScheduleTimeFormatting() {
        XCTAssertEqual(ScheduleTime(hour: 0, minute: 0).formatted, "12:00 AM")
        XCTAssertEqual(ScheduleTime(hour: 12, minute: 30).formatted, "12:30 PM")
        XCTAssertEqual(ScheduleTime(hour: 15, minute: 5).formatted, "3:05 PM")
        XCTAssertEqual(ScheduleTime(hour: 9, minute: 0).formatted, "9:00 AM")
    }

    // MARK: - DisableTimer Tests

    func testDisableTimerDuration() {
        XCTAssertEqual(DisableTimer.Duration.hour.timeInterval, 3600)
        XCTAssertEqual(DisableTimer.Duration.custom(minutes: 30).timeInterval, 1800)
        XCTAssertEqual(DisableTimer.Duration.custom(minutes: 90).timeInterval, 5400)
    }

    func testDisableTimerDisplayString() {
        XCTAssertEqual(DisableTimer.Duration.hour.displayString, "1 hour")
        XCTAssertEqual(DisableTimer.Duration.custom(minutes: 30).displayString, "30 minutes")
        XCTAssertEqual(DisableTimer.Duration.custom(minutes: 1).displayString, "1 minute")
        XCTAssertEqual(DisableTimer.Duration.custom(minutes: 90).displayString, "1h 30m")
        XCTAssertEqual(DisableTimer.Duration.custom(minutes: 120).displayString, "2 hours")
    }

    // MARK: - BrowserManager Tests

    func testSupportedBrowserDetection() {
        let manager = BrowserManager()
        XCTAssertTrue(manager.isSupportedBrowser("com.apple.Safari"))
        XCTAssertTrue(manager.isSupportedBrowser("com.google.Chrome"))
        XCTAssertTrue(manager.isSupportedBrowser("company.thebrowser.Browser"))
        XCTAssertFalse(manager.isSupportedBrowser("com.example.randomapp"))
    }

    func testDomainExtraction() {
        let manager = BrowserManager()

        let url1 = URL(string: "https://mail.google.com/inbox")!
        XCTAssertEqual(manager.registeredDomain(from: url1), "google.com")
        XCTAssertEqual(manager.subdomain(from: url1), "mail.google.com")

        let url2 = URL(string: "https://youtube.com/watch?v=123")!
        XCTAssertEqual(manager.registeredDomain(from: url2), "youtube.com")
    }

    // MARK: - RuleManager Tests

    func testAddAndRemoveAppRule() {
        let manager = RuleManager()
        let rule = AppRule(bundleIdentifier: "com.test.app", appName: "Test App")

        manager.addAppRule(rule)
        XCTAssertTrue(manager.isAppDisabled(bundleIdentifier: "com.test.app"))

        manager.removeAppRule(bundleIdentifier: "com.test.app")
        XCTAssertFalse(manager.isAppDisabled(bundleIdentifier: "com.test.app"))
    }

    func testToggleAppRule() {
        let manager = RuleManager()

        // First toggle creates the rule
        manager.toggleAppRule(bundleIdentifier: "com.test.app", appName: "Test App")
        XCTAssertTrue(manager.isAppDisabled(bundleIdentifier: "com.test.app"))

        // Second toggle disables it
        manager.toggleAppRule(bundleIdentifier: "com.test.app", appName: "Test App")
        XCTAssertFalse(manager.isAppDisabled(bundleIdentifier: "com.test.app"))
    }
}
