import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.055, blue: 0.05)
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
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(.white.opacity(0.94))

                Text("Quiet territory, two cells at a time.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.56))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.76))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.08)))
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
                .foregroundStyle(Color(red: 0.78, green: 0.66, blue: 0.52))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.72))
                            .frame(width: 4, height: 4)
                            .padding(.top, 7)

                        Text(item)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.white.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.045))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    RulesView()
}
