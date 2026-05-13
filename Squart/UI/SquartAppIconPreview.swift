import SwiftUI

struct SquartAppIconPreview: View {
    @Environment(\.squartPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("App Icon Direction")
                .font(SquartTheme.titleFont(size: 30))
                .foregroundStyle(palette.primaryText)

            HStack(alignment: .center, spacing: 24) {
                SquartAppIconView()
                    .frame(width: 180, height: 180)

                VStack(alignment: .leading, spacing: 16) {
                    IconScaleRow(size: 72, title: "Home Screen")
                    IconScaleRow(size: 44, title: "Spotlight")
                    IconScaleRow(size: 29, title: "Settings")
                }
            }

            HStack(spacing: 18) {
                PreviewTile(title: "Dark") {
                    SquartAppIconView()
                        .frame(width: 96, height: 96)
                }
                .background(palette.backgroundBottom)

                PreviewTile(title: "Light") {
                    SquartAppIconView()
                        .frame(width: 96, height: 96)
                }
                .background(Color(red: 0.90, green: 0.86, blue: 0.78))

                PreviewTile(title: "Mono") {
                    SquartMonochromeAppIconView()
                        .frame(width: 96, height: 96)
                }
                .background(palette.backgroundBottom)
            }
        }
        .padding(28)
        .background(palette.sheetBackground)
    }
}

struct SquartAppIconView: View {
    @Environment(\.squartPalette) private var palette

    var body: some View {
        SquartIconShell {
            SquartAppIconMark(
                tileFill: palette.backgroundMid,
                tileStroke: palette.border.opacity(0.42),
                primaryFill: palette.accent,
                secondaryFill: palette.secondaryAccent,
                shadow: palette.backgroundBottom.opacity(0.32)
            )
        }
        .accessibilityHidden(true)
    }
}

struct SquartMonochromeAppIconView: View {
    @Environment(\.squartPalette) private var palette

    var body: some View {
        SquartIconShell {
            SquartAppIconMark(
                tileFill: palette.panel.opacity(0.86),
                tileStroke: palette.subtleBorder.opacity(0.54),
                primaryFill: palette.primaryText,
                secondaryFill: palette.mutedText,
                shadow: palette.backgroundBottom.opacity(0.24)
            )
        }
        .accessibilityHidden(true)
    }
}

private struct SquartIconShell<Content: View>: View {
    @Environment(\.squartPalette) private var palette
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            palette.backgroundBottom,
                            palette.panel,
                            palette.backgroundMid
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 52, style: .continuous)
                        .stroke(palette.accent.opacity(0.24), lineWidth: 2)
                )

            content
                .padding(78)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct SquartAppIconMark: View {
    let tileFill: Color
    let tileStroke: Color
    let primaryFill: Color
    let secondaryFill: Color
    let shadow: Color

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let tile = side / 3.05
            let gap = tile * 0.12
            let step = tile + gap
            let width = tile * 3 + gap * 2
            let originX = (proxy.size.width - width) / 2
            let originY = (proxy.size.height - width) / 2

            ZStack {
                IconTile(x: originX, y: originY, size: tile, fill: secondaryFill, stroke: tileStroke)
                IconTile(x: originX + step, y: originY, size: tile, fill: tileFill, stroke: tileStroke)
                IconTile(x: originX + step * 2, y: originY, size: tile, fill: tileFill, stroke: tileStroke)

                IconTile(x: originX, y: originY + step, size: tile, fill: tileFill, stroke: tileStroke)
                IconDomino(
                    x: originX + step,
                    y: originY + step,
                    width: tile * 2 + gap,
                    height: tile,
                    fill: primaryFill,
                    stroke: tileStroke,
                    shadow: shadow
                )

                IconDomino(
                    x: originX,
                    y: originY + step * 2,
                    width: tile,
                    height: tile,
                    fill: tileFill,
                    stroke: tileStroke,
                    shadow: shadow.opacity(0.7)
                )
                IconDomino(
                    x: originX + step,
                    y: originY + step * 2,
                    width: tile,
                    height: tile,
                    fill: secondaryFill,
                    stroke: tileStroke,
                    shadow: shadow
                )
                IconTile(x: originX + step * 2, y: originY + step * 2, size: tile, fill: tileFill, stroke: tileStroke)
            }
        }
    }
}

private struct IconTile: View {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let fill: Color
    let stroke: Color

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
            .fill(fill)
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                    .stroke(stroke, lineWidth: max(1.5, size * 0.035))
            )
            .frame(width: size, height: size)
            .position(x: x + size / 2, y: y + size / 2)
    }
}

private struct IconDomino: View {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let fill: Color
    let stroke: Color
    let shadow: Color

    var body: some View {
        RoundedRectangle(cornerRadius: min(width, height) * 0.22, style: .continuous)
            .fill(fill)
            .overlay(
                RoundedRectangle(cornerRadius: min(width, height) * 0.22, style: .continuous)
                    .stroke(stroke.opacity(1.35), lineWidth: max(1.5, min(width, height) * 0.035))
            )
            .shadow(color: shadow, radius: max(5, min(width, height) * 0.18), y: max(3, min(width, height) * 0.08))
            .frame(width: width, height: height)
            .position(x: x + width / 2, y: y + height / 2)
    }
}

private struct IconScaleRow: View {
    @Environment(\.squartPalette) private var palette

    let size: CGFloat
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            SquartAppIconView()
                .frame(width: size, height: size)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(palette.mutedText)
        }
    }
}

private struct PreviewTile<Content: View>: View {
    @Environment(\.squartPalette) private var palette

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 12) {
            content

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.mutedText)
        }
        .frame(width: 132, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(palette.subtleBorder, lineWidth: 1)
        )
    }
}

#Preview("App Icon Direction") {
    SquartAppIconPreview()
        .environment(\.squartPalette, SquartVisualTheme.defaultTheme.palette)
}
