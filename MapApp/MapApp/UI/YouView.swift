//
//  YouView.swift
//  MapApp
//
//  Personal tab: learned pace speeds, feedback preferences, and app info.
//

import SwiftUI

struct YouView: View {
    @EnvironmentObject private var model: AppModel

    @AppStorage("voiceGuidanceEnabled") private var voiceGuidance = true
    @AppStorage("hapticsEnabled") private var haptics = true

    /// Bumped after a reset so the speed rows re-read the store.
    @State private var speedsVersion = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(PaceType.allCases, id: \.rawValue) { pace in
                        speedRow(pace)
                    }
                } header: {
                    Text("Your speeds")
                } footer: {
                    Text("StepOut learns these from your real outings — estimates get sharper the more you go.")
                }

                Section("Feedback") {
                    Toggle("Voice guidance", isOn: $voiceGuidance)
                        .tint(Theme.denim)
                    Toggle("Haptic pace alerts", isOn: $haptics)
                        .tint(Theme.denim)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0 β")
                    Link(destination: URL(string: "mailto:22lwolfee@gmail.com")!) {
                        Label("Contact support", systemImage: "envelope")
                            .foregroundStyle(Theme.denim)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("You")
        }
    }

    private func speedRow(_ pace: PaceType) -> some View {
        let mph = model.speedStore.learnedSpeed(for: pace) * 2.23694
        let samples = sampleCount(for: pace)

        return HStack(spacing: 12) {
            Image(systemName: pace.symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.color(for: pace))
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(pace.rawValue)
                    .font(.subheadline.weight(.medium))
                Text(samples >= 10 ? "\(samples) samples" : "Default until 10 samples")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(String(format: "%.1f mph", mph))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()

            Button("Reset") {
                model.speedStore.reset(pace)
                speedsVersion += 1
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
            .tint(Theme.denim)
        }
    }

    private func sampleCount(for pace: PaceType) -> Int {
        // speedsVersion is read so rows refresh after a reset.
        _ = speedsVersion
        switch pace {
        case .walk: return model.speedStore.walkSampleCount
        case .jog:  return model.speedStore.jogSampleCount
        case .run:  return model.speedStore.runSampleCount
        }
    }
}

#Preview {
    RootTabView()
}
