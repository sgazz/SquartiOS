import UIKit

enum Haptics {
    static func selection() {
        guard AppSettingsStore.shared.isHapticsEnabled else {
            return
        }

        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func lightImpact() {
        guard AppSettingsStore.shared.isHapticsEnabled else {
            return
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func softImpact() {
        guard AppSettingsStore.shared.isHapticsEnabled else {
            return
        }

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func warning() {
        guard AppSettingsStore.shared.isHapticsEnabled else {
            return
        }

        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
