import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.squartPalette) private var palette

    var body: some View {
        ZStack {
            palette.sheetBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 18) {
                    RulesSection(
                        title: "Pieces",
                        items: [
                            "Horizontal places 2-cell pieces left-to-right.",
                            "Vertical places 2-cell pieces top-to-bottom.",
                            "Pieces can only be placed on empty active cells."
                        ]
                    )

                    RulesSection(
                        title: "Board",
                        items: [
                            "Blocker cells cannot be used.",
                            "Diamond shape removes corners from the board.",
                            "Inactive cells are tactical blockers."
                        ]
                    )

                    RulesSection(
                        title: "Win Condition",
                        items: [
                            "A player loses when they have no valid move."
                        ]
                    )
                }

                Spacer(minLength: 0)
            }
            .padding(28)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("How to Play")
                    .font(SquartTheme.titleFont(size: 28))
                    .foregroundStyle(palette.primaryText)

                Text("Quiet territory, two cells at a time.")
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
            .accessibilityLabel("Close rules")
        }
    }
}

private struct RulesSection: View {
    let title: String
    let items: [String]
    @Environment(\.squartPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(palette.accent)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(palette.accent.opacity(0.72))
                            .frame(width: 4, height: 4)
                            .padding(.top, 7)

                        Text(item)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(palette.bodyText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .squartCard()
    }
}

#Preview {
    RulesView()
}
