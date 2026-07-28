//
//  FeedbackManager.swift
//  MapApp
//
//  Voice and haptic feedback for live routes. Respects the toggles on the
//  You tab ("voiceGuidanceEnabled" / "hapticsEnabled", default on).
//

import AVFoundation
import CoreLocation
import UIKit

@MainActor
final class FeedbackManager {
    static let shared = FeedbackManager()

    private let synthesizer = AVSpeechSynthesizer()
    private let impact = UIImpactFeedbackGenerator(style: .heavy)
    private let notify = UINotificationFeedbackGenerator()

    private var voiceEnabled: Bool {
        UserDefaults.standard.object(forKey: "voiceGuidanceEnabled") as? Bool ?? true
    }
    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback, mode: .spokenAudio, options: [.duckOthers]
        )
    }

    // MARK: - Session lifecycle

    func sessionBegan() {
        if voiceEnabled {
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        tap()
        speak("Route started.")
    }

    func sessionEnded(completed: Bool) {
        if completed {
            speak("Route complete. Nice work!")
            if hapticsEnabled { notify.notificationOccurred(.success) }
        } else {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Give the last utterance a beat before releasing audio.
        Task {
            try? await Task.sleep(for: .seconds(3))
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    // MARK: - Events

    func paceChanged(to pace: PaceType) {
        doubleTap()
        switch pace {
        case .walk: speak("Slow to a walk.")
        case .jog:  speak("Pick it up to a jog.")
        case .run:  speak("Time to run!")
        }
    }

    func announceCue(_ instruction: String, metersAway: CLLocationDistance) {
        let feet = Int((metersAway * 3.28084 / 10).rounded() * 10)
        if feet >= 40 {
            speak("In \(feet) feet, \(lowercasedFirst(instruction))")
        } else {
            speak(instruction)
        }
    }

    // MARK: - Primitives

    private func speak(_ text: String) {
        guard voiceEnabled else { return }
        synthesizer.speak(AVSpeechUtterance(string: text))
    }

    private func tap() {
        guard hapticsEnabled else { return }
        impact.impactOccurred()
    }

    private func doubleTap() {
        guard hapticsEnabled else { return }
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [impact] in
            impact.impactOccurred()
        }
    }

    private func lowercasedFirst(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.lowercased() + text.dropFirst()
    }
}
