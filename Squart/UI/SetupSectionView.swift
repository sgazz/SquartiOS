import SwiftUI

struct SetupSectionView<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SquartTheme.Colors.strongText)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(SquartTheme.Colors.mutedText)
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SquartTheme.Radius.small, style: .continuous)
                .fill(SquartTheme.Colors.subtlePanelGraphite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SquartTheme.Radius.small, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            SquartTheme.Colors.cappuccino.opacity(0.28),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.18), radius: 18, y: 12)
    }
}

#Preview {
    ZStack {
        SquartTheme.Colors.sheetBackground.ignoresSafeArea()

        SetupSectionView(title: "Match", subtitle: "Choose the opponent rhythm.") {
            Text("Preview")
                .foregroundStyle(SquartTheme.Colors.primaryText)
        }
        .padding()
    }
}
