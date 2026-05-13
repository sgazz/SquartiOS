import SwiftUI

enum SquartTheme {
    static let themeTransitionDuration: Double = 0.36
    static let themeTransitionAnimation = Animation.easeInOut(duration: themeTransitionDuration)
    static let microInteractionAnimation = Animation.spring(response: 0.22, dampingFraction: 0.86)

    enum Colors {
        static let backgroundTop = Color(red: 0.07, green: 0.07, blue: 0.07)
        static let backgroundMid = Color(red: 0.12, green: 0.11, blue: 0.10)
        static let backgroundBottom = Color(red: 0.05, green: 0.05, blue: 0.05)
        static let sheetBackground = Color(red: 0.06, green: 0.055, blue: 0.05)
        static let panelGraphite = Color.white.opacity(0.055)
        static let subtlePanelGraphite = Color.white.opacity(0.045)
        static let borderGraphite = Color.white.opacity(0.09)
        static let subtleBorderGraphite = Color.white.opacity(0.08)
        static let primaryText = Color.white.opacity(0.94)
        static let strongText = Color.white.opacity(0.90)
        static let bodyText = Color.white.opacity(0.76)
        static let mutedText = Color.white.opacity(0.58)
        static let quietText = Color.white.opacity(0.42)
        static let cappuccino = Color(red: 0.78, green: 0.66, blue: 0.52)
        static let bronze = Color(red: 0.58, green: 0.43, blue: 0.30)
        static let ink = Color(red: 0.16, green: 0.12, blue: 0.09)
        static let steel = Color(red: 0.58, green: 0.68, blue: 0.70)
    }

    enum Radius {
        static let small: CGFloat = 8
        static let overlay: CGFloat = 18
        static let logo: CGFloat = 26
    }

    enum Spacing {
        static let screenPadding: CGFloat = 32
        static let sheetPadding: CGFloat = 28
        static let cardPadding: CGFloat = 18
    }

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [
                Colors.backgroundTop,
                Colors.backgroundMid,
                Colors.backgroundBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func titleFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
}

private struct SquartPaletteKey: EnvironmentKey {
    static let defaultValue = SquartVisualTheme.defaultTheme.palette
}

extension EnvironmentValues {
    var squartPalette: SquartThemePalette {
        get { self[SquartPaletteKey.self] }
        set { self[SquartPaletteKey.self] = newValue }
    }
}
