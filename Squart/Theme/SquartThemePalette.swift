import SwiftUI

struct SquartThemePalette {
    let backgroundTop: Color
    let backgroundMid: Color
    let backgroundBottom: Color
    let sheetBackground: Color
    let panel: Color
    let subtlePanel: Color
    let border: Color
    let subtleBorder: Color
    let primaryText: Color
    let strongText: Color
    let bodyText: Color
    let mutedText: Color
    let quietText: Color
    let accent: Color
    let secondaryAccent: Color
    let buttonText: Color
    let coolAccent: Color
    let segmentedBackground: Color
    let segmentedSelectedBackground: Color
    let segmentedText: Color
    let segmentedSelectedText: Color
    let disabledText: Color
    let controlBorder: Color
    let segmentedColorScheme: ColorScheme
    let blockerCell: Color
    let blockerCellBorder: Color

    var appBackground: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundMid, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension SquartVisualTheme {
    var palette: SquartThemePalette {
        switch self {
        case .cappuccino:
            return SquartThemePalette(
                backgroundTop: Color(red: 0.07, green: 0.07, blue: 0.07),
                backgroundMid: Color(red: 0.12, green: 0.11, blue: 0.10),
                backgroundBottom: Color(red: 0.05, green: 0.05, blue: 0.05),
                sheetBackground: Color(red: 0.06, green: 0.055, blue: 0.05),
                panel: Color.white.opacity(0.055),
                subtlePanel: Color.white.opacity(0.045),
                border: Color.white.opacity(0.09),
                subtleBorder: Color.white.opacity(0.08),
                primaryText: Color.white.opacity(0.94),
                strongText: Color.white.opacity(0.90),
                bodyText: Color.white.opacity(0.76),
                mutedText: Color.white.opacity(0.58),
                quietText: Color.white.opacity(0.42),
                accent: Color(red: 0.78, green: 0.66, blue: 0.52),
                secondaryAccent: Color(red: 0.58, green: 0.43, blue: 0.30),
                buttonText: Color(red: 0.16, green: 0.12, blue: 0.09),
                coolAccent: Color(red: 0.58, green: 0.68, blue: 0.70),
                segmentedBackground: Color.white.opacity(0.07),
                segmentedSelectedBackground: Color(red: 0.78, green: 0.66, blue: 0.52),
                segmentedText: Color.white.opacity(0.84),
                segmentedSelectedText: Color(red: 0.14, green: 0.10, blue: 0.08),
                disabledText: Color.white.opacity(0.46),
                controlBorder: Color.white.opacity(0.16),
                segmentedColorScheme: .dark,
                blockerCell: Color(red: 0.26, green: 0.24, blue: 0.23),
                blockerCellBorder: Color(red: 0.38, green: 0.35, blue: 0.33).opacity(0.72)
            )
        case .obsidian:
            return SquartThemePalette(
                backgroundTop: Color(red: 0.018, green: 0.020, blue: 0.023),
                backgroundMid: Color(red: 0.040, green: 0.045, blue: 0.050),
                backgroundBottom: Color(red: 0.010, green: 0.012, blue: 0.014),
                sheetBackground: Color(red: 0.020, green: 0.023, blue: 0.026),
                panel: Color.white.opacity(0.060),
                subtlePanel: Color.white.opacity(0.044),
                border: Color.white.opacity(0.105),
                subtleBorder: Color.white.opacity(0.075),
                primaryText: Color.white.opacity(0.95),
                strongText: Color.white.opacity(0.90),
                bodyText: Color.white.opacity(0.74),
                mutedText: Color.white.opacity(0.54),
                quietText: Color.white.opacity(0.38),
                accent: Color(red: 0.62, green: 0.68, blue: 0.72),
                secondaryAccent: Color(red: 0.32, green: 0.38, blue: 0.42),
                buttonText: Color(red: 0.035, green: 0.040, blue: 0.045),
                coolAccent: Color(red: 0.48, green: 0.58, blue: 0.62),
                segmentedBackground: Color.white.opacity(0.08),
                segmentedSelectedBackground: Color(red: 0.66, green: 0.73, blue: 0.79),
                segmentedText: Color.white.opacity(0.86),
                segmentedSelectedText: Color(red: 0.05, green: 0.07, blue: 0.09),
                disabledText: Color.white.opacity(0.44),
                controlBorder: Color.white.opacity(0.16),
                segmentedColorScheme: .dark,
                blockerCell: Color(red: 0.18, green: 0.21, blue: 0.25),
                blockerCellBorder: Color(red: 0.31, green: 0.36, blue: 0.42).opacity(0.70)
            )
        case .ivory:
            return SquartThemePalette(
                backgroundTop: Color(red: 0.92, green: 0.88, blue: 0.80),
                backgroundMid: Color(red: 0.82, green: 0.76, blue: 0.66),
                backgroundBottom: Color(red: 0.70, green: 0.63, blue: 0.52),
                sheetBackground: Color(red: 0.90, green: 0.86, blue: 0.78),
                panel: Color.black.opacity(0.070),
                subtlePanel: Color.white.opacity(0.30),
                border: Color.black.opacity(0.12),
                subtleBorder: Color.black.opacity(0.09),
                primaryText: Color(red: 0.16, green: 0.14, blue: 0.12),
                strongText: Color(red: 0.18, green: 0.15, blue: 0.12),
                bodyText: Color(red: 0.29, green: 0.25, blue: 0.20),
                mutedText: Color(red: 0.43, green: 0.36, blue: 0.28),
                quietText: Color(red: 0.54, green: 0.46, blue: 0.36),
                accent: Color(red: 0.58, green: 0.42, blue: 0.24),
                secondaryAccent: Color(red: 0.70, green: 0.58, blue: 0.40),
                buttonText: Color(red: 0.96, green: 0.92, blue: 0.84),
                coolAccent: Color(red: 0.38, green: 0.48, blue: 0.50),
                segmentedBackground: Color.black.opacity(0.08),
                segmentedSelectedBackground: Color(red: 0.58, green: 0.42, blue: 0.24),
                segmentedText: Color(red: 0.20, green: 0.16, blue: 0.13),
                segmentedSelectedText: Color(red: 0.98, green: 0.95, blue: 0.88),
                disabledText: Color(red: 0.44, green: 0.36, blue: 0.28),
                controlBorder: Color.black.opacity(0.14),
                segmentedColorScheme: .light,
                blockerCell: Color(red: 0.56, green: 0.51, blue: 0.46),
                blockerCellBorder: Color(red: 0.42, green: 0.37, blue: 0.32).opacity(0.74)
            )
        case .forest:
            return SquartThemePalette(
                backgroundTop: Color(red: 0.035, green: 0.075, blue: 0.060),
                backgroundMid: Color(red: 0.060, green: 0.105, blue: 0.080),
                backgroundBottom: Color(red: 0.020, green: 0.040, blue: 0.034),
                sheetBackground: Color(red: 0.030, green: 0.060, blue: 0.050),
                panel: Color.white.opacity(0.055),
                subtlePanel: Color.white.opacity(0.040),
                border: Color.white.opacity(0.09),
                subtleBorder: Color.white.opacity(0.07),
                primaryText: Color.white.opacity(0.94),
                strongText: Color.white.opacity(0.89),
                bodyText: Color.white.opacity(0.74),
                mutedText: Color.white.opacity(0.56),
                quietText: Color.white.opacity(0.40),
                accent: Color(red: 0.64, green: 0.58, blue: 0.40),
                secondaryAccent: Color(red: 0.30, green: 0.44, blue: 0.30),
                buttonText: Color(red: 0.08, green: 0.11, blue: 0.075),
                coolAccent: Color(red: 0.44, green: 0.62, blue: 0.54),
                segmentedBackground: Color.white.opacity(0.075),
                segmentedSelectedBackground: Color(red: 0.67, green: 0.62, blue: 0.46),
                segmentedText: Color.white.opacity(0.84),
                segmentedSelectedText: Color(red: 0.10, green: 0.12, blue: 0.08),
                disabledText: Color.white.opacity(0.46),
                controlBorder: Color.white.opacity(0.16),
                segmentedColorScheme: .dark,
                blockerCell: Color(red: 0.22, green: 0.26, blue: 0.21),
                blockerCellBorder: Color(red: 0.34, green: 0.40, blue: 0.30).opacity(0.72)
            )
        case .bronzeNight:
            return SquartThemePalette(
                backgroundTop: Color(red: 0.050, green: 0.042, blue: 0.045),
                backgroundMid: Color(red: 0.095, green: 0.065, blue: 0.050),
                backgroundBottom: Color(red: 0.028, green: 0.023, blue: 0.025),
                sheetBackground: Color(red: 0.048, green: 0.037, blue: 0.034),
                panel: Color.white.opacity(0.055),
                subtlePanel: Color.white.opacity(0.042),
                border: Color.white.opacity(0.095),
                subtleBorder: Color.white.opacity(0.075),
                primaryText: Color.white.opacity(0.94),
                strongText: Color.white.opacity(0.90),
                bodyText: Color.white.opacity(0.75),
                mutedText: Color.white.opacity(0.56),
                quietText: Color.white.opacity(0.40),
                accent: Color(red: 0.84, green: 0.57, blue: 0.30),
                secondaryAccent: Color(red: 0.48, green: 0.27, blue: 0.14),
                buttonText: Color(red: 0.15, green: 0.08, blue: 0.04),
                coolAccent: Color(red: 0.58, green: 0.60, blue: 0.60),
                segmentedBackground: Color.white.opacity(0.075),
                segmentedSelectedBackground: Color(red: 0.86, green: 0.60, blue: 0.34),
                segmentedText: Color.white.opacity(0.85),
                segmentedSelectedText: Color(red: 0.16, green: 0.09, blue: 0.05),
                disabledText: Color.white.opacity(0.45),
                controlBorder: Color.white.opacity(0.16),
                segmentedColorScheme: .dark,
                blockerCell: Color(red: 0.24, green: 0.20, blue: 0.22),
                blockerCellBorder: Color(red: 0.36, green: 0.29, blue: 0.33).opacity(0.72)
            )
        }
    }
}
