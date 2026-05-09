import SwiftUI

struct SquartCardModifier: ViewModifier {
    var cornerRadius: CGFloat = SquartTheme.Radius.small
    var fill: Color = SquartTheme.Colors.subtlePanelGraphite
    var stroke: Color = SquartTheme.Colors.subtleBorderGraphite

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            )
    }
}

extension View {
    func squartCard(
        cornerRadius: CGFloat = SquartTheme.Radius.small,
        fill: Color = SquartTheme.Colors.subtlePanelGraphite,
        stroke: Color = SquartTheme.Colors.subtleBorderGraphite
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
