import SwiftUI

struct SquartLogoView: View {
    @Environment(\.squartPalette) private var palette

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SquartTheme.Radius.logo, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            palette.panel.opacity(1.6),
                            palette.subtlePanel.opacity(0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: SquartTheme.Radius.logo, style: .continuous)
                        .stroke(palette.accent.opacity(0.20), lineWidth: 1)
                )
                .shadow(color: palette.accent.opacity(0.12), radius: 28, y: 14)

            boardMark
                .padding(18)
        }
        .accessibilityHidden(true)
    }

    private var boardMark: some View {
        GeometryReader { proxy in
            let tile = proxy.size.width / 3.4
            let gap = tile * 0.18
            let step = tile + gap
            let originX = (proxy.size.width - (tile * 3 + gap * 2)) / 2
            let originY = (proxy.size.height - (tile * 3 + gap * 2)) / 2

            ZStack {
                LogoTile(x: originX, y: originY, size: tile, fill: cappuccino.opacity(0.78), lift: 0)
                LogoTile(x: originX + step, y: originY, size: tile, fill: graphite.opacity(0.86), lift: 3)
                LogoTile(x: originX + step * 2, y: originY, size: tile, fill: bronze.opacity(0.76), lift: 1)

                LogoTile(x: originX, y: originY + step, size: tile, fill: graphite.opacity(0.92), lift: 3)
                DominoBar(
                    x: originX + step,
                    y: originY + step,
                    width: tile * 2 + gap,
                    height: tile,
                    fill: cappuccino,
                    lift: 6
                )

                LogoTile(x: originX, y: originY + step * 2, size: tile, fill: bronze.opacity(0.64), lift: 1)
                DominoBar(
                    x: originX + step,
                    y: originY + step * 2,
                    width: tile,
                    height: tile,
                    fill: graphite.opacity(0.88),
                    lift: 3
                )
                LogoTile(x: originX + step * 2, y: originY + step * 2, size: tile, fill: cappuccino.opacity(0.62), lift: 0)
            }
        }
    }

    private var cappuccino: Color { palette.accent }
    private var bronze: Color { palette.secondaryAccent }
    private var graphite: Color { palette.backgroundMid }
}

private struct LogoTile: View {
    @Environment(\.squartPalette) private var palette

    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let fill: Color
    let lift: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: SquartTheme.Radius.small - 1, style: .continuous)
            .fill(fill)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: SquartTheme.Radius.small - 1, style: .continuous)
                    .stroke(palette.subtleBorder, lineWidth: 1)
            )
            .shadow(color: palette.backgroundBottom.opacity(0.26), radius: 8, y: 4 + lift)
            .position(x: x + size / 2, y: y + size / 2 - lift)
    }
}

private struct DominoBar: View {
    @Environment(\.squartPalette) private var palette

    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let fill: Color
    let lift: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: SquartTheme.Radius.small, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        fill.opacity(0.98),
                        fill.opacity(0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: SquartTheme.Radius.small, style: .continuous)
                    .stroke(palette.border.opacity(1.2), lineWidth: 1)
            )
            .shadow(color: palette.backgroundBottom.opacity(0.34), radius: 10, y: 5 + lift)
            .position(x: x + width / 2, y: y + height / 2 - lift)
    }
}

#Preview {
    ZStack {
        SquartVisualTheme.defaultTheme.palette.sheetBackground
            .ignoresSafeArea()

        SquartLogoView()
            .frame(width: 140, height: 140)
    }
}
