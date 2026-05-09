import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings: AppSettings

    private let store: AppSettingsStore

    init(store: AppSettingsStore = .shared) {
        self.store = store
        self._settings = State(initialValue: store.load())
    }

    var body: some View {
        ZStack {
            SquartTheme.Colors.sheetBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(spacing: 12) {
                    settingsToggle(
                        title: "Haptics",
                        subtitle: "Subtle feedback for moves and controls.",
                        isOn: hapticsBinding
                    )

                    settingsToggle(
                        title: "Sound Effects",
                        subtitle: "Prepared for future move and match sounds.",
                        isOn: soundEffectsBinding
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
                Text("Settings")
                    .font(SquartTheme.titleFont(size: 28))
                    .foregroundStyle(SquartTheme.Colors.primaryText)

                Text("Keep the experience quiet and tactile.")
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
            .accessibilityLabel("Close settings")
        }
    }

    private var hapticsBinding: Binding<Bool> {
        Binding {
            settings.isHapticsEnabled
        } set: { isEnabled in
            settings.isHapticsEnabled = isEnabled
            store.save(settings)
        }
    }

    private var soundEffectsBinding: Binding<Bool> {
        Binding {
            settings.isSoundEffectsEnabled
        } set: { isEnabled in
            settings.isSoundEffectsEnabled = isEnabled
            store.save(settings)
        }
    }

    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(SquartTheme.Colors.strongText)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(SquartTheme.Colors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(SquartTheme.Colors.cappuccino)
        .padding(18)
        .squartCard()
    }
}

#Preview {
    SettingsView()
}
