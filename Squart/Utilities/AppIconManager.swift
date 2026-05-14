import Combine
import Foundation
import UIKit

@MainActor
final class AppIconManager: ObservableObject {
    static let shared = AppIconManager()
    nonisolated static let selectedIconThemeIDKey = "squart.appIcon.selectedThemeID"

    @Published private(set) var selectedTheme: SquartVisualTheme
    @Published private(set) var statusMessage: String?

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.selectedTheme = Self.theme(forAlternateIconName: UIApplication.shared.alternateIconName)
            ?? Self.storedTheme(in: defaults)
            ?? .defaultTheme
    }

    var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    func refreshSelectedTheme(access: ThemeAccess) {
        let currentTheme = Self.theme(forAlternateIconName: UIApplication.shared.alternateIconName)
            ?? Self.storedTheme(in: defaults)
            ?? .defaultTheme
        selectedTheme = access.canUseAppIcon(for: currentTheme) ? currentTheme : .defaultTheme
        defaults.set(selectedTheme.id, forKey: Self.selectedIconThemeIDKey)
        #if DEBUG
        print("[SquartStore] AppIconManager refreshSelectedTheme current=\(currentTheme.id) selected=\(selectedTheme.id)")
        #endif
    }

    func enforceAccessibleIcon(access: ThemeAccess) async {
        let currentTheme = Self.theme(forAlternateIconName: UIApplication.shared.alternateIconName)
            ?? Self.storedTheme(in: defaults)
            ?? .defaultTheme

        guard !access.canUseAppIcon(for: currentTheme) else {
            refreshSelectedTheme(access: access)
            return
        }

        guard supportsAlternateIcons else {
            refreshSelectedTheme(access: access)
            return
        }

        do {
            try await applyIcon(named: Self.alternateIconName(for: .defaultTheme))
            selectedTheme = .defaultTheme
            defaults.set(selectedTheme.id, forKey: Self.selectedIconThemeIDKey)
            statusMessage = nil
            #if DEBUG
            print("[SquartStore] AppIconManager enforced default icon due to missing entitlement")
            #endif
        } catch {
            selectedTheme = .defaultTheme
            defaults.set(selectedTheme.id, forKey: Self.selectedIconThemeIDKey)
            statusMessage = "Could not update the app icon."
            #if DEBUG
            print("[SquartStore] AppIconManager failed to enforce default icon")
            #endif
        }
    }

    func setIcon(for theme: SquartVisualTheme, access: ThemeAccess) async -> AppIconChangeResult {
        guard access.canUseAppIcon(for: theme) else {
            statusMessage = "Squart Supporter unlocks this app icon."
            return .locked
        }

        guard supportsAlternateIcons else {
            statusMessage = "Alternate app icons are not available on this device."
            return .unsupported
        }

        let iconName = Self.alternateIconName(for: theme)
        guard UIApplication.shared.alternateIconName != iconName else {
            selectedTheme = theme
            defaults.set(theme.id, forKey: Self.selectedIconThemeIDKey)
            statusMessage = "\(theme.displayName) icon is already active."
            return .alreadySelected
        }

        do {
            try await applyIcon(named: iconName)
            selectedTheme = theme
            defaults.set(theme.id, forKey: Self.selectedIconThemeIDKey)
            statusMessage = "\(theme.displayName) icon applied."
            return .changed
        } catch {
            statusMessage = "Could not change the app icon."
            return .failed
        }
    }

    nonisolated static func alternateIconName(for theme: SquartVisualTheme) -> String? {
        switch theme {
        case .cappuccino:
            return nil
        case .obsidian:
            return "Obsidian"
        case .ivory:
            return "Ivory"
        case .forest:
            return "Forest"
        case .bronzeNight:
            return "BronzeNight"
        }
    }

    nonisolated static func theme(forAlternateIconName iconName: String?) -> SquartVisualTheme? {
        switch iconName {
        case nil:
            return .cappuccino
        case "Obsidian":
            return .obsidian
        case "Ivory":
            return .ivory
        case "Forest":
            return .forest
        case "BronzeNight":
            return .bronzeNight
        default:
            return nil
        }
    }

    nonisolated private static func storedTheme(in defaults: UserDefaults) -> SquartVisualTheme? {
        guard let storedID = defaults.string(forKey: selectedIconThemeIDKey) else {
            return nil
        }

        return SquartVisualTheme(rawValue: storedID)
    }

    private func applyIcon(named iconName: String?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

enum AppIconChangeResult: Equatable {
    case changed
    case alreadySelected
    case locked
    case unsupported
    case failed
}
