import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.squartPalette) private var palette
    @State private var settings: AppSettings
    @State private var isShowingSupportDevelopment = false
    @State private var isShowingThemes = false
    @State private var isShowingAppIcons = false

    private let store: AppSettingsStore

    init(store: AppSettingsStore = .shared) {
        self.store = store
        self._settings = State(initialValue: store.load())
    }

    var body: some View {
        ZStack {
            palette.sheetBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    VStack(spacing: 12) {
                        settingsToggle(
                            title: "Haptics",
                            subtitle: "Subtle feedback for moves and controls.",
                            isOn: hapticsBinding
                        )

                        Button {
                            isShowingThemes = true
                        } label: {
                            settingsRow(
                                title: "Themes",
                                subtitle: "Choose Squart's visual mood."
                            )
                        }
                        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.99, pressedOpacity: 0.88))

                        Button {
                            isShowingAppIcons = true
                        } label: {
                            settingsRow(
                                title: "App Icons",
                                subtitle: "Match the Home Screen icon to your theme."
                            )
                        }
                        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.99, pressedOpacity: 0.88))

                        Button {
                            isShowingSupportDevelopment = true
                        } label: {
                            settingsRow(
                                title: "Support Development",
                                subtitle: "Optional one-time support for Squart."
                            )
                        }
                        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.99, pressedOpacity: 0.88))
                    }
                }
                .padding(28)
            }
        }
        .sheet(isPresented: $isShowingSupportDevelopment) {
            SupportDevelopmentView()
                .presentationDetents([.height(430), .medium])
        }
        .sheet(isPresented: $isShowingThemes) {
            ThemePickerView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $isShowingAppIcons) {
            AppIconPickerView()
                .presentationDetents([.large])
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings")
                    .font(SquartTheme.titleFont(size: 28))
                    .foregroundStyle(palette.primaryText)

                Text("Keep the experience quiet and tactile.")
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
            .accessibilityLabel("Close settings")
        }
    }

    private var hapticsBinding: Binding<Bool> {
        Binding {
            settings.isHapticsEnabled
        } set: { isEnabled in
            settings.isHapticsEnabled = isEnabled
            store.save(settings)
            Haptics.selection()
        }
    }

    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.strongText)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(palette.accent)
        .padding(18)
        .squartCard()
        .animation(SquartTheme.microInteractionAnimation, value: isOn.wrappedValue)
    }

    private func settingsRow(title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.strongText)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.accent)
        }
        .padding(18)
        .squartCard()
    }
}

#Preview {
    SettingsView()
}
