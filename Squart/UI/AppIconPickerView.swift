import SwiftUI

struct AppIconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.squartPalette) private var palette
    @StateObject private var storeManager: StoreManager
    @StateObject private var iconManager: AppIconManager
    @State private var isShowingSupportDevelopment = false

    @MainActor
    init() {
        self.init(storeManager: .shared, iconManager: .shared)
    }

    @MainActor
    init(storeManager: StoreManager, iconManager: AppIconManager) {
        self._storeManager = StateObject(wrappedValue: storeManager)
        self._iconManager = StateObject(wrappedValue: iconManager)
    }

    var body: some View {
        ZStack {
            palette.sheetBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                header

                Text("Choose an app icon manually. Premium icons are included with Squart Supporter.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.mutedText)
                    .padding(.horizontal, 2)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(SquartVisualTheme.allCases) { theme in
                            iconRow(for: theme)
                        }
                    }
                    .padding(.bottom, 6)
                }

                if let statusMessage = iconManager.statusMessage {
                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(28)
        }
        .task {
            await storeManager.refreshPurchasedProducts()
            iconManager.refreshSelectedTheme(access: access)
        }
        .onChange(of: storeManager.purchasedProductIDs) { _, _ in
            iconManager.refreshSelectedTheme(access: access)
        }
        .sheet(isPresented: $isShowingSupportDevelopment) {
            SupportDevelopmentView(storeManager: storeManager)
                .presentationDetents([.height(430), .medium])
        }
    }

    private var access: ThemeAccess {
        ThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("App Icons")
                    .font(SquartTheme.titleFont(size: 28))
                    .foregroundStyle(palette.primaryText)

                Text("Match Squart to your selected visual mood.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.mutedText)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.bodyText)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(palette.panel))
            }
            .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.94, pressedOpacity: 0.82))
            .accessibilityLabel("Close app icons")
        }
    }

    private func iconRow(for theme: SquartVisualTheme) -> some View {
        let isSelected = iconManager.selectedTheme == theme
        let isLocked = !access.canUseAppIcon(for: theme)

        return Button {
            select(theme)
        } label: {
            HStack(spacing: 14) {
                iconPreview(for: theme, isLocked: isLocked)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(theme.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isLocked ? palette.mutedText : palette.strongText)

                        Text(theme == .cappuccino ? "Default" : (isLocked ? "Locked" : "Premium"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isLocked ? palette.accent : palette.buttonText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(isLocked ? palette.subtlePanel : palette.accent))
                    }

                    Text(iconDescription(for: theme, isLocked: isLocked))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: trailingIcon(isSelected: isSelected, isLocked: isLocked))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? palette.accent : palette.mutedText.opacity(0.58))
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
        .animation(SquartTheme.themeTransitionAnimation, value: isSelected)
        .animation(SquartTheme.themeTransitionAnimation, value: isLocked)
    }

    private func select(_ theme: SquartVisualTheme) {
        guard access.canUseAppIcon(for: theme) else {
            Haptics.selection()
            isShowingSupportDevelopment = true
            return
        }

        Task {
            let result = await iconManager.setIcon(for: theme, access: access)
            if result == .changed || result == .alreadySelected {
                Haptics.selection()
            } else if result == .failed || result == .unsupported {
                Haptics.warning()
            }
        }
    }

    private func iconDescription(for theme: SquartVisualTheme, isLocked: Bool) -> String {
        if isLocked {
            return "Included with Squart Supporter."
        }

        if theme == .cappuccino {
            return "The primary Squart app icon."
        }

        return "Alternate icon for the \(theme.displayName) theme."
    }

    private func trailingIcon(isSelected: Bool, isLocked: Bool) -> String {
        if isLocked {
            return "lock.circle"
        }

        return isSelected ? "checkmark.circle.fill" : "circle"
    }

    private func iconPreview(for theme: SquartVisualTheme, isLocked: Bool) -> some View {
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

#Preview {
    AppIconPickerView()
}
