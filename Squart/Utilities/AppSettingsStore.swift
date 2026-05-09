import Foundation

struct AppSettingsStore {
    static let shared = AppSettingsStore()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppSettings {
        return AppSettings(
            isHapticsEnabled: bool(forKey: Key.hapticsEnabled, defaultValue: true),
            isSoundEffectsEnabled: bool(forKey: Key.soundEffectsEnabled, defaultValue: false)
        )
    }

    func save(_ settings: AppSettings) {
        defaults.set(settings.isHapticsEnabled, forKey: Key.hapticsEnabled)
        defaults.set(settings.isSoundEffectsEnabled, forKey: Key.soundEffectsEnabled)
    }

    var isHapticsEnabled: Bool {
        load().isHapticsEnabled
    }

    var isSoundEffectsEnabled: Bool {
        load().isSoundEffectsEnabled
    }
}

private extension AppSettingsStore {
    enum Key {
        static let hapticsEnabled = "squart.appSettings.hapticsEnabled"
        static let soundEffectsEnabled = "squart.appSettings.soundEffectsEnabled"
    }

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        guard defaults.object(forKey: key) != nil else {
            return defaultValue
        }

        return defaults.bool(forKey: key)
    }
}
