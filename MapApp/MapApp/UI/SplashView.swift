//
//  SplashView.swift
//  MapApp
//
//  Launch animation: a sun dot appears (you), a denim route draws itself out
//  (the app working), a pin drops onto the end (destination), and the wordmark
//  fades in — then the whole thing dissolves into the Build tab.
//
//  The static LaunchScreen.storyboard uses the same background color, so the
//  OS launch frame hands off to this view invisibly. Plays once per cold
//  launch; honors Reduce Motion by skipping straight to a composed frame.
//

import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var dotVisible = false
    @State private var routeProgress: CGFloat = 0
    @State private var pinVisible = false
    @State private var textVisible = false
    @State private var fadeOut = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            canvas
                .frame(width: 280, height: 560)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(fadeOut ? 0 : 1)
        .onAppear(perform: run)
    }

    // MARK: - Composition (designed in a fixed 280×560 space)

    private var canvas: some View {
        ZStack {
            SplashRouteShape()
                .trim(from: 0, to: routeProgress)
                .stroke(
                    Theme.denim,
                    style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round)
                )

            Circle()
                .fill(Theme.sun)
                .frame(width: 18, height: 18)
                .scaleEffect(dotVisible ? 1 : 0.01)
                .position(x: 96, y: 396)

            pin
                .position(x: 214, y: 126)

            VStack(spacing: 6) {
                Text("StepOut")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Ready when you are.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .opacity(textVisible ? 1 : 0)
            .offset(y: textVisible ? 0 : 14)
            .position(x: 140, y: 470)
        }
        .frame(width: 280, height: 560)
    }

    private var pin: some View {
        ZStack {
            SplashPinShape()
                .fill(Theme.denim)
            Circle()
                .fill(Theme.sun)
                .frame(width: 16, height: 16)
                .offset(y: -8)
        }
        .frame(width: 48, height: 60)
        .scaleEffect(pinVisible ? 1 : 0.3, anchor: .bottom)
        .offset(y: pinVisible ? 0 : -70)
        .opacity(pinVisible ? 1 : 0)
    }

    // MARK: - Sequence

    private func run() {
        guard !reduceMotion else {
            dotVisible = true
            routeProgress = 1
            pinVisible = true
            textVisible = true
            finish(after: 1.4)
            return
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.6).delay(0.25)) {
            dotVisible = true
        }
        withAnimation(.easeInOut(duration: 1.1).delay(0.35)) {
            routeProgress = 1
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(1.35)) {
            pinVisible = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(1.6)) {
            textVisible = true
        }
        finish(after: 2.5)
    }

    private func finish(after delay: TimeInterval) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(delay))
            withAnimation(.easeOut(duration: 0.45)) { fadeOut = true }
            try? await Task.sleep(for: .seconds(0.5))
            onFinished()
        }
    }
}

// MARK: - Shapes

/// The S-curve route line, in the splash's 280×560 design space.
private struct SplashRouteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 96, y: 396))
        p.addCurve(
            to: CGPoint(x: 152, y: 284),
            control1: CGPoint(x: 150, y: 370),
            control2: CGPoint(x: 118, y: 320)
        )
        p.addCurve(
            to: CGPoint(x: 190, y: 178),
            control1: CGPoint(x: 186, y: 248),
            control2: CGPoint(x: 158, y: 210)
        )
        p.addCurve(
            to: CGPoint(x: 214, y: 132),
            control1: CGPoint(x: 210, y: 158),
            control2: CGPoint(x: 212, y: 144)
        )
        return p
    }
}

/// Classic teardrop map pin, drawn in its local rect.
private struct SplashPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 48
        var p = Path()
        p.move(to: CGPoint(x: 24 * s, y: 0))
        p.addCurve(
            to: CGPoint(x: 0, y: 23 * s),
            control1: CGPoint(x: 10 * s, y: 0),
            control2: CGPoint(x: 0, y: 10 * s)
        )
        p.addCurve(
            to: CGPoint(x: 24 * s, y: 60 * s),
            control1: CGPoint(x: 0, y: 36 * s),
            control2: CGPoint(x: 12 * s, y: 44 * s)
        )
        p.addCurve(
            to: CGPoint(x: 48 * s, y: 23 * s),
            control1: CGPoint(x: 36 * s, y: 44 * s),
            control2: CGPoint(x: 48 * s, y: 36 * s)
        )
        p.addCurve(
            to: CGPoint(x: 24 * s, y: 0),
            control1: CGPoint(x: 48 * s, y: 10 * s),
            control2: CGPoint(x: 38 * s, y: 0)
        )
        p.closeSubpath()
        return p
    }
}

#Preview {
    SplashView(onFinished: {})
}
