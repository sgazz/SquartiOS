import SceneKit

enum SquartSceneMaterials {
    static let background = color(red: 0.035, green: 0.035, blue: 0.034)
    static let environment = color(red: 0.62, green: 0.52, blue: 0.43)

    static let emptyTile = material(
        color: color(red: 0.185, green: 0.176, blue: 0.162),
        emission: color(red: 0.010, green: 0.008, blue: 0.006),
        roughness: 0.78,
        metalness: 0.07
    )

    static let inactiveBlocker = material(
        color: color(red: 0.096, green: 0.080, blue: 0.064),
        emission: color(red: 0.010, green: 0.006, blue: 0.004),
        roughness: 0.92,
        metalness: 0.03
    )

    static let outsideTile = material(
        color: color(red: 0.035, green: 0.035, blue: 0.035, alpha: 0),
        roughness: 1,
        metalness: 0,
        transparency: 0
    )

    static let horizontalPiece = material(
        color: color(red: 0.49, green: 0.36, blue: 0.24),
        emission: color(red: 0.045, green: 0.026, blue: 0.012),
        roughness: 0.60,
        metalness: 0.20
    )

    static let verticalPiece = material(
        color: color(red: 0.23, green: 0.30, blue: 0.305),
        emission: color(red: 0.014, green: 0.024, blue: 0.026),
        roughness: 0.62,
        metalness: 0.14
    )

    static let horizontalPieceAccent = material(
        color: color(red: 0.83, green: 0.65, blue: 0.42),
        emission: color(red: 0.095, green: 0.055, blue: 0.020),
        roughness: 0.46,
        metalness: 0.28
    )

    static let verticalPieceAccent = material(
        color: color(red: 0.55, green: 0.65, blue: 0.65),
        emission: color(red: 0.020, green: 0.035, blue: 0.035),
        roughness: 0.48,
        metalness: 0.18
    )

    static let humanPreviewFill = material(
        color: color(red: 0.86, green: 0.62, blue: 0.34, alpha: 0.20),
        emission: color(red: 0.10, green: 0.050, blue: 0.016),
        roughness: 0.36,
        metalness: 0.10,
        transparency: 0.42
    )

    static let humanPreviewEdge = material(
        color: color(red: 0.93, green: 0.72, blue: 0.46, alpha: 0.62),
        emission: color(red: 0.15, green: 0.080, blue: 0.026),
        roughness: 0.42,
        metalness: 0.20,
        transparency: 0.70
    )

    static let aiPreviewFill = material(
        color: color(red: 0.42, green: 0.55, blue: 0.58, alpha: 0.22),
        emission: color(red: 0.018, green: 0.040, blue: 0.045),
        roughness: 0.40,
        metalness: 0.10,
        transparency: 0.44
    )

    static let aiPreviewEdge = material(
        color: color(red: 0.57, green: 0.70, blue: 0.72, alpha: 0.60),
        emission: color(red: 0.026, green: 0.060, blue: 0.066),
        roughness: 0.44,
        metalness: 0.18,
        transparency: 0.68
    )

    static let blockerCap = material(
        color: color(red: 0.135, green: 0.105, blue: 0.078),
        emission: color(red: 0.018, green: 0.010, blue: 0.005),
        roughness: 0.88,
        metalness: 0.05
    )

    static let trayBase = material(
        color: color(red: 0.072, green: 0.067, blue: 0.061),
        emission: color(red: 0.012, green: 0.009, blue: 0.006),
        roughness: 0.82,
        metalness: 0.08
    )

    static let shadowPlate = material(
        color: color(red: 0.018, green: 0.017, blue: 0.016),
        roughness: 0.96,
        metalness: 0.0
    )

    private static func material(
        color: PlatformColor,
        emission: PlatformColor? = nil,
        roughness: CGFloat,
        metalness: CGFloat,
        transparency: CGFloat = 1
    ) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        material.roughness.contents = roughness
        material.metalness.contents = metalness
        material.emission.contents = emission ?? PlatformColor.black
        material.transparency = transparency
        material.blendMode = transparency < 1 ? .alpha : .replace
        return material
    }

    private static func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> PlatformColor {
        PlatformColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private static func color(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> PlatformColor {
        PlatformColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif
