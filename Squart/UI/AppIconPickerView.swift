import SwiftUI

struct AppIconThemeRow: View {
    @Environment(\.squartPalette) private var palette

    let theme: SquartVisualTheme
    let isSelected: Bool
    let isLocked: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                iconPreview

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(theme.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isLocked ? palette.strongText.opacity(0.72) : palette.strongText)

                        Text(theme == .cappuccino ? "Default" : "Premium")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(badgeForeground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(badgeFill))
                    }

                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: trailingIcon)
                    .font(.system(size: isLocked ? 17 : 20, weight: .semibold))
                    .foregroundStyle(trailingIconColor)
            }
            .padding(16)
            .squartCard(
                cornerRadius: 16,
                fill: isLocked ? palette.panel.opacity(0.72) : palette.panel,
                stroke: isSelected ? palette.accent.opacity(0.62) : palette.border
            )
        }
        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.99, pressedOpacity: 0.90))
        .opacity(isLocked ? 0.94 : 1)
        .animation(SquartTheme.themeTransitionAnimation, value: isSelected)
        .animation(SquartTheme.themeTransitionAnimation, value: isLocked)
    }

    private var badgeForeground: Color {
        if theme == .cappuccino {
            return palette.accent
        }
        return isLocked ? palette.accent : palette.buttonText
    }

    private var badgeFill: Color {
        if theme == .cappuccino {
            return palette.subtlePanel
        }
        return isLocked ? palette.subtlePanel : palette.accent
    }

    private var description: String {
        if isLocked {
            return "Unlocks with the premium pack."
        }
        if theme == .cappuccino {
            return "The primary Squart app icon."
        }
        return "Matches the \(theme.displayName) theme."
    }

    private var trailingIcon: String {
        if isLocked {
            return "lock.fill"
        }
        return isSelected ? "checkmark.circle.fill" : "circle"
    }

    private var trailingIconColor: Color {
        if isLocked {
            return palette.mutedText.opacity(0.55)
        }
        return isSelected ? palette.accent : palette.mutedText.opacity(0.55)
    }

    private var iconPreview: some View {
        let themePalette = theme.palette

        return RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        themePalette.backgroundTop,
                        themePalette.backgroundMid,
                        themePalette.accent
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 48, height: 48)
            .overlay {
                SquartLogoView()
                    .frame(width: 28, height: 28)
                    .opacity(isLocked ? 0.48 : 0.86)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(palette.subtleBorder, lineWidth: 1)
            )
    }
}
