import ActivityKit
import SwiftUI
import WidgetKit

struct MapAppRouteLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MapAppRouteActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text(context.state.routeName)
                    .font(.headline)
                    .lineLimit(1)
                HStack {
                    Label(String(format: "%.2f mi", context.state.remainingMiles), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    Spacer()
                    Label("~\(context.state.remainingMinutes) min", systemImage: "clock")
                }
                .font(.subheadline)
                Text(context.state.nextInstruction.isEmpty ? "Follow route" : context.state.nextInstruction)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 10)
            .activityBackgroundTint(paceColor(for: context.state.currentPaceType).opacity(0.16))
            .activitySystemActionForegroundColor(paceColor(for: context.state.currentPaceType))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(paceColor(for: context.state.currentPaceType))
                            Image(systemName: paceSymbol(for: context.state.currentPaceType))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 28, height: 28)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(context.state.routeName)
                                .font(.headline)
                                .lineLimit(1)
                            Text(context.state.nextInstruction.isEmpty ? "Follow route" : context.state.nextInstruction)
                                .font(.caption2)
                                .lineLimit(2)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f mi", context.state.remainingMiles))
                            .font(.headline)
                        Text("~\(context.state.remainingMinutes) min")
                            .font(.caption)
                    }
                    .foregroundStyle(paceColor(for: context.state.currentPaceType))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: paceSymbol(for: context.state.currentPaceType))
                        Text(context.state.currentPaceType)
                            .font(.caption.weight(.semibold))
                        Spacer()
                        Text(context.state.nextInstruction.isEmpty ? "Continue on route" : context.state.nextInstruction)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(paceColor(for: context.state.currentPaceType))
                }
            } compactLeading: {
                ZStack {
                    Circle()
                        .fill(paceColor(for: context.state.currentPaceType))
                    Image(systemName: paceSymbol(for: context.state.currentPaceType))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 24, height: 24)
            } compactTrailing: {
                Text(compactDirectionText(for: context.state.nextInstruction))
                    .font(.caption2.weight(.black))
                    .lineLimit(1)
                    .foregroundStyle(.white)
            } minimal: {
                ZStack {
                    Circle()
                        .fill(paceColor(for: context.state.currentPaceType))
                    Image(systemName: paceSymbol(for: context.state.currentPaceType))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 24, height: 24)
            }
            .keylineTint(paceColor(for: context.state.currentPaceType))
        }
    }
    
    private func paceColor(for paceType: String) -> Color {
        switch paceType {
        case "Walk":
            return .green
        case "Jog":
            return .orange
        case "Run":
            return .red
        default:
            return .blue
        }
    }
    
    private func paceSymbol(for paceType: String) -> String {
        switch paceType {
        case "Walk":
            return "tortoise.fill"
        case "Jog":
            return "figure.run"
        case "Run":
            return "hare.fill"
        default:
            return "location.fill"
        }
    }
    
    private func compactDirectionText(for instruction: String) -> String {
        let lowered = instruction.lowercased()
        if lowered.contains("left") {
            return "L"
        }
        if lowered.contains("right") {
            return "R"
        }
        if lowered.contains("straight") || lowered.contains("continue") {
            return "↑"
        }
        if lowered.contains("turn around") {
            return "↺"
        }
        return "\(0)".replacingOccurrences(of: "0", with: "")
    }
}
