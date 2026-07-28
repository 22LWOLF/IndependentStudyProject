//
//  ActiveView.swift
//  MapApp
//
//  The live-route tab. Shows the queued route full-bleed with a status card.
//  Skeleton for now: Start/End toggles session state; real GPS progress,
//  voice guidance, and Live Activity wiring land in the next pass.
//

import SwiftUI

struct ActiveView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        if let route = model.builtRoute {
            activeContent(route)
        } else {
            emptyState
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 44))
                .foregroundStyle(Theme.denim)
            Text("No route queued")
                .font(.title3.weight(.semibold))
            Text("Build a route and it will be waiting for you here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                model.selectedTab = .build
            } label: {
                Text("Go to Build")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.denim)
                    .foregroundStyle(Theme.onAccent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }

    // MARK: - Active route

    private func activeContent(_ route: BuiltRoute) -> some View {
        ZStack(alignment: .bottom) {
            MapCanvasView()
                .ignoresSafeArea(edges: .top)

            statusCard(route)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }

    private func statusCard(_ route: BuiltRoute) -> some View {
        VStack(spacing: 16) {
            HStack {
                if let firstPace = route.paceSegments.first?.paceType {
                    HStack(spacing: 8) {
                        Image(systemName: firstPace.symbolName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Theme.color(for: firstPace))
                            .clipShape(Circle())
                        Text(firstPace.rawValue)
                            .font(.subheadline.weight(.bold))
                    }
                }
                Spacer()
                if model.isLive {
                    Text("LIVE")
                        .font(.caption.weight(.heavy))
                        .tracking(0.5)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.sun)
                        .foregroundStyle(Theme.onAccent)
                        .clipShape(Capsule())
                }
            }

            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.1f", model.remainingMiles(for: route)))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("miles left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("~\(Int(model.remainingMinutes(for: route).rounded()))")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if model.isLive, let progress = model.progress {
                ProgressView(value: min(max(progress.fraction, 0), 1))
                    .tint(Theme.denim)
            }

            HStack(spacing: 10) {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.denim)
                Text(instructionText)
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding(12)
            .background(Theme.surfaceHi)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                withAnimation(.snappy) {
                    if model.isLive {
                        model.endRoute()
                    } else {
                        model.startRoute()
                    }
                }
            } label: {
                Text(model.isLive ? "End route" : "Start route")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(model.isLive ? Theme.danger : Theme.denim)
                    .foregroundStyle(model.isLive ? .white : Theme.onAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: -2)
    }

    private var instructionText: String {
        guard model.isLive else {
            return "Press start when you're at the route's first step."
        }
        if let progress = model.progress, progress.deviationMeters > 40 {
            return "You're off the route — head back toward the line."
        }
        if let cue = model.nextCue {
            if let traveled = model.progress?.traveledMeters {
                let feet = Int(((cue.meters - traveled) * 3.28084 / 10).rounded() * 10)
                if feet > 30 {
                    return "In \(feet) ft: \(cue.instruction)"
                }
            }
            return cue.instruction
        }
        return "Follow the route."
    }
}

#Preview {
    RootTabView()
}
