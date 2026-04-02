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
                    ZStack {
                        Circle()
                            .fill(paceColor(for: context.state.currentPaceType))
                        Image(systemName: paceSymbol(for: context.state.currentPaceType))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 30, height: 30)
                    .padding(.leading, 10)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.routeName)
                            .font(.headline)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(context.state.nextInstruction.isEmpty ? "Follow route" : context.state.nextInstruction)
                            .font(.caption2)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f mi", context.state.remainingMiles))
                            .font(.headline)
                        Text("~\(context.state.remainingMinutes) min")
                            .font(.caption)
                    }
                    .foregroundStyle(paceColor(for: context.state.currentPaceType))
                    .padding(.trailing, 10)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: paceSymbol(for: context.state.currentPaceType))
                        Text(context.state.currentPaceType)
                            .font(.caption.weight(.semibold))
                        Spacer()
                        Text(context.state.nextInstruction.isEmpty ? "Continue on route" : context.state.nextInstruction)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.trailing)
                    }
                    .foregroundStyle(paceColor(for: context.state.currentPaceType))
                    .padding(.horizontal, 10)
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
                HStack(spacing: 3) {
                    Image(systemName: directionSymbol(for: context.state.nextInstruction))
                        .font(.caption2.weight(.bold))
                    Text(compactDistanceText(feet: context.state.nextInstructionDistanceFeet))
                        .font(.caption2.weight(.black))
                        .monospacedDigit()
                }
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
    
    private func directionSymbol(for instruction: String) -> String {
        let lowered = instruction.lowercased()
        if lowered.contains("turn around") || lowered.contains("u-turn") {
            return "arrow.uturn.backward"
        }
        if lowered.contains("slight left") {
            return "arrow.up.left"
        }
        if lowered.contains("slight right") {
            return "arrow.up.right"
        }
        if lowered.contains("sharp left") {
            return "arrowshape.turn.up.left"
        }
        if lowered.contains("sharp right") {
            return "arrowshape.turn.up.right"
        }
        if lowered.contains("left") {
            return "arrowshape.turn.up.left"
        }
        if lowered.contains("right") {
            return "arrowshape.turn.up.right"
        }
        if lowered.contains("straight") || lowered.contains("continue") || lowered.contains("head") {
            return "arrow.up"
        }
        return "location.fill"
    }
    
    private func compactDistanceText(feet: Int) -> String {
        guard feet > 0 else { return "" }
        if feet >= 1320 {
            return String(format: "%.1f mi", Double(feet) / 5280.0)
        }
        return "\(feet)ft"
    }
}
