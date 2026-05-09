import SwiftUI

struct SquartPrimaryButtonStyle: ButtonStyle {
    var width: CGFloat = 178
    var height: CGFloat = 52

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(SquartTheme.Colors.ink)
            .frame(width: width, height: height)
            .background(
                Capsule()
                    .fill(SquartTheme.Colors.cappuccino)
                    .shadow(
                        color: SquartTheme.Colors.cappuccino.opacity(configuration.isPressed ? 0.10 : 0.18),
                        radius: configuration.isPressed ? 10 : 18
                    )
            )
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

struct SquartSecondaryButtonStyle: ButtonStyle {
    var width: CGFloat = 112
    var height: CGFloat = 52
    var foreground: Color = Color.white.opacity(0.82)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(foreground)
            .frame(width: width, height: height)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    .background(Capsule().fill(SquartTheme.Colors.subtlePanelGraphite))
            )
            .opacity(configuration.isPressed ? 0.78 : 1)
    }
}
