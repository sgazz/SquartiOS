import SwiftUI

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var iconManager: AppIconManager
    @State private var selectedTheme: SquartVisualTheme
    @State private var isShowingPremiumPurchase = false
    @State private var pendingPremiumTheme: SquartVisualTheme?
    #if DEBUG
    @AppStorage(DebugPremiumUnlock.userDefaultsKey) private var debugUnlockPremium = false
    #endif

    private let store: SquartThemeStore

    init(store: SquartThemeStore = .shared) {
        self.store = store
        self._selectedTheme = State(initialValue: store.loadSelectedTheme())
    }

    var body: some View {
        let palette = selectedTheme.palette

        ZStack {
            palette.sheetBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 12) {
                            ForEach(SquartVisualTheme.allCases) { theme in
                                ThemePreviewCard(
                                    theme: theme,
                                    isSelected: selectedTheme == theme,
                                    isLocked: !access.canUse(theme)
                                ) {
                                    selectTheme(theme)
                                }
                            }
                        }

                        appIconSection
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
        .environment(\.squartPalette, palette)
        .animation(SquartTheme.themeTransitionAnimation, value: selectedTheme)
        .animation(SquartTheme.themeTransitionAnimation, value: storeManager.purchasedProductIDs)
        #if DEBUG
        .animation(SquartTheme.themeTransitionAnimation, value: debugUnlockPremium)
        #endif
        .animation(SquartTheme.themeTransitionAnimation, value: iconManager.selectedTheme)
        .onAppear {
            selectedTheme = store.loadSelectedTheme(access: access)
            iconManager.refreshSelectedTheme(access: access)
        }
        .task {
            await storeManager.refreshPurchasedProducts()
            await storeManager.loadProducts()
            selectedTheme = store.sanitizeSelectedTheme(access: access)
            iconManager.refreshSelectedTheme(access: access)
        }
        .onChange(of: storeManager.purchasedProductIDs) { _, _ in
            #if DEBUG
            print("[SquartStore] ThemePickerView observed purchasedProductIDs=\(storeManager.purchasedProductIDs.sorted())")
            #endif
            iconManager.refreshSelectedTheme(access: access)
            applyPendingPremiumSelectionIfNeeded()
        }
        #if DEBUG
        .onChange(of: debugUnlockPremium) { _, _ in
            selectedTheme = store.sanitizeSelectedTheme(access: access)
            iconManager.refreshSelectedTheme(access: access)
            Task {
                await iconManager.enforceAccessibleIcon(access: access)
            }
            applyPendingPremiumSelectionIfNeeded()
        }
        #endif
        .sheet(isPresented: $isShowingPremiumPurchase) {
            PremiumThemesPurchaseView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var access: ThemeAccess {
        #if DEBUG
        DebugPremiumUnlock.makeThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
        #else
        ThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
        #endif
    }

    private var hasPremiumEntitlement: Bool {
        #if DEBUG
        DebugPremiumUnlock.grantsPremiumEntitlement(supporterPurchased: storeManager.isSupporterPurchased)
        #else
        storeManager.isSupporterPurchased
        #endif
    }

    private var appIconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Icon")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selectedTheme.palette.mutedText)
                .textCase(.uppercase)
                .tracking(0.6)

            if !hasPremiumEntitlement {
                Text("One purchase unlocks premium themes and alternate app icons.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selectedTheme.palette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 12) {
                ForEach(SquartVisualTheme.allCases) { theme in
                    AppIconThemeRow(
                        theme: theme,
                        isSelected: iconManager.selectedTheme == theme,
                        isLocked: !access.canUseAppIcon(for: theme)
                    ) {
                        selectAppIcon(theme)
                    }
                }
            }
        }
    }

    private func selectTheme(_ theme: SquartVisualTheme) {
        guard access.canUse(theme) else {
            Haptics.selection()
            pendingPremiumTheme = theme
            isShowingPremiumPurchase = true
            return
        }

        applyThemeAndIcon(theme)
    }

    private func selectAppIcon(_ theme: SquartVisualTheme) {
        guard access.canUseAppIcon(for: theme) else {
            Haptics.selection()
            pendingPremiumTheme = theme
            isShowingPremiumPurchase = true
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

    private func applyThemeAndIcon(_ theme: SquartVisualTheme) {
        withAnimation(SquartTheme.themeTransitionAnimation) {
            selectedTheme = theme
        }
        store.saveSelectedTheme(theme)

        Task {
            _ = await iconManager.setIcon(for: theme, access: access)
            Haptics.selection()
        }
    }

    private func applyPendingPremiumSelectionIfNeeded() {
        guard let pendingPremiumTheme, access.canUse(pendingPremiumTheme) else {
            withAnimation(SquartTheme.themeTransitionAnimation) {
                selectedTheme = store.sanitizeSelectedTheme(access: access)
            }
            return
        }

        applyThemeAndIcon(pendingPremiumTheme)
        self.pendingPremiumTheme = nil
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Themes & Icons")
                    .font(SquartTheme.titleFont(size: 28))
                    .foregroundStyle(selectedTheme.palette.primaryText)

                Text("Premium themes and matching app icons unlock together.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(selectedTheme.palette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selectedTheme.palette.bodyText)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(selectedTheme.palette.panel))
            }
            .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.94, pressedOpacity: 0.82))
            .accessibilityLabel("Close themes and icons")
        }
    }
}

#Preview {
    ThemePickerView()
        .environmentObject(StoreManager.shared)
        .environmentObject(AppIconManager.shared)
}
