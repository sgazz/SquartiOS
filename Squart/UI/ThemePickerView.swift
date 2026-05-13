import SwiftUI

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @State private var selectedTheme: SquartVisualTheme
    @State private var isShowingSupportDevelopment = false
    @State private var isShowingAppIcons = false
    @State private var pendingThemeAfterUnlock: SquartVisualTheme?

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

                HStack(spacing: 12) {
                    Text("Premium themes are included with Squart Supporter.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    Button {
                        isShowingAppIcons = true
                    } label: {
                        Label("App Icons", systemImage: "app.badge")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(palette.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(palette.subtlePanel))
                    }
                    .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.97, pressedOpacity: 0.86))
                }
                .padding(.horizontal, 2)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(SquartVisualTheme.allCases) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: selectedTheme == theme,
                                isLocked: !access.canUse(theme)
                            ) {
                                select(theme)
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            .padding(28)
        }
        .environment(\.squartPalette, palette)
        .animation(SquartTheme.themeTransitionAnimation, value: selectedTheme)
        .animation(SquartTheme.themeTransitionAnimation, value: storeManager.purchasedProductIDs)
        .onAppear {
            selectedTheme = store.loadSelectedTheme(access: access)
        }
        .task {
            await storeManager.refreshPurchasedProducts()
            await storeManager.loadProducts()
            selectedTheme = store.sanitizeSelectedTheme(access: access)
        }
        .onChange(of: storeManager.purchasedProductIDs) { _, _ in
            #if DEBUG
            print("[SquartStore] ThemePickerView observed purchasedProductIDs=\(storeManager.purchasedProductIDs.sorted())")
            #endif
            if let pendingThemeAfterUnlock, access.canUse(pendingThemeAfterUnlock) {
                withAnimation(SquartTheme.themeTransitionAnimation) {
                    selectedTheme = pendingThemeAfterUnlock
                }
                store.saveSelectedTheme(pendingThemeAfterUnlock)
                self.pendingThemeAfterUnlock = nil
            } else {
                withAnimation(SquartTheme.themeTransitionAnimation) {
                    selectedTheme = store.sanitizeSelectedTheme(access: access)
                }
            }
        }
        .sheet(isPresented: $isShowingSupportDevelopment) {
            SupportDevelopmentView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingAppIcons) {
            AppIconPickerView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var access: ThemeAccess {
        ThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
    }

    private func select(_ theme: SquartVisualTheme) {
        guard access.canUse(theme) else {
            Haptics.selection()
            pendingThemeAfterUnlock = theme
            isShowingSupportDevelopment = true
            return
        }

        withAnimation(SquartTheme.themeTransitionAnimation) {
            selectedTheme = theme
        }
        store.saveSelectedTheme(theme)
        Haptics.selection()
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Themes")
                    .font(SquartTheme.titleFont(size: 28))
                    .foregroundStyle(selectedTheme.palette.primaryText)

                Text("Choose the visual mood for Squart.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(selectedTheme.palette.mutedText)
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
            .accessibilityLabel("Close themes")
        }
    }
}

#Preview {
    ThemePickerView()
        .environmentObject(StoreManager.shared)
        .environmentObject(AppIconManager.shared)
}
