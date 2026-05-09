enum SoundEffects {
    static func playMove() {
        guard AppSettingsStore.shared.isSoundEffectsEnabled else {
            return
        }
    }

    static func playInvalid() {
        guard AppSettingsStore.shared.isSoundEffectsEnabled else {
            return
        }
    }

    static func playGameOver() {
        guard AppSettingsStore.shared.isSoundEffectsEnabled else {
            return
        }
    }
}
