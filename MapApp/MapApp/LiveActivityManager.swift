import ActivityKit
import UIKit

enum LiveActivityManager {
    private static let heartbeatKey = "routeLiveActivityHeartbeat"
    private static let activeKey = "routeLiveActivityActive"
    private static let cleanupDelay: TimeInterval = 15
    private static var backgroundCleanupWorkItem: DispatchWorkItem?

    @available(iOS 16.1, *)
    static func endAllRouteActivities() async {
        for activity in Activity<MapAppRouteActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        markRouteActivityEnded()
    }

    static func requestEndAllRouteActivities(using application: UIApplication) {
        guard #available(iOS 16.1, *) else { return }
        cancelScheduledCleanup()

        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskID = application.beginBackgroundTask(withName: "End Route Live Activity") {
            if backgroundTaskID != .invalid {
                application.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
        }

        Task {
            await endAllRouteActivities()
            if backgroundTaskID != .invalid {
                application.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
        }
    }

    static func markRouteActivityStarted() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: activeKey)
        defaults.set(Date().timeIntervalSince1970, forKey: heartbeatKey)
    }

    static func markRouteActivityHeartbeat() {
        let defaults = UserDefaults.standard
        defaults.set(Date().timeIntervalSince1970, forKey: heartbeatKey)
    }

    static func markRouteActivityEnded() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: activeKey)
        defaults.removeObject(forKey: heartbeatKey)
    }

    static func cleanupAbandonedActivitiesIfNeeded(using application: UIApplication) {
        guard UserDefaults.standard.bool(forKey: activeKey) else { return }
        guard isHeartbeatExpired(maxAge: cleanupDelay) else { return }
        requestEndAllRouteActivities(using: application)
    }

    static func scheduleBackgroundCleanup(using application: UIApplication) {
        cancelScheduledCleanup()

        let workItem = DispatchWorkItem {
            guard application.applicationState == .background else { return }
            guard UserDefaults.standard.bool(forKey: activeKey) else { return }
            guard isHeartbeatExpired(maxAge: cleanupDelay) else { return }
            requestEndAllRouteActivities(using: application)
        }

        backgroundCleanupWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + cleanupDelay, execute: workItem)
    }

    static func cancelScheduledCleanup() {
        backgroundCleanupWorkItem?.cancel()
        backgroundCleanupWorkItem = nil
    }

    private static func isHeartbeatExpired(maxAge: TimeInterval) -> Bool {
        let heartbeat = UserDefaults.standard.double(forKey: heartbeatKey)
        guard heartbeat > 0 else { return true }
        return Date().timeIntervalSince1970 - heartbeat >= maxAge
    }
}
