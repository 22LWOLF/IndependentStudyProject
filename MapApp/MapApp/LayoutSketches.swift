//
//  LayoutSketches.swift
//  MapApp
//
//  Preview-only UI sketches for the StepOut redesign.
//  None of these views are wired to RouteEngine — they exist purely so you can
//  compare layout directions in Xcode's Canvas. Once you pick a direction,
//  delete this file (or cannibalize the chosen layout into the real UI).
//
//  How to view:
//    1. Open this file in Xcode
//    2. Open the Canvas (Editor → Canvas, or ⌥⌘↩)
//    3. Use the preview chooser at the bottom of the canvas to switch sketches.

//Launch Screen: is 2 Tabs plan layout

//Customize/Alter route specs page: layout 6 Customize Rotue Sheet

// Go/when you are running the route you made screen is: layout 2 Tabs Go (active)

// Route history/You page vibe of ultra modern (dark)

//

import SwiftUI

// =============================================================================
// MARK: - Shared placeholder bits
// =============================================================================

private struct MapPlaceholder: View {
    var cornerRadius: CGFloat = 0
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.86, green: 0.90, blue: 0.85),
                         Color(red: 0.74, green: 0.81, blue: 0.78)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            // Faux road network
            GeometryReader { geo in
                Path { p in
                    p.move(to: CGPoint(x: 0, y: geo.size.height * 0.32))
                    p.addCurve(
                        to: CGPoint(x: geo.size.width, y: geo.size.height * 0.55),
                        control1: CGPoint(x: geo.size.width * 0.3, y: geo.size.height * 0.12),
                        control2: CGPoint(x: geo.size.width * 0.6, y: geo.size.height * 0.65)
                    )
                    p.move(to: CGPoint(x: geo.size.width * 0.2, y: 0))
                    p.addLine(to: CGPoint(x: geo.size.width * 0.55, y: geo.size.height))
                    p.move(to: CGPoint(x: 0, y: geo.size.height * 0.78))
                    p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.84))
                }
                .stroke(Color.white.opacity(0.55), lineWidth: 5)

                // Faux route polyline
                Path { p in
                    p.move(to: CGPoint(x: geo.size.width * 0.28, y: geo.size.height * 0.7))
                    p.addCurve(
                        to: CGPoint(x: geo.size.width * 0.78, y: geo.size.height * 0.32),
                        control1: CGPoint(x: geo.size.width * 0.42, y: geo.size.height * 0.55),
                        control2: CGPoint(x: geo.size.width * 0.55, y: geo.size.height * 0.58)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [.green, .orange, .red],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct FloatingMapButton: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.primary)
            .frame(width: 44, height: 44)
            .background(.thinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }
}

// =============================================================================
// MARK: - Layout 1: Apple Maps style sheet
// =============================================================================

struct AppleMapsSheetLayout: View {
    @State private var selectedMinutes = 30

    var body: some View {
        ZStack(alignment: .top) {
            MapPlaceholder().ignoresSafeArea()

            // Top-right floating controls
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    FloatingMapButton(systemName: "magnifyingglass")
                    FloatingMapButton(systemName: "location.fill")
                    FloatingMapButton(systemName: "gearshape.fill")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 60)

            // Bottom sheet
            VStack(spacing: 0) {
                Spacer()
                sheet
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var sheet: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.gray.opacity(0.45))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 14) {
                Text("How much time do you have?")
                    .font(.headline)

                HStack(spacing: 8) {
                    ForEach([15, 30, 45, 60], id: \.self) { mins in
                        chip(label: "\(mins) min", selected: selectedMinutes == mins)
                            .onTapGesture { selectedMinutes = mins }
                    }
                    chip(label: "Custom", selected: false)
                }

                Divider().padding(.vertical, 2)

                drillRow(icon: "figure.run", label: "Pace mix", detail: "60% walk · 40% jog")
                drillRow(icon: "point.topleft.down.curvedto.point.bottomright.up", label: "Route type", detail: "Loop")
                drillRow(icon: "slider.horizontal.3", label: "Advanced options", detail: nil)
                drillRow(icon: "bookmark.fill", label: "Saved routes", detail: "12")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
    }

    private func chip(label: String, selected: Bool) -> some View {
        Text(label)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(selected ? .white : .primary)
            .clipShape(Capsule())
    }

    private func drillRow(icon: String, label: String, detail: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).frame(width: 24)
            Text(label).font(.subheadline.weight(.medium))
            Spacer()
            if let detail {
                Text(detail).font(.caption).foregroundColor(.secondary)
            }
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }
}

#Preview("1 · Apple Maps sheet") { AppleMapsSheetLayout() }


// =============================================================================
// MARK: - Layout 2: Two-tab Plan / Go
// =============================================================================

struct TwoTabPlanGoLayout: View {
    var body: some View {
        TabView {
            PlanTab()
                .tabItem { Label("Plan", systemImage: "map") }
            GoTab()
                .tabItem { Label("Go", systemImage: "figure.walk") }
        }
    }
}

private struct PlanTab: View {
    @State private var selectedMinutes = 30
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Plan").font(.largeTitle.bold())
                Spacer()
                Image(systemName: "gearshape").font(.title3).foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Time bar
            VStack(alignment: .leading, spacing: 10) {
                Text("Time available").font(.caption.weight(.semibold)).foregroundColor(.secondary)
                HStack(spacing: 8) {
                    ForEach([15, 30, 45, 60], id: \.self) { m in
                        Text("\(m) min")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(selectedMinutes == m ? Color.accentColor : Color(.systemGray6))
                            .foregroundColor(selectedMinutes == m ? .white : .primary)
                            .clipShape(Capsule())
                            .onTapGesture { selectedMinutes = m }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, 16)

            // Map preview
            MapPlaceholder(cornerRadius: 18)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 16)

            // Bottom action
            VStack(spacing: 10) {
                HStack(spacing: 16) {
                    summaryStat(label: "Distance", value: "~1.4 mi")
                    Divider().frame(height: 28)
                    summaryStat(label: "Pace mix", value: "Walk + Jog")
                    Divider().frame(height: 28)
                    summaryStat(label: "Direction", value: "Random")
                }
                Button {
                } label: {
                    Text("Build my route")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func summaryStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2.weight(.medium)).foregroundColor(.secondary)
            Text(value).font(.footnote.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GoTab: View {
    var body: some View {
        ZStack {
            MapPlaceholder().ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 18) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.orange)
                                .clipShape(Circle())
                            Text("Jog").font(.subheadline.weight(.bold))
                        }
                        Spacer()
                        Text("Live").font(.caption.weight(.bold))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.red).foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    HStack(alignment: .lastTextBaseline, spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("1.4").font(.system(size: 44, weight: .bold, design: .rounded))
                            Text("miles left").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("~18").font(.system(size: 44, weight: .bold, design: .rounded))
                            Text("minutes").font(.caption).foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.accentColor)
                        Text("Turn right in 200 ft").font(.subheadline.weight(.medium))
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                    } label: {
                        Text("End route")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
    }
}

#Preview("2 · Tabs · Plan") { TwoTabPlanGoLayout() }
#Preview("2 · Tabs · Go (active)") {
    // Direct preview of just the Go tab so the canvas focuses on it.
    GoTab()
}


// =============================================================================
// MARK: - Layout 3: Stacked cards, no tabs, no sheet
// =============================================================================

struct StackedCardsLayout: View {
    @State private var selectedMinutes = 30

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Time card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("How much time?").font(.title3.weight(.semibold))
                        Spacer()
                        Image(systemName: "gearshape").foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        ForEach([15, 30, 45, 60], id: \.self) { m in
                            Text("\(m) min")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(selectedMinutes == m ? Color.accentColor : Color(.systemGray6))
                                .foregroundColor(selectedMinutes == m ? .white : .primary)
                                .clipShape(Capsule())
                                .onTapGesture { selectedMinutes = m }
                        }
                        Text("Custom")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
                .padding(18)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                // Map card
                MapPlaceholder(cornerRadius: 18)
                    .frame(height: 280)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)

                // Pace card
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pace mix").font(.subheadline.weight(.semibold))
                    HStack(spacing: 0) {
                        Rectangle().fill(Color.green).frame(maxWidth: .infinity)
                        Rectangle().fill(Color.orange).frame(maxWidth: .infinity).frame(width: 80)
                    }
                    .frame(height: 10)
                    .clipShape(Capsule())
                    HStack {
                        Label("60% walk", systemImage: "tortoise.fill").font(.caption).foregroundColor(.green)
                        Spacer()
                        Label("40% jog", systemImage: "figure.run").font(.caption).foregroundColor(.orange)
                    }
                }
                .padding(18)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                // Action card
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        miniStat(title: "Distance", value: "~1.4 mi")
                        miniStat(title: "ETA", value: "~30 min")
                        miniStat(title: "Type", value: "Loop")
                    }
                    Button {
                    } label: {
                        Text("Build my route")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(18)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func miniStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2.weight(.medium)).foregroundColor(.secondary)
            Text(value).font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview("3 · Stacked cards") { StackedCardsLayout() }


// =============================================================================
// MARK: - Layout 4: Ultra-modern (Robinhood-ish, dark, calm)
// =============================================================================

private enum UM {
    static let bg          = Color(red: 0.04, green: 0.05, blue: 0.06)
    static let surface     = Color(red: 0.10, green: 0.11, blue: 0.13)
    static let surfaceHi   = Color(red: 0.14, green: 0.16, blue: 0.18)
    static let textPrimary = Color(red: 0.94, green: 0.95, blue: 0.96)
    static let textMuted   = Color(red: 0.62, green: 0.66, blue: 0.70)
    static let accent      = Color(red: 0.49, green: 0.78, blue: 0.71)   // soft sage
    static let accentSoft  = Color(red: 0.49, green: 0.78, blue: 0.71).opacity(0.15)
    static let warm        = Color(red: 0.93, green: 0.78, blue: 0.55)
}

struct UltraModernLayout: View {
    @State private var selected = 30

    var body: some View {
        ZStack(alignment: .bottom) {
            UM.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    timeCard
                    paceCard
                    statsRow
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }

            tabBar
        }
        .foregroundColor(UM.textPrimary)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ready when you are.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Build a route that fits the time you have.")
                    .font(.subheadline)
                    .foregroundColor(UM.textMuted)
            }
            Spacer()
            Circle()
                .fill(UM.surfaceHi)
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "person.fill").foregroundColor(UM.textMuted))
        }
    }

    private var timeCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Time").font(.caption.weight(.semibold)).foregroundColor(UM.textMuted)
                Spacer()
                Text("Tap to choose").font(.caption2).foregroundColor(UM.textMuted)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach([15, 30, 45, 60], id: \.self) { m in
                    Button {
                        selected = m
                    } label: {
                        HStack {
                            Text("\(m)")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            Text("min")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(selected == m ? UM.bg.opacity(0.65) : UM.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                        .background(selected == m ? UM.accent : UM.surfaceHi)
                        .foregroundColor(selected == m ? UM.bg : UM.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
            }

            HStack {
                Text("Custom time")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "arrow.right")
            }
            .foregroundColor(UM.textMuted)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(UM.surfaceHi)
            .clipShape(Capsule())
        }
        .padding(20)
        .background(UM.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var paceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Pace blend").font(.caption.weight(.semibold)).foregroundColor(UM.textMuted)
                Spacer()
                Text("Edit").font(.caption.weight(.semibold)).foregroundColor(UM.accent)
            }
            HStack(spacing: 4) {
                Capsule().fill(UM.accent).frame(maxWidth: .infinity).frame(height: 8)
                Capsule().fill(UM.warm).frame(width: 80).frame(height: 8)
            }
            HStack(spacing: 14) {
                Label { Text("60% walk").font(.caption.weight(.medium)) } icon: {
                    Circle().fill(UM.accent).frame(width: 8, height: 8)
                }
                Label { Text("40% jog").font(.caption.weight(.medium)) } icon: {
                    Circle().fill(UM.warm).frame(width: 8, height: 8)
                }
                Spacer()
            }
            .foregroundColor(UM.textMuted)
        }
        .padding(20)
        .background(UM.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCell(title: "Expected", value: "1.4", unit: "mi")
            statCell(title: "Saved routes", value: "12", unit: "")
            statCell(title: "Avg walk", value: "3.1", unit: "mph")
        }
    }

    private func statCell(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.medium)).foregroundColor(UM.textMuted)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(.system(size: 22, weight: .bold, design: .rounded))
                if !unit.isEmpty {
                    Text(unit).font(.caption.weight(.medium)).foregroundColor(UM.textMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(UM.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var tabBar: some View {
        HStack {
            tabItem(icon: "plus.circle.fill", label: "Build", active: true)
            tabItem(icon: "figure.walk", label: "Active", active: false)
            tabItem(icon: "bookmark.fill", label: "Routes", active: false)
            tabItem(icon: "chart.line.uptrend.xyaxis", label: "You", active: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(UM.surface.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }

    private func tabItem(icon: String, label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
            Text(label).font(.caption2.weight(.medium))
        }
        .foregroundColor(active ? UM.accent : UM.textMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(active ? UM.accentSoft : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview("4 · Ultra-modern (dark)") { UltraModernLayout() }


// =============================================================================
// MARK: - Layout 5: Hybrid Plan tab (route type bubble + dual CTA)
// =============================================================================
//
// The Plan tab from Layout 2 + a route-type bubble below the map +
// a two-button row: secondary "Customize" + primary "Build my route".
// Uses the L4 sage accent to start bridging the two aesthetics.
//

private let sageAccent  = Color(red: 0.32, green: 0.62, blue: 0.55)
private let sageSoft    = Color(red: 0.32, green: 0.62, blue: 0.55).opacity(0.14)

struct HybridPlanLayout: View {
    @State private var selectedMinutes = 30
    @State private var routeType: RouteTypePill = .loop

    enum RouteTypePill: String, CaseIterable {
        case oneWay, outAndBack, loop
        var title: String {
            switch self {
            case .oneWay:     return "One-way"
            case .outAndBack: return "Out & back"
            case .loop:       return "Loop"
            }
        }
        var icon: String {
            switch self {
            case .oneWay:     return "arrow.up.forward"
            case .outAndBack: return "arrow.left.and.right"
            case .loop:       return "arrow.triangle.2.circlepath"
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Title bar
            HStack {
                Text("Plan").font(.largeTitle.bold())
                Spacer()
                Image(systemName: "gearshape").font(.title3).foregroundColor(.secondary)
            }
            .padding(.horizontal, 20).padding(.top, 12)

            ScrollView {
                VStack(spacing: 12) {
                    // Time bubble
                    bubble {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Time available").font(.caption.weight(.semibold)).foregroundColor(.secondary)
                            HStack(spacing: 8) {
                                ForEach([15, 30, 45, 60], id: \.self) { m in
                                    Text("\(m) min")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 14).padding(.vertical, 10)
                                        .background(selectedMinutes == m ? sageAccent : Color(.systemGray6))
                                        .foregroundColor(selectedMinutes == m ? .white : .primary)
                                        .clipShape(Capsule())
                                        .onTapGesture { selectedMinutes = m }
                                }
                                Text("Custom")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // Map bubble
                    MapPlaceholder(cornerRadius: 18)
                        .frame(height: 220)
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                    // Route type bubble (NEW)
                    bubble {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Route type").font(.caption.weight(.semibold)).foregroundColor(.secondary)
                            HStack(spacing: 8) {
                                ForEach(RouteTypePill.allCases, id: \.self) { kind in
                                    routeTypeChip(kind)
                                }
                            }
                        }
                    }

                    // Stats summary
                    bubble {
                        HStack(spacing: 16) {
                            stat(label: "Distance", value: "~1.4 mi")
                            Divider().frame(height: 28)
                            stat(label: "Pace mix", value: "60w · 40j")
                            Divider().frame(height: 28)
                            stat(label: "Direction", value: "Random")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }

            // Dual CTA row
            HStack(spacing: 10) {
                Button {
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3").font(.subheadline.weight(.semibold))
                        Text("Customize").font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .foregroundColor(sageAccent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(sageAccent.opacity(0.6), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .frame(maxWidth: 150)

                Button {
                } label: {
                    Text("Build my route")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(sageAccent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func bubble<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private func routeTypeChip(_ kind: RouteTypePill) -> some View {
        let selected = routeType == kind
        return Button {
            routeType = kind
        } label: {
            VStack(spacing: 6) {
                Image(systemName: kind.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(kind.title).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? sageAccent : Color(.systemGray6))
            .foregroundColor(selected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func stat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2.weight(.medium)).foregroundColor(.secondary)
            Text(value).font(.footnote.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("5 · Hybrid Plan tab") { HybridPlanLayout() }


// =============================================================================
// MARK: - Layout 6: Customize Route sheet (full settings, L4 dark)
// =============================================================================

struct CustomizeRouteSheet: View {
    @State private var routeStyle = 0           // 0 fastest, 1 scenic
    @State private var direction: String? = nil // nil = random
    @State private var walk: Double = 0.6
    @State private var jog: Double = 0.4
    @State private var run: Double = 0.0
    @State private var paceOrder: [String] = ["Walk", "Jog"]
    @State private var pulse = 1
    @State private var loopPoints = 4
    @State private var targetMode = 0           // 0 time, 1 distance
    @State private var planByDistance = false

    var body: some View {
        ZStack(alignment: .bottom) {
            UM.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    titleBar
                    routeStyleSection
                    directionSection
                    paceMixSection
                    paceOrderSection
                    pulseSection
                    loopPointsSection
                    targetModeSection
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }

            bottomActionBar
        }
        .foregroundColor(UM.textPrimary)
        .preferredColorScheme(.dark)
    }

    // MARK: Title bar

    private var titleBar: some View {
        HStack {
            Button { } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(UM.surfaceHi)
                    .foregroundColor(UM.textPrimary)
                    .clipShape(Circle())
            }
            Spacer()
            Text("Customize route")
                .font(.headline)
            Spacer()
            // Spacer to balance the close button
            Color.clear.frame(width: 36, height: 36)
        }
    }

    // MARK: Route style

    private var routeStyleSection: some View {
        sectionCard(title: "Route style") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    pillToggle(label: "Fastest", selected: routeStyle == 0) { routeStyle = 0 }
                    pillToggle(label: "Scenic",  selected: routeStyle == 1) { routeStyle = 1 }
                }
                Text(routeStyle == 0
                     ? "Direct path between waypoints."
                     : "Prefers longer or more interesting routes when available.")
                    .font(.caption).foregroundColor(UM.textMuted)
            }
        }
    }

    // MARK: Direction

    private var directionSection: some View {
        let dirs: [[String?]] = [
            ["NW", "N",  "NE"],
            ["W",  nil,  "E" ],
            ["SW", "S",  "SE"]
        ]
        return sectionCard(title: "Direction") {
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { col in
                            let d = dirs[row][col]
                            directionCell(label: d)
                        }
                    }
                }
                Text(direction.map { "Bias toward \($0)" } ?? "Any direction (random)")
                    .font(.caption).foregroundColor(UM.textMuted)
            }
        }
    }

    private func directionCell(label: String?) -> some View {
        let isRandom = label == nil
        let selected: Bool = isRandom ? direction == nil : direction == label
        return Button {
            direction = isRandom ? nil : label
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(selected ? UM.accent : UM.surfaceHi)
                if let label {
                    Text(label).font(.subheadline.weight(.bold))
                } else {
                    Image(systemName: "die.face.5.fill").font(.subheadline.weight(.bold))
                }
            }
            .frame(height: 50)
            .foregroundColor(selected ? UM.bg : UM.textPrimary)
        }
    }

    // MARK: Pace mix

    private var paceMixSection: some View {
        sectionCard(title: "Pace mix") {
            VStack(alignment: .leading, spacing: 14) {
                paceTrack(label: "Walk", percent: walk, color: UM.accent,
                          symbol: "tortoise.fill") { walk = $0 }
                paceTrack(label: "Jog",  percent: jog,  color: UM.warm,
                          symbol: "figure.run") { jog = $0 }
                paceTrack(label: "Run",  percent: run,  color: Color(red: 0.93, green: 0.45, blue: 0.45),
                          symbol: "hare.fill") { run = $0 }

                HStack(spacing: 8) {
                    smallActionButton(icon: "dice.fill", label: "Randomize")
                    smallActionButton(icon: "arrow.uturn.backward", label: "Reset")
                }
            }
        }
    }

    private func paceTrack(label: String, percent: Double, color: Color, symbol: String,
                           onChange: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: symbol).foregroundColor(color).font(.footnote)
                Text(label).font(.footnote.weight(.semibold))
                Spacer()
                Text("\(Int(percent * 100))%").font(.footnote.weight(.bold)).foregroundColor(UM.textMuted)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(UM.surfaceHi).frame(height: 8)
                    Capsule().fill(color).frame(width: geo.size.width * percent, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private func smallActionButton(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption.weight(.bold))
            Text(label).font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(UM.surfaceHi)
        .foregroundColor(UM.textPrimary)
        .clipShape(Capsule())
    }

    // MARK: Pace order

    private var paceOrderSection: some View {
        sectionCard(title: "Pace order") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(paceOrder, id: \.self) { p in
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal")
                                .font(.caption2).foregroundColor(UM.textMuted)
                            Text(p).font(.caption.weight(.semibold))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(UM.surfaceHi)
                        .clipShape(Capsule())
                    }
                    Spacer()
                }
                Text("Drag to reorder how paces appear along the route.")
                    .font(.caption).foregroundColor(UM.textMuted)
            }
        }
    }

    // MARK: Pulse

    private var pulseSection: some View {
        sectionCard(title: "Pulse mode") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ForEach([1, 2, 3, 4, 6, 8], id: \.self) { count in
                        Button {
                            pulse = count
                        } label: {
                            Text(count == 1 ? "Off" : "\(count)×")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(pulse == count ? UM.accent : UM.surfaceHi)
                                .foregroundColor(pulse == count ? UM.bg : UM.textPrimary)
                                .clipShape(Capsule())
                        }
                    }
                }
                Text(pulse == 1
                     ? "Each pace appears once in a single block."
                     : "Repeats the pace pattern \(pulse) times across the route.")
                    .font(.caption).foregroundColor(UM.textMuted)
            }
        }
    }

    // MARK: Loop points

    private var loopPointsSection: some View {
        sectionCard(title: "Loop points") {
            HStack {
                Text("\(loopPoints) waypoints")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                stepper(value: loopPoints, range: 3...8) { loopPoints = $0 }
            }
        }
    }

    private func stepper(value: Int, range: ClosedRange<Int>, onChange: @escaping (Int) -> Void) -> some View {
        HStack(spacing: 0) {
            Button {
                if value > range.lowerBound { onChange(value - 1) }
            } label: {
                Image(systemName: "minus").frame(width: 40, height: 36)
            }
            .background(UM.surfaceHi)

            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .frame(width: 36, height: 36)
                .background(UM.surface)

            Button {
                if value < range.upperBound { onChange(value + 1) }
            } label: {
                Image(systemName: "plus").frame(width: 40, height: 36)
            }
            .background(UM.surfaceHi)
        }
        .foregroundColor(UM.textPrimary)
        .clipShape(Capsule())
    }

    // MARK: Target mode

    private var targetModeSection: some View {
        sectionCard(title: "Target type") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    pillToggle(label: "Time", selected: targetMode == 0,
                               icon: "clock.fill") { targetMode = 0 }
                    pillToggle(label: "Distance", selected: targetMode == 1,
                               icon: "ruler.fill") { targetMode = 1 }
                }
                Text(targetMode == 0
                     ? "Build a route that fits a duration."
                     : "Build a route that fits a mileage target.")
                    .font(.caption).foregroundColor(UM.textMuted)
            }
        }
    }

    // MARK: Bottom action bar

    private var bottomActionBar: some View {
        HStack(spacing: 10) {
            Button { } label: {
                Text("Save settings")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(UM.textPrimary)
                    .background(UM.surfaceHi)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(maxWidth: 140)

            Button { } label: {
                Text("Build with these")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(UM.accent)
                    .foregroundColor(UM.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(
            LinearGradient(
                colors: [UM.bg.opacity(0), UM.bg, UM.bg],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    // MARK: Helpers

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundColor(UM.textMuted)
                .tracking(0.8)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(UM.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func pillToggle(label: String, selected: Bool, icon: String? = nil,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon { Image(systemName: icon).font(.caption.weight(.bold)) }
                Text(label).font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(selected ? UM.accent : UM.surfaceHi)
            .foregroundColor(selected ? UM.bg : UM.textPrimary)
            .clipShape(Capsule())
        }
    }
}

#Preview("6 · Customize Route sheet") { CustomizeRouteSheet() }


// =============================================================================
// MARK: - Layout 7: Map mode indicator (Solution 1 + Solution 3)
// =============================================================================
//
// Solution 1 — persistent text chip in the map corner: "AUTO · 30 MIN" / "MANUAL · 1 PIN"
//   (Helps users who read state from labels.)
// Solution 3 — time chips visibly deselect and dim when manual mode activates.
//   (Helps users who read state from visual fills.)
//
// Two previews demonstrate the transition: Auto (initial) vs Manual (after tap).
// In a static preview you see the BEFORE and AFTER as separate frames; in the
// real app the time chips would animate from filled → drained, and the mode
// chip would morph in place.
//

struct HybridPlanWithModeIndicator: View {
    enum Mode { case auto, manual }

    @State private var mode: Mode
    @State private var selectedMinutes: Int?
    @State private var pinCount: Int

    init(mode: Mode) {
        _mode = State(initialValue: mode)
        _selectedMinutes = State(initialValue: mode == .auto ? 30 : nil)
        _pinCount = State(initialValue: mode == .manual ? 1 : 0)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Title bar
            HStack {
                Text("Plan").font(.largeTitle.bold())
                Spacer()
                Image(systemName: "gearshape").font(.title3).foregroundColor(.secondary)
            }
            .padding(.horizontal, 20).padding(.top, 12)

            ScrollView {
                VStack(spacing: 12) {
                    timeBubble
                    mapBubble
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }

            // Two-button CTA row (same as Layout 5)
            HStack(spacing: 10) {
                Button { } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3").font(.subheadline.weight(.semibold))
                        Text("Customize").font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(sageAccent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(sageAccent.opacity(0.6), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .frame(maxWidth: 150)

                Button { } label: {
                    Text(mode == .manual ? "Build from pins" : "Build my route")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(sageAccent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: Time bubble

    private var timeBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Time available").font(.caption.weight(.semibold)).foregroundColor(.secondary)
                Spacer()
                if mode == .manual {
                    Text("Tap a time to switch back")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                }
            }
            HStack(spacing: 8) {
                ForEach([15, 30, 45, 60], id: \.self) { m in
                    timeChip(m)
                }
                customChip
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private func timeChip(_ m: Int) -> some View {
        let isSelected = (mode == .auto) && (selectedMinutes == m)
        return Text("\(m) min")
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(isSelected ? sageAccent : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .opacity(mode == .manual ? 0.4 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: mode)
    }

    private var customChip: some View {
        Text("Custom")
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            .opacity(mode == .manual ? 0.4 : 1.0)
    }

    // MARK: Map bubble (with overlays)

    private var mapBubble: some View {
        MapPlaceholder(cornerRadius: 18)
            .frame(height: 260)
            .overlay(alignment: .topLeading) { modeChip.padding(10) }
            .overlay(alignment: .center) { pinAtCenter }
            .overlay(alignment: .bottom) { firstLaunchHint }
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private var modeChip: some View {
        let isAuto = mode == .auto
        return HStack(spacing: 6) {
            Image(systemName: isAuto ? "wand.and.stars" : "hand.tap.fill")
                .font(.system(size: 11, weight: .bold))
            Text(modeText)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.6)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(isAuto ? sageAccent : Color.black.opacity(0.7))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }

    private var modeText: String {
        switch mode {
        case .auto:
            return selectedMinutes.map { "AUTO · \($0) MIN" } ?? "AUTO"
        case .manual:
            let plural = pinCount == 1 ? "PIN" : "PINS"
            return "MANUAL · \(pinCount) \(plural)"
        }
    }

    @ViewBuilder
    private var pinAtCenter: some View {
        if mode == .manual && pinCount > 0 {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(sageAccent)
                .background(Circle().fill(Color.white).padding(3))
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var firstLaunchHint: some View {
        if mode == .auto {
            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                    .font(.caption.weight(.semibold))
                Text("Tap anywhere to place your own pins")
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color.black.opacity(0.55))
            .clipShape(Capsule())
            .padding(.bottom, 14)
        }
    }
}

#Preview("7 · Auto mode (initial)") {
    HybridPlanWithModeIndicator(mode: .auto)
}

#Preview("7 · Manual mode (after tap)") {
    HybridPlanWithModeIndicator(mode: .manual)
}
