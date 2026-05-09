import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SquartTheme.Colors.sheetBackground
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
                    .foregroundStyle(SquartTheme.Colors.primaryText)

                Text("Quiet territory, two cells at a time.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SquartTheme.Colors.mutedText)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(SquartTheme.Colors.bodyText)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(SquartTheme.Colors.panelGraphite))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close rules")
        }
    }
}

private struct RulesSection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(SquartTheme.Colors.cappuccino)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(SquartTheme.Colors.cappuccino.opacity(0.72))
                            .frame(width: 4, height: 4)
                            .padding(.top, 7)

                        Text(item)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(SquartTheme.Colors.bodyText)
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
