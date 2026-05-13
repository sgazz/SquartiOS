import SwiftUI

struct SetupSectionView<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content
    @Environment(\.squartPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(palette.strongText)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.mutedText)
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SquartTheme.Radius.small, style: .continuous)
                .fill(palette.subtlePanel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SquartTheme.Radius.small, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            palette.accent.opacity(0.28),
                            palette.subtleBorder
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
        SquartVisualTheme.defaultTheme.palette.sheetBackground.ignoresSafeArea()

        SetupSectionView(title: "Match", subtitle: "Choose the opponent rhythm.") {
            Text("Preview")
                .foregroundStyle(SquartVisualTheme.defaultTheme.palette.primaryText)
        }
        .padding()
    }
}
