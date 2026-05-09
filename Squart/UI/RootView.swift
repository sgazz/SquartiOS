import SwiftUI

struct RootView: View {
    private enum Screen {
        case landing
        case setup
        case game(GameConfiguration)
    }

    @State private var screen: Screen = .landing

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
                                .font(.system(size: 52, weight: .semibold, design: .serif))
                                .foregroundStyle(.white.opacity(0.95))

                            Text("A quiet tactical game of space, direction, and denial.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.58))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .frame(maxWidth: 330)
                        }

                        Button {
                            screen = .setup
                        } label: {
                            Text("Start Game")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color(red: 0.16, green: 0.12, blue: 0.09))
                                .frame(width: 178, height: 52)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0.78, green: 0.66, blue: 0.52))
                                        .shadow(color: Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.18), radius: 18)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 6)
                    }

                    Spacer()

                    Text("Native iOS prototype")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.36))
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
    }
}

private struct PremiumBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.07, blue: 0.07),
                Color(red: 0.12, green: 0.11, blue: 0.10),
                Color(red: 0.05, green: 0.05, blue: 0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    RootView()
}
