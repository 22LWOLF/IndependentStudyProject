//
//  Theme.swift
//  MapApp
//
//  Single source of truth for the StepOut visual system: denim blue + sun
//  yellow, adaptive light/dark. Change a color here and the whole app follows.
//

import SwiftUI
import UIKit

extension Color {
    /// A color that resolves differently in light and dark mode.
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

enum Theme {

    // MARK: - Brand

    /// Primary accent — denim blue.
    static let denim = Color(uiColor: denimUI)
    static let denimUI = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.55, green: 0.70, blue: 0.95, alpha: 1)
            : UIColor(red: 0.20, green: 0.36, blue: 0.60, alpha: 1)
    }

    /// Secondary accent — sun yellow. Used sparingly: favorites, live badges, highlights.
    static let sun = Color(
        light: UIColor(red: 0.94, green: 0.72, blue: 0.20, alpha: 1),
        dark:  UIColor(red: 0.97, green: 0.79, blue: 0.35, alpha: 1)
    )

    /// Text/icon color that sits on top of a denim (or sun) fill.
    static let onAccent = Color(
        light: .white,
        dark:  UIColor(red: 0.07, green: 0.09, blue: 0.13, alpha: 1)
    )

    static var denimSoft: Color { denim.opacity(0.14) }
    static var sunSoft: Color { sun.opacity(0.18) }

    // MARK: - Surfaces

    static let background = Color(
        light: UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1),
        dark:  UIColor(red: 0.06, green: 0.07, blue: 0.10, alpha: 1)
    )
    static let surface = Color(
        light: .white,
        dark:  UIColor(red: 0.11, green: 0.13, blue: 0.17, alpha: 1)
    )
    /// Raised fills inside cards: chips, wells, steppers.
    static let surfaceHi = Color(
        light: UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1),
        dark:  UIColor(red: 0.17, green: 0.19, blue: 0.24, alpha: 1)
    )

    static let cardShadow = Color.black.opacity(0.07)

    // MARK: - Status

    static let danger = Color(
        light: UIColor(red: 0.83, green: 0.29, blue: 0.27, alpha: 1),
        dark:  UIColor(red: 0.93, green: 0.45, blue: 0.43, alpha: 1)
    )

    // MARK: - Pace colors

    static let walk = Color(uiColor: walkUI)
    static let jog  = Color(uiColor: jogUI)
    static let run  = Color(uiColor: runUI)

    static func color(for pace: PaceType) -> Color {
        Color(uiColor: uiColor(for: pace))
    }

    /// UIKit variants for MapKit renderers.
    static func uiColor(for pace: PaceType) -> UIColor {
        switch pace {
        case .walk: return walkUI
        case .jog:  return jogUI
        case .run:  return runUI
        }
    }

    private static let walkUI = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.36, green: 0.78, blue: 0.60, alpha: 1)
            : UIColor(red: 0.20, green: 0.60, blue: 0.44, alpha: 1)
    }
    private static let jogUI = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.97, green: 0.72, blue: 0.30, alpha: 1)
            : UIColor(red: 0.90, green: 0.60, blue: 0.14, alpha: 1)
    }
    private static let runUI = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.94, green: 0.46, blue: 0.44, alpha: 1)
            : UIColor(red: 0.82, green: 0.29, blue: 0.28, alpha: 1)
    }
}

// MARK: - Shared building blocks

/// Standard card container used across all tabs.
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Theme.cardShadow, radius: 8, y: 2)
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View { modifier(CardStyle(padding: padding)) }
}

/// Capsule chip used for time, distance, route type and setting choices.
struct SelectableChip: View {
    let label: String
    var icon: String? = nil
    let selected: Bool
    var dimmed: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).font(.caption.weight(.bold))
                }
                Text(label).font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selected ? Theme.denim : Theme.surfaceHi)
            .foregroundStyle(selected ? Theme.onAccent : .primary)
            .clipShape(Capsule())
            .opacity(dimmed ? 0.4 : 1)
        }
        .buttonStyle(.plain)
    }
}

/// Small uppercase section caption inside cards.
struct CardCaption: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
    }
}

extension PaceType {
    var symbolName: String {
        switch self {
        case .walk: return "tortoise.fill"
        case .jog:  return "figure.run"
        case .run:  return "hare.fill"
        }
    }
}
