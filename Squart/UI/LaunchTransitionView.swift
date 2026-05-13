import SwiftUI

struct LaunchTransitionView<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: LaunchTransitionPhase = .intro
    @ViewBuilder let content: Content

    private let palette = SquartThemeStore.shared.loadSelectedTheme(access: .free).palette

    var body: some View {
        ZStack {
            content
                .environment(\.squartPalette, palette)
                .opacity(phase == .content ? 1 : 0)
                .scaleEffect(phase == .content ? 1 : 0.985)

            if phase != .content {
                IntroLayer(phase: phase, palette: palette)
                    .transition(.opacity)
            }
        }
        .background(palette.appBackground.ignoresSafeArea())
        .task {
            await playIntro()
        }
    }

    private func playIntro() async {
        guard !reduceMotion else {
            phase = .content
            return
        }

        withAnimation(.easeOut(duration: 0.42)) {
            phase = .mark
        }

        try? await Task.sleep(for: .milliseconds(520))

        withAnimation(.easeInOut(duration: 0.36)) {
            phase = .title
        }

        try? await Task.sleep(for: .milliseconds(620))

        withAnimation(.easeInOut(duration: 0.34)) {
            phase = .content
        }
    }
}

private enum LaunchTransitionPhase {
    case intro
    case mark
    case title
    case content
}

private struct IntroLayer: View {
    let phase: LaunchTransitionPhase
    let palette: SquartThemePalette

    var body: some View {
        ZStack {
            palette.appBackground
                .ignoresSafeArea()

            VStack(spacing: 22) {
                SquartLogoView()
                    .frame(width: 112, height: 112)
                    .scaleEffect(phase == .intro ? 0.92 : 1)
                    .opacity(phase == .intro ? 0 : 1)
                    .blur(radius: phase == .intro ? 8 : 0)

                VStack(spacing: 8) {
                    Text("Squart")
                        .font(SquartTheme.titleFont(size: 36))
                        .foregroundStyle(palette.primaryText)

                    Text("A quiet tactical game of space, direction, and denial.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(maxWidth: 300)
                }
                .opacity(phase == .title ? 1 : 0)
                .offset(y: phase == .title ? 0 : 8)
            }
            .padding(32)
        }
        .environment(\.squartPalette, palette)
    }
}

#Preview {
    LaunchTransitionView {
        RootView()
    }
}
