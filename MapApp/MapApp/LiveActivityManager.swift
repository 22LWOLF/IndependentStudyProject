import ActivityKit
import UIKit

enum LiveActivityManager {
    @available(iOS 16.1, *)
    static func endAllRouteActivities() async {
        for activity in Activity<MapAppRouteActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    static func requestEndAllRouteActivities(using application: UIApplication) {
        guard #available(iOS 16.1, *) else { return }

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
}
