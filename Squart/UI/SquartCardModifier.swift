import SwiftUI

struct SquartCardModifier: ViewModifier {
    @Environment(\.squartPalette) private var palette

    var cornerRadius: CGFloat = SquartTheme.Radius.small
    var fill: Color?
    var stroke: Color?

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill ?? palette.subtlePanel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(stroke ?? palette.subtleBorder, lineWidth: 1)
            )
    }
}

extension View {
    func squartCard(
        cornerRadius: CGFloat = SquartTheme.Radius.small,
        fill: Color? = nil,
        stroke: Color? = nil
    ) -> some View {
        modifier(
            SquartCardModifier(
                cornerRadius: cornerRadius,
                fill: fill,
                stroke: stroke
            )
        )
    }
}
