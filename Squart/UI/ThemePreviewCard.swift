import SwiftUI

struct ThemePreviewCard: View {
    @Environment(\.squartPalette) private var palette

    let theme: SquartVisualTheme
    let isSelected: Bool
    let isLocked: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                swatches

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(theme.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isLocked ? palette.mutedText : palette.strongText)

                        Text(labelText)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(labelForeground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(labelFill)
                            )
                    }

                    Text(theme.shortDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)

                    if isLocked {
                        Label("Included with Squart Supporter", systemImage: "lock.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(palette.accent.opacity(0.86))
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: trailingIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(trailingIconColor)
            }
            .padding(16)
            .squartCard(
                cornerRadius: 16,
                fill: isLocked ? palette.panel.opacity(0.62) : palette.panel,
                stroke: isSelected ? palette.accent.opacity(0.62) : palette.border
            )
        }
        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.99, pressedOpacity: 0.90))
        .opacity(isLocked ? 0.82 : 1)
        .scaleEffect(isSelected ? 1.015 : 1)
        .animation(SquartTheme.themeTransitionAnimation, value: isSelected)
        .animation(SquartTheme.themeTransitionAnimation, value: isLocked)
    }

    private var labelText: String {
        if isLocked {
            return "Locked"
        }

        return theme.isPremium ? "Premium" : "Free"
    }

    private var labelForeground: Color {
        if isLocked {
            return palette.accent
        }

        return theme.isPremium ? palette.buttonText : palette.accent
    }

    private var labelFill: Color {
        if isLocked {
            return palette.subtlePanel
        }

        return theme.isPremium ? palette.accent : palette.subtlePanel
    }

    private var trailingIcon: String {
        if isLocked {
            return "lock.circle"
        }

        return isSelected ? "checkmark.circle.fill" : "circle"
    }

    private var trailingIconColor: Color {
        if isLocked {
            return palette.accent.opacity(0.66)
        }

        return isSelected ? palette.accent : palette.mutedText.opacity(0.55)
    }

    private var swatches: some View {
        HStack(spacing: 0) {
            ForEach(theme.previewColors.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: index == 0 ? 8 : 0, style: .continuous)
                    .fill(theme.previewColors[index])
                    .frame(width: 15, height: 42)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(palette.subtleBorder, lineWidth: 1)
        )
    }
}

private extension SquartVisualTheme {
    var previewColors: [Color] {
        switch self {
        case .cappuccino:
            return [
                Color(red: 0.07, green: 0.07, blue: 0.065),
                Color(red: 0.44, green: 0.34, blue: 0.25),
                Color(red: 0.78, green: 0.66, blue: 0.52)
            ]
        case .obsidian:
            return [
                Color(red: 0.02, green: 0.022, blue: 0.024),
                Color(red: 0.13, green: 0.15, blue: 0.17),
                Color(red: 0.55, green: 0.62, blue: 0.66)
            ]
        case .ivory:
            return [
                Color(red: 0.92, green: 0.88, blue: 0.80),
                Color(red: 0.68, green: 0.58, blue: 0.44),
                Color(red: 0.20, green: 0.18, blue: 0.15)
            ]
        case .forest:
            return [
                Color(red: 0.04, green: 0.09, blue: 0.075),
                Color(red: 0.13, green: 0.28, blue: 0.20),
                Color(red: 0.64, green: 0.58, blue: 0.40)
            ]
        case .bronzeNight:
            return [
                Color(red: 0.045, green: 0.04, blue: 0.045),
                Color(red: 0.38, green: 0.22, blue: 0.12),
                Color(red: 0.84, green: 0.57, blue: 0.30)
            ]
        }
    }
}

#Preview {
    ThemePreviewCard(theme: .cappuccino, isSelected: true, isLocked: false) {}
        .padding()
        .background(SquartVisualTheme.defaultTheme.palette.sheetBackground)
}
