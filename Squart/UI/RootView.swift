import SwiftUI

struct RootView: View {
    private enum Screen {
        case landing
        case setup
        case game(GameConfiguration, DailyChallenge?)
    }

    @State private var screen: Screen = .landing
    @State private var isShowingSettings = false
    @State private var isShowingRules = false
    @State private var todayChallenge = DailyChallengeStore.shared.today()
    @State private var isTodayChallengeCompleted = false
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var iconManager: AppIconManager
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(SquartThemeStore.selectedThemeIDKey) private var selectedThemeID = SquartVisualTheme.defaultTheme.id
    #if DEBUG
    @State private var screenshotConfiguration: ScreenshotConfiguration?
    @AppStorage(DebugPremiumUnlock.userDefaultsKey) private var debugUnlockPremium = false
    #endif

    var body: some View {
        let palette = selectedTheme.palette

        ZStack {
            PremiumBackground(palette: palette)

            switch screen {
            case .landing:
                VStack(spacing: 0) {
                    Spacer(minLength: 36)

                    VStack(spacing: 26) {
                        SquartLogoView()
                            .frame(width: 118, height: 118)

                        VStack(spacing: 10) {
                            Text("Squart")
                                .font(SquartTheme.titleFont(size: 52))
                                .foregroundStyle(palette.primaryText)

                            Text("A quiet tactical game of space, direction, and denial.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(palette.mutedText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .frame(maxWidth: 330)
                        }

                        Button {
                            screen = .setup
                        } label: {
                            Text("Start Game")
                        }
                        .buttonStyle(SquartPrimaryButtonStyle())
                        .padding(.top, 6)

                        Button {
                            Haptics.softImpact()
                            screen = .game(todayChallenge.configuration, todayChallenge)
                        } label: {
                            dailyChallengeButtonLabel(palette: palette)
                        }
                        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.985, pressedOpacity: 0.88))
                        .accessibilityLabel(isTodayChallengeCompleted ? "Daily Challenge completed today" : "Daily Challenge available today")
                    }

                    Spacer(minLength: 20)
                }
                .padding(32)
            case .setup:
                SetupView { configuration in
                    screen = .game(configuration, nil)
                } onBack: {
                    screen = .landing
                }
            case .game(let configuration, let dailyChallenge):
                #if DEBUG
                let debugScene = screenshotConfiguration?.screen.gamePreset
                #else
                let debugScene: ScreenshotConfiguration.GamePreset? = nil
                #endif
                GameView(
                    configuration: configuration,
                    dailyChallenge: dailyChallenge,
                    onChangeSetup: {
                        screen = .setup
                    },
                    onDailyChallengeCompleted: {
                        refreshDailyChallenge()
                    },
                    screenshotConfiguration: debugScene
                )
            }
        }
        .overlay(alignment: .topLeading) {
            if case .landing = screen {
                landingToolbarButton(
                    palette: palette,
                    systemImage: "questionmark",
                    accessibilityLabel: "How to Play"
                ) {
                    Haptics.selection()
                    isShowingRules = true
                }
                .padding(.top, 22)
                .padding(.leading, 22)
            }
        }
        .overlay(alignment: .topTrailing) {
            if case .landing = screen {
                landingToolbarButton(
                    palette: palette,
                    systemImage: "gearshape",
                    accessibilityLabel: "Settings"
                ) {
                    Haptics.selection()
                    isShowingSettings = true
                }
                .padding(.top, 22)
                .padding(.trailing, 22)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingRules) {
            RulesView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task {
            #if DEBUG
            applyScreenshotSceneIfNeeded()
            #endif
            await storeManager.refreshPurchasedProducts()
            sanitizeSelectedTheme()
            await iconManager.enforceAccessibleIcon(access: themeAccess)
            refreshDailyChallenge()
        }
        .onChange(of: storeManager.purchasedProductIDs) { _, _ in
            #if DEBUG
            print("[SquartStore] RootView observed purchasedProductIDs=\(storeManager.purchasedProductIDs.sorted())")
            #endif
            sanitizeSelectedTheme()
            Task {
                await iconManager.enforceAccessibleIcon(access: themeAccess)
            }
        }
        #if DEBUG
        .onChange(of: debugUnlockPremium) { _, _ in
            sanitizeSelectedTheme()
            iconManager.refreshSelectedTheme(access: themeAccess)
            Task {
                await iconManager.enforceAccessibleIcon(access: themeAccess)
            }
        }
        #endif
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                await storeManager.refreshPurchasedProducts()
            }
        }
        .environment(\.squartPalette, palette)
        .animation(SquartTheme.themeTransitionAnimation, value: selectedThemeID)
    }

    private var selectedTheme: SquartVisualTheme {
        let storedTheme = SquartVisualTheme(rawValue: selectedThemeID) ?? .defaultTheme
        return themeAccess.usableTheme(for: storedTheme)
    }

    private var themeAccess: ThemeAccess {
        #if DEBUG
        DebugPremiumUnlock.makeThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
        #else
        ThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
        #endif
    }

    private func sanitizeSelectedTheme() {
        let usableTheme = selectedTheme
        if usableTheme.id != selectedThemeID {
            selectedThemeID = usableTheme.id
        }
    }

    private func refreshDailyChallenge() {
        todayChallenge = DailyChallengeStore.shared.today()
        isTodayChallengeCompleted = DailyChallengeHistoryStore.shared.isCompleted(dateKey: todayChallenge.dateKey)
    }

    #if DEBUG
    private func applyScreenshotSceneIfNeeded() {
        guard let scene = ScreenshotScene.fromLaunchArguments(ProcessInfo.processInfo.arguments) else {
            return
        }

        let screenshot = ScreenshotSceneFactory.make(scene)
        screenshotConfiguration = screenshot
        selectedThemeID = screenshot.selectedTheme.id

        switch screenshot.screen {
        case .landing:
            screen = .landing
        case .game(let preset):
            screen = .game(preset.configuration, preset.dailyChallenge)
        }
    }
    #endif

    private func dailyChallengeButtonLabel(palette: SquartThemePalette) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isTodayChallengeCompleted ? "checkmark.circle.fill" : "calendar")
                .font(.system(size: 15, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(isTodayChallengeCompleted ? "Completed Today" : "Daily Challenge")
                    .font(.system(size: 15, weight: .semibold))

                Text(isTodayChallengeCompleted ? "Replay: \(todayChallenge.setupSummary)" : todayChallenge.setupSummary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.mutedText)
                    .lineLimit(2)
            }
        }
        .foregroundStyle(palette.accent)
        .padding(.horizontal, 18)
        .padding(.vertical, 11)
        .background(
            Capsule()
                .stroke(palette.accent.opacity(isTodayChallengeCompleted ? 0.44 : 0.30), lineWidth: 1)
                .background(Capsule().fill(palette.subtlePanel.opacity(0.76)))
        )
    }
}

#if DEBUG
private extension ScreenshotConfiguration.Screen {
    var gamePreset: ScreenshotConfiguration.GamePreset? {
        if case .game(let preset) = self {
            return preset
        }

        return nil
    }
}
#endif

private func landingToolbarButton(
    palette: SquartThemePalette,
    systemImage: String,
    accessibilityLabel: String,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        Image(systemName: systemImage)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(palette.bodyText)
            .frame(width: 42, height: 42)
            .background(
                Circle()
                    .fill(palette.panel)
                    .overlay(Circle().stroke(palette.border, lineWidth: 1))
            )
    }
    .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.96, pressedOpacity: 0.86))
    .accessibilityLabel(accessibilityLabel)
}

private struct PremiumBackground: View {
    let palette: SquartThemePalette

    var body: some View {
        palette.appBackground
            .ignoresSafeArea()
    }
}

#Preview {
    RootView()
        .environmentObject(StoreManager.shared)
        .environmentObject(AppIconManager.shared)
}
