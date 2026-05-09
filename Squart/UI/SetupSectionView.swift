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
                    .foregroundStyle(.white.opacity(0.90))

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.48))
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.045))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.28),
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
        Color.black.ignoresSafeArea()

        SetupSectionView(title: "Match", subtitle: "Choose the opponent rhythm.") {
            Text("Preview")
                .foregroundStyle(.white)
        }
        .padding()
    }
}
