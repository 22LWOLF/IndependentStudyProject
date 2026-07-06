//
//  BuildView.swift
//  MapApp
//
//  The launch tab. Pick a time (or distance), optionally drop pins for a
//  manual route, and hit Build. Deep settings live in CustomizeSheet, reached
//  from the Customize button or by tapping any summary chip.
//

import SwiftUI
import MapKit

struct BuildView: View {
    @EnvironmentObject private var model: AppModel

    @State private var showCustomize = false
    @State private var customizeSection: CustomizeSection?
    @State private var showCustomTarget = false
    @State private var customTargetText = ""

    private let minuteChoices: [Double] = [15, 30, 45, 60]
    private let mileChoices: [Double] = [1, 2, 3, 5]

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 12) {
                    targetCard
                    mapCard
                    routeTypeCard
                    summaryCard
                    if let route = model.builtRoute {
                        resultCard(route)
                    }
                    if let error = model.buildError {
                        errorCard(error)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
            }

            ctaRow
        }
        .background(Theme.background.ignoresSafeArea())
        .sheet(isPresented: $showCustomize) {
            CustomizeSheet(initialSection: customizeSection)
                .environmentObject(model)
        }
        .sheet(isPresented: $showCustomTarget) {
            customTargetSheet
                .presentationDetents([.height(240)])
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Build")
                .font(.largeTitle.bold())
            Spacer()
            Text("Ready when you are.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Target card

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                CardCaption(model.targetKind == .time ? "Time available" : "Target distance")
                Spacer()
                if model.buildMode == .manual {
                    Text("Tap one to switch back to auto")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                } else {
                    Button {
                        model.targetKind = model.targetKind == .time ? .distance : .time
                    } label: {
                        Image(systemName: model.targetKind == .time ? "ruler" : "clock")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.denim)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if model.targetKind == .time {
                        ForEach(minuteChoices, id: \.self) { minutes in
                            SelectableChip(
                                label: "\(Int(minutes)) min",
                                selected: model.buildMode == .auto && model.targetMinutes == minutes,
                                dimmed: model.buildMode == .manual
                            ) {
                                model.selectMinutes(minutes)
                            }
                        }
                    } else {
                        ForEach(mileChoices, id: \.self) { miles in
                            SelectableChip(
                                label: miles == 1 ? "1 mile" : "\(Int(miles)) miles",
                                selected: model.buildMode == .auto && model.targetMiles == miles,
                                dimmed: model.buildMode == .manual
                            ) {
                                model.selectMiles(miles)
                            }
                        }
                    }
                    SelectableChip(
                        label: "Custom",
                        selected: isCustomTargetSelected,
                        dimmed: model.buildMode == .manual
                    ) {
                        customTargetText = ""
                        showCustomTarget = true
                    }
                }
            }
        }
        .card()
    }

    private var isCustomTargetSelected: Bool {
        guard model.buildMode == .auto else { return false }
        switch model.targetKind {
        case .time: return !minuteChoices.contains(model.targetMinutes)
        case .distance: return !mileChoices.contains(model.targetMiles)
        }
    }

    // MARK: - Map card

    private var mapCard: some View {
        MapCanvasView(allowsPinEditing: true)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .topLeading) {
                modeChip.padding(10)
            }
            .overlay(alignment: .topTrailing) {
                if !model.manualPins.isEmpty {
                    Button {
                        withAnimation(.snappy) { model.clearPins() }
                    } label: {
                        Label("Clear pins", systemImage: "xmark")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                    }
                    .padding(10)
                }
            }
            .overlay(alignment: .bottom) {
                if model.buildMode == .auto && model.manualPins.isEmpty && model.builtRoute == nil {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.caption.weight(.semibold))
                        Text("Tap anywhere to place your own pins")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Capsule())
                    .padding(.bottom, 12)
                }
            }
            .shadow(color: Theme.cardShadow, radius: 8, y: 2)
    }

    private var modeChip: some View {
        let isAuto = model.buildMode == .auto
        return HStack(spacing: 6) {
            Image(systemName: isAuto ? "wand.and.stars" : "hand.tap.fill")
                .font(.system(size: 11, weight: .bold))
            Text(modeText)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.6)
        }
        .foregroundStyle(isAuto ? Theme.onAccent : .white)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(isAuto ? Theme.denim : Color.black.opacity(0.7))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }

    private var modeText: String {
        switch model.buildMode {
        case .auto:
            switch model.targetKind {
            case .time: return "AUTO · \(Int(model.targetMinutes)) MIN"
            case .distance: return "AUTO · \(trimmed(model.targetMiles)) MI"
            }
        case .manual:
            let count = model.manualPins.count
            return "MANUAL · \(count) \(count == 1 ? "PIN" : "PINS")"
        }
    }

    // MARK: - Route type card

    private var routeTypeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardCaption("Route type")
            HStack(spacing: 8) {
                routeTypeChip(.oneWay, title: "One-way", icon: "arrow.up.forward")
                routeTypeChip(.outAndBack, title: "Out & back", icon: "arrow.left.and.right")
                routeTypeChip(.loop, title: "Loop", icon: "arrow.triangle.2.circlepath")
            }
        }
        .card()
    }

    private func routeTypeChip(_ type: RouteConfig.RouteType, title: String, icon: String) -> some View {
        let selected = model.routeType == type
        return Button {
            model.routeType = type
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? Theme.denim : Theme.surfaceHi)
            .foregroundStyle(selected ? Theme.onAccent : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                CardCaption("Your setup")
                Spacer()
                if model.buildMode == .auto {
                    Text("≈ \(trimmed(model.expectedMiles)) mi")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.denim)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    summaryChip(icon: "figure.run", text: model.paceMixSummary, section: .paceMix)
                    summaryChip(icon: "location.north.line", text: model.directionSummary, section: .direction)
                    summaryChip(
                        icon: model.isScenic ? "leaf" : "bolt",
                        text: model.isScenic ? "Scenic" : "Fastest",
                        section: .routeStyle
                    )
                    if model.pulseCount > 1 {
                        summaryChip(icon: "repeat", text: "Pulse \(model.pulseCount)×", section: .pulse)
                    }
                    if model.routeType == .loop {
                        summaryChip(icon: "point.3.connected.trianglepath.dotted",
                                    text: "\(model.loopPointCount) points", section: .loopPoints)
                    }
                }
            }

            Text("Tap a chip to fine-tune just that setting.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .card()
    }

    private func summaryChip(icon: String, text: String, section: CustomizeSection) -> some View {
        Button {
            customizeSection = section
            showCustomize = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.denim)
                Text(text)
                    .font(.caption.weight(.semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Theme.surfaceHi)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Result card

    private func resultCard(_ route: BuiltRoute) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CardCaption("Route ready")
                Spacer()
                if model.routeSaved {
                    Label("Saved", systemImage: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.sun)
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.1f", route.totalMiles))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("miles")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("~\(Int(route.estimatedMinutes.rounded()))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            paceLegend(route)

            HStack(spacing: 10) {
                Button {
                    model.saveCurrentRoute()
                } label: {
                    Label(model.routeSaved ? "Saved" : "Save route",
                          systemImage: model.routeSaved ? "checkmark" : "bookmark")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.surfaceHi)
                        .foregroundStyle(model.routeSaved ? .secondary : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(model.routeSaved)

                Button {
                    model.selectedTab = .active
                } label: {
                    Label("Start", systemImage: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.denim)
                        .foregroundStyle(Theme.onAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .card()
    }

    private func paceLegend(_ route: BuiltRoute) -> some View {
        let paces = route.paceSegments.reduce(into: [PaceType]()) { list, segment in
            if !list.contains(segment.paceType) { list.append(segment.paceType) }
        }
        return HStack(spacing: 14) {
            ForEach(paces, id: \.rawValue) { pace in
                Label {
                    Text(pace.rawValue).font(.caption.weight(.medium))
                } icon: {
                    Circle().fill(Theme.color(for: pace)).frame(width: 8, height: 8)
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Error card

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.sun)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .card()
    }

    // MARK: - CTA row

    private var ctaRow: some View {
        HStack(spacing: 10) {
            Button {
                customizeSection = nil
                showCustomize = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold))
                    Text("Customize")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(Theme.denim)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.denim.opacity(0.6), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 150)

            Button {
                Task { await model.build() }
            } label: {
                HStack(spacing: 8) {
                    if model.isBuilding {
                        ProgressView().tint(Theme.onAccent)
                        Text("Building…")
                    } else {
                        Text(model.buildMode == .manual ? "Build from pins" : "Build my route")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.denim.opacity(model.isBuilding ? 0.6 : 1))
                .foregroundStyle(Theme.onAccent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(model.isBuilding)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Theme.background)
    }

    // MARK: - Custom target entry

    private var customTargetSheet: some View {
        VStack(spacing: 16) {
            Text(model.targetKind == .time ? "How many minutes?" : "How many miles?")
                .font(.headline)
                .padding(.top, 20)

            TextField(model.targetKind == .time ? "e.g. 25" : "e.g. 2.5", text: $customTargetText)
                .keyboardType(.decimalPad)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .background(Theme.surfaceHi)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 24)

            Button {
                if let value = Double(customTargetText), value > 0 {
                    if model.targetKind == .time {
                        model.selectMinutes(min(value, 600))
                    } else {
                        model.selectMiles(min(value, 50))
                    }
                }
                showCustomTarget = false
            } label: {
                Text("Set target")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.denim)
                    .foregroundStyle(Theme.onAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Theme.background)
    }

    // MARK: - Formatting

    private func trimmed(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }
}

#Preview {
    RootTabView()
}
