//
//  MapAppLiveActivityExtensionLiveActivity.swift
//  MapAppLiveActivityExtension
//
//  Created by Wolf,Luke D on 3/31/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MapAppLiveActivityExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MapAppLiveActivityExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MapAppLiveActivityExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MapAppLiveActivityExtensionAttributes {
    fileprivate static var preview: MapAppLiveActivityExtensionAttributes {
        MapAppLiveActivityExtensionAttributes(name: "World")
    }
}

extension MapAppLiveActivityExtensionAttributes.ContentState {
    fileprivate static var smiley: MapAppLiveActivityExtensionAttributes.ContentState {
        MapAppLiveActivityExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MapAppLiveActivityExtensionAttributes.ContentState {
         MapAppLiveActivityExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MapAppLiveActivityExtensionAttributes.preview) {
   MapAppLiveActivityExtensionLiveActivity()
} contentStates: {
    MapAppLiveActivityExtensionAttributes.ContentState.smiley
    MapAppLiveActivityExtensionAttributes.ContentState.starEyes
}
