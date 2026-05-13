import Foundation

struct SquartThemeStore {
    static let shared = SquartThemeStore()
    static let selectedThemeIDKey = "squart.theme.selectedThemeID"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSelectedTheme(access: ThemeAccess = .free) -> SquartVisualTheme {
        guard
            let storedID = defaults.string(forKey: Key.selectedThemeID),
            let theme = SquartVisualTheme(rawValue: storedID)
        else {
            return .defaultTheme
        }

        return access.usableTheme(for: theme)
    }

    func saveSelectedTheme(_ theme: SquartVisualTheme) {
        defaults.set(theme.id, forKey: Key.selectedThemeID)
    }

    func sanitizeSelectedTheme(access: ThemeAccess) -> SquartVisualTheme {
        let selectedTheme = loadSelectedTheme(access: access)
        saveSelectedTheme(selectedTheme)
        return selectedTheme
    }
}

private extension SquartThemeStore {
    enum Key {
        static let selectedThemeID = SquartThemeStore.selectedThemeIDKey
    }
}
