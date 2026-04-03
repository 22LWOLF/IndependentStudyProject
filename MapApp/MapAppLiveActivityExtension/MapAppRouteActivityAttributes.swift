import ActivityKit
import Foundation

struct MapAppRouteActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var routeName: String
        var remainingMiles: Double
        var remainingMinutes: Int
        var nextInstruction: String
        var nextInstructionDistanceFeet: Int
        var currentPaceType: String
    }
    
    var routeID: String
}
