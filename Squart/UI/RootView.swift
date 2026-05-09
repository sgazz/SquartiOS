import SwiftUI

struct RootView: View {
    private enum Screen {
        case landing
        case setup
        case game(GameConfiguration)
    }

    @State private var screen: Screen = .landing
    @State private var isShowingSettings = false

    var body: some View {
        ZStack {
            PremiumBackground()

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
                                .foregroundStyle(SquartTheme.Colors.primaryText)

                            Text("A quiet tactical game of space, direction, and denial.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(SquartTheme.Colors.mutedText)
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
                    }

                    Spacer()

                    Text("Native iOS prototype")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(SquartTheme.Colors.quietText)
                        .padding(.bottom, 20)
                }
                .padding(32)
            case .setup:
                SetupView { configuration in
                    screen = .game(configuration)
                } onBack: {
                    screen = .landing
                }
            case .game(let configuration):
                GameView(configuration: configuration) {
                    screen = .setup
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if case .landing = screen {
                Button {
                    Haptics.selection()
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(SquartTheme.Colors.bodyText)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(SquartTheme.Colors.panelGraphite)
                                .overlay(Circle().stroke(SquartTheme.Colors.borderGraphite, lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Settings")
                .padding(.top, 22)
                .padding(.trailing, 22)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct PremiumBackground: View {
    var body: some View {
        SquartTheme.appBackground
        .ignoresSafeArea()
    }
}

#Preview {
    RootView()
}
