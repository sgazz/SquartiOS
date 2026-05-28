import SwiftUI

struct SquartPrimaryButtonStyle: ButtonStyle {
    @Environment(\.squartPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var width: CGFloat = 178
    var height: CGFloat = 52

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(palette.buttonText)
            .frame(width: width, height: height)
            .background(
                Capsule()
                    .fill(palette.accent)
                    .shadow(
                        color: palette.accent.opacity(configuration.isPressed ? 0.10 : 0.18),
                        radius: configuration.isPressed ? 10 : 18
                    )
            )
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .brightness(configuration.isPressed ? -0.018 : 0)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(reduceMotion ? nil : SquartTheme.microInteractionAnimation, value: configuration.isPressed)
    }
}

struct SquartSecondaryButtonStyle: ButtonStyle {
    @Environment(\.squartPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var width: CGFloat = 112
    var height: CGFloat = 52
    var foreground: Color?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(foreground ?? palette.segmentedText)
            .frame(width: width, height: height)
            .background(
                Capsule()
                    .stroke(palette.controlBorder, lineWidth: 1)
                    .background(Capsule().fill(palette.segmentedBackground))
            )
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .brightness(configuration.isPressed ? -0.012 : 0)
            .opacity(configuration.isPressed ? 0.78 : 1)
            .animation(reduceMotion ? nil : SquartTheme.microInteractionAnimation, value: configuration.isPressed)
    }
}

struct SquartTactileButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var pressedScale: CGFloat = 0.985
    var pressedOpacity: Double = 0.84
    var pressedBrightness: Double = -0.012

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? pressedScale : 1)
            .brightness(configuration.isPressed ? pressedBrightness : 0)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .animation(reduceMotion ? nil : SquartTheme.microInteractionAnimation, value: configuration.isPressed)
    }
}
