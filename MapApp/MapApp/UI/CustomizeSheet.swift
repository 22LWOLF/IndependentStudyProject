//
//  CustomizeSheet.swift
//  MapApp
//
//  The deep-settings sheet, reached from Build. Every setting is a collapsed
//  row showing its current value; expanding one reveals just that control, so
//  the full wall of options never appears at once.
//

import SwiftUI

enum CustomizeSection: String, CaseIterable, Identifiable {
    case target, routeStyle, direction, paceMix, paceOrder, pulse, loopPoints

    var id: String { rawValue }

    var title: String {
        switch self {
        case .target:     return "Target type"
        case .routeStyle: return "Route style"
        case .direction:  return "Direction"
        case .paceMix:    return "Pace mix"
        case .paceOrder:  return "Pace order"
        case .pulse:      return "Pulse mode"
        case .loopPoints: return "Loop points"
        }
    }

    var icon: String {
        switch self {
        case .target:     return "target"
        case .routeStyle: return "bolt"
        case .direction:  return "location.north.line"
        case .paceMix:    return "figure.run"
        case .paceOrder:  return "arrow.left.arrow.right"
        case .pulse:      return "repeat"
        case .loopPoints: return "point.3.connected.trianglepath.dotted"
        }
    }
}

struct CustomizeSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var initialSection: CustomizeSection?

    @State private var expanded: CustomizeSection?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(CustomizeSection.allCases) { section in
                        sectionCard(section)
                    }
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Customize route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.headline)
                        .tint(Theme.denim)
                }
            }
            .onAppear { expanded = initialSection }
        }
    }

    // MARK: - Section shell

    private func sectionCard(_ section: CustomizeSection) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) {
                    expanded = expanded == section ? nil : section
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: section.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.denim)
                        .frame(width: 26)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(summary(for: section))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(expanded == section ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded == section {
                Divider().padding(.vertical, 12)
                content(for: section)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func summary(for section: CustomizeSection) -> String {
        switch section {
        case .target:
            return model.targetKind == .time
                ? "\(Int(model.targetMinutes)) minutes"
                : String(format: "%.1f miles", model.targetMiles)
        case .routeStyle:
            return model.isScenic ? "Scenic" : "Fastest"
        case .direction:
            return model.directionSummary
        case .paceMix:
            return model.paceMixSummary
        case .paceOrder:
            return model.paceOrder.map(\.rawValue).joined(separator: " → ")
        case .pulse:
            return model.pulseCount == 1 ? "Off" : "\(model.pulseCount)× repeat"
        case .loopPoints:
            return "\(model.loopPointCount) waypoints"
        }
    }

    // MARK: - Section content

    @ViewBuilder
    private func content(for section: CustomizeSection) -> some View {
        switch section {
        case .target:     targetContent
        case .routeStyle: routeStyleContent
        case .direction:  directionContent
        case .paceMix:    paceMixContent
        case .paceOrder:  paceOrderContent
        case .pulse:      pulseContent
        case .loopPoints: loopPointsContent
        }
    }

    private var targetContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                SelectableChip(label: "Time", icon: "clock.fill",
                               selected: model.targetKind == .time) {
                    model.targetKind = .time
                }
                SelectableChip(label: "Distance", icon: "ruler.fill",
                               selected: model.targetKind == .distance) {
                    model.targetKind = .distance
                }
            }

            if model.targetKind == .time {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Int(model.targetMinutes)) minutes")
                        .font(.subheadline.weight(.bold))
                    Slider(value: $model.targetMinutes, in: 10...120, step: 5)
                        .tint(Theme.denim)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(format: "%.2f miles", model.targetMiles))
                        .font(.subheadline.weight(.bold))
                    Slider(value: $model.targetMiles, in: 0.5...10, step: 0.25)
                        .tint(Theme.denim)
                }
            }

            Text(model.targetKind == .time
                 ? "Route length adapts to your pace mix and learned speeds."
                 : "Builds a route close to this mileage.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var routeStyleContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                SelectableChip(label: "Fastest", icon: "bolt.fill",
                               selected: !model.isScenic) {
                    model.isScenic = false
                }
                SelectableChip(label: "Scenic", icon: "leaf.fill",
                               selected: model.isScenic) {
                    model.isScenic = true
                }
            }
            Text(model.isScenic
                 ? "Prefers longer or more interesting paths when available."
                 : "Direct paths between waypoints.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var directionContent: some View {
        let grid: [[String?]] = [
            ["NW", "N", "NE"],
            ["W",  nil, "E"],
            ["SW", "S", "SE"]
        ]
        return VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { col in
                        directionCell(grid[row][col])
                    }
                }
            }
            Text(model.direction.map { "Routes will head roughly \($0) from your start." }
                 ?? "Any direction — the dice decide.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func directionCell(_ label: String?) -> some View {
        let isRandom = label == nil
        let selected = isRandom ? model.direction == nil : model.direction == label
        return Button {
            model.direction = isRandom ? nil : label
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? Theme.denim : Theme.surfaceHi)
                if let label {
                    Text(label).font(.subheadline.weight(.bold))
                } else {
                    Image(systemName: "die.face.5.fill")
                        .font(.subheadline.weight(.bold))
                }
            }
            .frame(height: 46)
            .foregroundStyle(selected ? Theme.onAccent : .primary)
        }
        .buttonStyle(.plain)
    }

    private var paceMixContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(PaceType.allCases, id: \.rawValue) { pace in
                paceSliderRow(pace)
            }

            HStack(spacing: 8) {
                Button {
                    withAnimation(.snappy) { model.randomizeShares() }
                } label: {
                    Label("Randomize", systemImage: "dice.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.surfaceHi)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.snappy) { model.resetShares() }
                } label: {
                    Label("Reset", systemImage: "arrow.uturn.backward")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.surfaceHi)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Text("Sliders auto-balance so the mix always totals 100%.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func paceSliderRow(_ pace: PaceType) -> some View {
        let share = Binding<Double>(
            get: { model.paceShares[pace] ?? 0 },
            set: { model.setShare(pace, to: $0) }
        )
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: pace.symbolName)
                    .font(.footnote)
                    .foregroundStyle(Theme.color(for: pace))
                Text(pace.rawValue)
                    .font(.footnote.weight(.semibold))
                Spacer()
                Text("\(Int((share.wrappedValue * 100).rounded()))%")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: share, in: 0...1)
                .tint(Theme.color(for: pace))
        }
    }

    private var paceOrderContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ForEach(model.paceOrder, id: \.rawValue) { pace in
                    Button {
                        withAnimation(.snappy) { model.promotePace(pace) }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: pace.symbolName)
                                .font(.caption2)
                                .foregroundStyle(Theme.color(for: pace))
                            Text(pace.rawValue)
                                .font(.caption.weight(.semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.surfaceHi)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            Text("Tap a pace to move it earlier in the route.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var pulseContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ForEach([1, 2, 3, 4, 6, 8], id: \.self) { count in
                    SelectableChip(
                        label: count == 1 ? "Off" : "\(count)×",
                        selected: model.pulseCount == count
                    ) {
                        model.pulseCount = count
                    }
                }
            }
            Text(model.pulseCount == 1
                 ? "Each pace appears once in a single block."
                 : "Repeats your pace pattern \(model.pulseCount) times across the route.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var loopPointsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(model.loopPointCount) waypoints")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                HStack(spacing: 0) {
                    Button {
                        if model.loopPointCount > 3 { model.loopPointCount -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 40, height: 34)
                            .background(Theme.surfaceHi)
                    }
                    .buttonStyle(.plain)

                    Text("\(model.loopPointCount)")
                        .font(.subheadline.weight(.bold))
                        .frame(width: 36, height: 34)
                        .monospacedDigit()

                    Button {
                        if model.loopPointCount < 8 { model.loopPointCount += 1 }
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 40, height: 34)
                            .background(Theme.surfaceHi)
                    }
                    .buttonStyle(.plain)
                }
                .clipShape(Capsule())
            }
            Text(model.routeType == .loop
                 ? "More points make rounder, more varied loops."
                 : "Only applies to Loop routes.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CustomizeSheet(initialSection: nil)
        .environmentObject(AppModel())
}
