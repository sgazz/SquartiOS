import SwiftUI

struct RootView: View {
    @State private var hasStartedGame = false

    var body: some View {
        ZStack {
            PremiumBackground()

            if hasStartedGame {
                GameView()
            } else {
                VStack(spacing: 32) {
                    Text("Squart")
                        .font(.system(size: 46, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.94))

                    Button {
                        hasStartedGame = true
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
                }
                .padding(32)
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
