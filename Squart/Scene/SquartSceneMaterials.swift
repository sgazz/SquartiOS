import SceneKit

final class SquartSceneMaterials {
    private(set) var background: PlatformColor
    private(set) var environment: PlatformColor
    private(set) var fog: SquartSceneFog
    private(set) var lighting: SquartSceneLighting

    let emptyTile: SCNMaterial
    let inactiveBlocker: SCNMaterial
    let outsideTile: SCNMaterial
    let horizontalPiece: SCNMaterial
    let verticalPiece: SCNMaterial
    let horizontalPieceAccent: SCNMaterial
    let verticalPieceAccent: SCNMaterial
    let humanPreviewFill: SCNMaterial
    let humanPreviewEdge: SCNMaterial
    let aiPreviewFill: SCNMaterial
    let aiPreviewEdge: SCNMaterial
    let blockerCap: SCNMaterial
    let trayBase: SCNMaterial
    let shadowPlate: SCNMaterial

    init(theme: SquartVisualTheme) {
        self.background = .black
        self.environment = .black
        self.fog = SquartSceneFog(startDistance: 24, endDistance: 42, densityExponent: 0.55)
        self.lighting = SquartSceneLighting(
            environmentIntensity: 0.24,
            ambientIntensity: 340,
            ambientTemperature: 4_350,
            keyIntensity: 95,
            keyTemperature: 4_200,
            fillIntensity: 260,
            fillTemperature: 4_500,
            rimIntensity: 210,
            rimTemperature: 4_900,
            shadowOpacity: 0.10
        )
        self.emptyTile = SCNMaterial()
        self.inactiveBlocker = SCNMaterial()
        self.outsideTile = SCNMaterial()
        self.horizontalPiece = SCNMaterial()
        self.verticalPiece = SCNMaterial()
        self.horizontalPieceAccent = SCNMaterial()
        self.verticalPieceAccent = SCNMaterial()
        self.humanPreviewFill = SCNMaterial()
        self.humanPreviewEdge = SCNMaterial()
        self.aiPreviewFill = SCNMaterial()
        self.aiPreviewEdge = SCNMaterial()
        self.blockerCap = SCNMaterial()
        self.trayBase = SCNMaterial()
        self.shadowPlate = SCNMaterial()

        apply(theme: theme, animated: false)
    }

    func apply(theme: SquartVisualTheme, animated: Bool) {
        let palette = SquartScenePalette(theme: theme)

        let changes = {
            self.background = palette.background
            self.environment = palette.environment
            self.fog = palette.fog
            self.lighting = palette.lighting
            Self.configure(self.emptyTile, color: palette.emptyTile, emission: palette.emptyTileEmission, roughness: 0.78, metalness: 0.07)
            Self.configure(self.inactiveBlocker, color: palette.inactiveBlocker, emission: palette.inactiveBlockerEmission, roughness: 0.92, metalness: 0.03)
            Self.configure(self.outsideTile, color: PlatformColor.color(red: 0.035, green: 0.035, blue: 0.035, alpha: 0), roughness: 1, metalness: 0, transparency: 0)
            Self.configure(self.horizontalPiece, color: palette.horizontalPieceAccent, roughness: 0.74, metalness: 0.06)
            Self.configure(self.verticalPiece, color: palette.verticalPieceAccent, roughness: 0.76, metalness: 0.05)
            Self.configure(self.horizontalPieceAccent, color: palette.horizontalPieceAccent, roughness: 0.82, metalness: 0.02)
            Self.configure(self.verticalPieceAccent, color: palette.verticalPieceAccent, roughness: 0.84, metalness: 0.02)
            Self.configure(self.humanPreviewFill, color: palette.humanPreviewFill, emission: palette.humanPreviewEmission, roughness: 0.36, metalness: 0.10, transparency: 0.42)
            Self.configure(self.humanPreviewEdge, color: palette.humanPreviewEdge, emission: palette.humanPreviewEdgeEmission, roughness: 0.42, metalness: 0.20, transparency: 0.70)
            Self.configure(self.aiPreviewFill, color: palette.aiPreviewFill, emission: palette.aiPreviewEmission, roughness: 0.40, metalness: 0.10, transparency: 0.44)
            Self.configure(self.aiPreviewEdge, color: palette.aiPreviewEdge, emission: palette.aiPreviewEdgeEmission, roughness: 0.44, metalness: 0.18, transparency: 0.68)
            Self.configure(self.blockerCap, color: palette.blockerCap, emission: palette.blockerCapEmission, roughness: 0.88, metalness: 0.05)
            Self.configure(self.trayBase, color: palette.trayBase, emission: palette.trayBaseEmission, roughness: 0.82, metalness: 0.08)
            Self.configure(self.shadowPlate, color: palette.shadowPlate, roughness: 0.96, metalness: 0)
        }

        guard animated else {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            changes()
            SCNTransaction.commit()
            return
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = SquartTheme.themeTransitionDuration
        changes()
        SCNTransaction.commit()
    }

    private static func configure(
        _ material: SCNMaterial,
        color: PlatformColor,
        emission: PlatformColor? = nil,
        roughness: CGFloat,
        metalness: CGFloat,
        transparency: CGFloat = 1
    ) {
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        material.roughness.contents = roughness
        material.metalness.contents = metalness
        material.emission.contents = emission ?? PlatformColor.black
        material.transparency = transparency
        material.blendMode = transparency < 1 ? .alpha : .replace
    }
}

struct SquartSceneFog {
    let startDistance: CGFloat
    let endDistance: CGFloat
    let densityExponent: CGFloat
}

struct SquartSceneLighting {
    let environmentIntensity: CGFloat
    let ambientIntensity: CGFloat
    let ambientTemperature: CGFloat
    let keyIntensity: CGFloat
    let keyTemperature: CGFloat
    let fillIntensity: CGFloat
    let fillTemperature: CGFloat
    let rimIntensity: CGFloat
    let rimTemperature: CGFloat
    let shadowOpacity: CGFloat
}

private struct SquartScenePalette {
    let background: PlatformColor
    let environment: PlatformColor
    let fog: SquartSceneFog
    let lighting: SquartSceneLighting

    let emptyTile: PlatformColor
    let emptyTileEmission: PlatformColor
    let inactiveBlocker: PlatformColor
    let inactiveBlockerEmission: PlatformColor
    let horizontalPiece: PlatformColor
    let horizontalPieceEmission: PlatformColor
    let verticalPiece: PlatformColor
    let verticalPieceEmission: PlatformColor
    let horizontalPieceAccent: PlatformColor
    let horizontalPieceAccentEmission: PlatformColor
    let verticalPieceAccent: PlatformColor
    let verticalPieceAccentEmission: PlatformColor
    let humanPreviewFill: PlatformColor
    let humanPreviewEmission: PlatformColor
    let humanPreviewEdge: PlatformColor
    let humanPreviewEdgeEmission: PlatformColor
    let aiPreviewFill: PlatformColor
    let aiPreviewEmission: PlatformColor
    let aiPreviewEdge: PlatformColor
    let aiPreviewEdgeEmission: PlatformColor
    let blockerCap: PlatformColor
    let blockerCapEmission: PlatformColor
    let trayBase: PlatformColor
    let trayBaseEmission: PlatformColor
    let shadowPlate: PlatformColor

    init(theme: SquartVisualTheme) {
        switch theme {
        case .cappuccino:
            self = .cappuccino
        case .obsidian:
            self = .obsidian
        case .ivory:
            self = .ivory
        case .forest:
            self = .forest
        case .bronzeNight:
            self = .bronzeNight
        }
    }
}

private extension SquartScenePalette {
    static let cappuccino = SquartScenePalette(
        background: .color(red: 0.035, green: 0.035, blue: 0.034),
        environment: .color(red: 0.62, green: 0.52, blue: 0.43),
        fog: SquartSceneFog(startDistance: 24, endDistance: 42, densityExponent: 0.55),
        lighting: SquartSceneLighting(
            environmentIntensity: 0.24,
            ambientIntensity: 340,
            ambientTemperature: 4_350,
            keyIntensity: 95,
            keyTemperature: 4_200,
            fillIntensity: 260,
            fillTemperature: 4_500,
            rimIntensity: 210,
            rimTemperature: 4_900,
            shadowOpacity: 0.10
        ),
        emptyTile: .color(red: 0.185, green: 0.176, blue: 0.162),
        emptyTileEmission: .color(red: 0.010, green: 0.008, blue: 0.006),
        inactiveBlocker: .color(red: 0.096, green: 0.080, blue: 0.064),
        inactiveBlockerEmission: .color(red: 0.010, green: 0.006, blue: 0.004),
        horizontalPiece: .color(red: 0.49, green: 0.36, blue: 0.24),
        horizontalPieceEmission: .color(red: 0.045, green: 0.026, blue: 0.012),
        verticalPiece: .color(red: 0.23, green: 0.30, blue: 0.305),
        verticalPieceEmission: .color(red: 0.014, green: 0.024, blue: 0.026),
        horizontalPieceAccent: .color(red: 0.83, green: 0.65, blue: 0.42),
        horizontalPieceAccentEmission: .color(red: 0.095, green: 0.055, blue: 0.020),
        verticalPieceAccent: .color(red: 0.55, green: 0.65, blue: 0.65),
        verticalPieceAccentEmission: .color(red: 0.020, green: 0.035, blue: 0.035),
        humanPreviewFill: .color(red: 0.86, green: 0.62, blue: 0.34, alpha: 0.20),
        humanPreviewEmission: .color(red: 0.10, green: 0.050, blue: 0.016),
        humanPreviewEdge: .color(red: 0.93, green: 0.72, blue: 0.46, alpha: 0.62),
        humanPreviewEdgeEmission: .color(red: 0.15, green: 0.080, blue: 0.026),
        aiPreviewFill: .color(red: 0.42, green: 0.55, blue: 0.58, alpha: 0.22),
        aiPreviewEmission: .color(red: 0.018, green: 0.040, blue: 0.045),
        aiPreviewEdge: .color(red: 0.57, green: 0.70, blue: 0.72, alpha: 0.60),
        aiPreviewEdgeEmission: .color(red: 0.026, green: 0.060, blue: 0.066),
        blockerCap: .color(red: 0.135, green: 0.105, blue: 0.078),
        blockerCapEmission: .color(red: 0.018, green: 0.010, blue: 0.005),
        trayBase: .color(red: 0.072, green: 0.067, blue: 0.061),
        trayBaseEmission: .color(red: 0.012, green: 0.009, blue: 0.006),
        shadowPlate: .color(red: 0.018, green: 0.017, blue: 0.016)
    )

    static let obsidian = SquartScenePalette(
        background: .color(red: 0.018, green: 0.020, blue: 0.023),
        environment: .color(red: 0.42, green: 0.48, blue: 0.52),
        fog: SquartSceneFog(startDistance: 24, endDistance: 42, densityExponent: 0.52),
        lighting: SquartSceneLighting(
            environmentIntensity: 0.25,
            ambientIntensity: 355,
            ambientTemperature: 5_300,
            keyIntensity: 82,
            keyTemperature: 5_100,
            fillIntensity: 280,
            fillTemperature: 5_700,
            rimIntensity: 230,
            rimTemperature: 6_100,
            shadowOpacity: 0.11
        ),
        emptyTile: .color(red: 0.105, green: 0.115, blue: 0.125),
        emptyTileEmission: .color(red: 0.004, green: 0.006, blue: 0.008),
        inactiveBlocker: .color(red: 0.045, green: 0.050, blue: 0.056),
        inactiveBlockerEmission: .color(red: 0.002, green: 0.003, blue: 0.004),
        horizontalPiece: .color(red: 0.43, green: 0.47, blue: 0.50),
        horizontalPieceEmission: .color(red: 0.016, green: 0.020, blue: 0.024),
        verticalPiece: .color(red: 0.18, green: 0.25, blue: 0.30),
        verticalPieceEmission: .color(red: 0.007, green: 0.016, blue: 0.020),
        horizontalPieceAccent: .color(red: 0.64, green: 0.70, blue: 0.74),
        horizontalPieceAccentEmission: .color(red: 0.030, green: 0.038, blue: 0.042),
        verticalPieceAccent: .color(red: 0.43, green: 0.56, blue: 0.62),
        verticalPieceAccentEmission: .color(red: 0.012, green: 0.030, blue: 0.038),
        humanPreviewFill: .color(red: 0.62, green: 0.70, blue: 0.76, alpha: 0.18),
        humanPreviewEmission: .color(red: 0.034, green: 0.045, blue: 0.052),
        humanPreviewEdge: .color(red: 0.72, green: 0.80, blue: 0.84, alpha: 0.60),
        humanPreviewEdgeEmission: .color(red: 0.042, green: 0.055, blue: 0.062),
        aiPreviewFill: .color(red: 0.36, green: 0.48, blue: 0.56, alpha: 0.22),
        aiPreviewEmission: .color(red: 0.010, green: 0.030, blue: 0.042),
        aiPreviewEdge: .color(red: 0.52, green: 0.66, blue: 0.74, alpha: 0.60),
        aiPreviewEdgeEmission: .color(red: 0.018, green: 0.044, blue: 0.058),
        blockerCap: .color(red: 0.070, green: 0.076, blue: 0.084),
        blockerCapEmission: .color(red: 0.003, green: 0.004, blue: 0.006),
        trayBase: .color(red: 0.035, green: 0.040, blue: 0.046),
        trayBaseEmission: .color(red: 0.003, green: 0.004, blue: 0.005),
        shadowPlate: .color(red: 0.006, green: 0.008, blue: 0.010)
    )

    static let ivory = SquartScenePalette(
        background: .color(red: 0.78, green: 0.73, blue: 0.64),
        environment: .color(red: 0.78, green: 0.72, blue: 0.62),
        fog: SquartSceneFog(startDistance: 26, endDistance: 46, densityExponent: 0.42),
        lighting: SquartSceneLighting(
            environmentIntensity: 0.34,
            ambientIntensity: 470,
            ambientTemperature: 4_850,
            keyIntensity: 72,
            keyTemperature: 4_700,
            fillIntensity: 240,
            fillTemperature: 5_000,
            rimIntensity: 150,
            rimTemperature: 5_200,
            shadowOpacity: 0.08
        ),
        emptyTile: .color(red: 0.78, green: 0.72, blue: 0.62),
        emptyTileEmission: .color(red: 0.020, green: 0.017, blue: 0.012),
        inactiveBlocker: .color(red: 0.48, green: 0.40, blue: 0.31),
        inactiveBlockerEmission: .color(red: 0.012, green: 0.009, blue: 0.006),
        horizontalPiece: .color(red: 0.38, green: 0.26, blue: 0.15),
        horizontalPieceEmission: .color(red: 0.022, green: 0.012, blue: 0.005),
        verticalPiece: .color(red: 0.28, green: 0.34, blue: 0.35),
        verticalPieceEmission: .color(red: 0.010, green: 0.014, blue: 0.014),
        horizontalPieceAccent: .color(red: 0.68, green: 0.50, blue: 0.28),
        horizontalPieceAccentEmission: .color(red: 0.034, green: 0.018, blue: 0.006),
        verticalPieceAccent: .color(red: 0.39, green: 0.49, blue: 0.50),
        verticalPieceAccentEmission: .color(red: 0.012, green: 0.020, blue: 0.020),
        humanPreviewFill: .color(red: 0.55, green: 0.36, blue: 0.18, alpha: 0.24),
        humanPreviewEmission: .color(red: 0.040, green: 0.020, blue: 0.006),
        humanPreviewEdge: .color(red: 0.68, green: 0.46, blue: 0.23, alpha: 0.64),
        humanPreviewEdgeEmission: .color(red: 0.052, green: 0.026, blue: 0.008),
        aiPreviewFill: .color(red: 0.30, green: 0.43, blue: 0.46, alpha: 0.24),
        aiPreviewEmission: .color(red: 0.008, green: 0.026, blue: 0.030),
        aiPreviewEdge: .color(red: 0.38, green: 0.52, blue: 0.54, alpha: 0.64),
        aiPreviewEdgeEmission: .color(red: 0.012, green: 0.034, blue: 0.038),
        blockerCap: .color(red: 0.58, green: 0.49, blue: 0.38),
        blockerCapEmission: .color(red: 0.014, green: 0.010, blue: 0.006),
        trayBase: .color(red: 0.58, green: 0.51, blue: 0.42),
        trayBaseEmission: .color(red: 0.010, green: 0.008, blue: 0.005),
        shadowPlate: .color(red: 0.36, green: 0.31, blue: 0.25)
    )

    static let forest = SquartScenePalette(
        background: .color(red: 0.020, green: 0.040, blue: 0.034),
        environment: .color(red: 0.35, green: 0.45, blue: 0.34),
        fog: SquartSceneFog(startDistance: 24, endDistance: 42, densityExponent: 0.55),
        lighting: SquartSceneLighting(
            environmentIntensity: 0.25,
            ambientIntensity: 350,
            ambientTemperature: 4_600,
            keyIntensity: 86,
            keyTemperature: 4_450,
            fillIntensity: 270,
            fillTemperature: 4_900,
            rimIntensity: 200,
            rimTemperature: 5_100,
            shadowOpacity: 0.11
        ),
        emptyTile: .color(red: 0.105, green: 0.150, blue: 0.118),
        emptyTileEmission: .color(red: 0.004, green: 0.008, blue: 0.005),
        inactiveBlocker: .color(red: 0.060, green: 0.086, blue: 0.065),
        inactiveBlockerEmission: .color(red: 0.002, green: 0.004, blue: 0.003),
        horizontalPiece: .color(red: 0.36, green: 0.32, blue: 0.19),
        horizontalPieceEmission: .color(red: 0.020, green: 0.015, blue: 0.006),
        verticalPiece: .color(red: 0.16, green: 0.28, blue: 0.22),
        verticalPieceEmission: .color(red: 0.006, green: 0.018, blue: 0.012),
        horizontalPieceAccent: .color(red: 0.64, green: 0.58, blue: 0.36),
        horizontalPieceAccentEmission: .color(red: 0.038, green: 0.030, blue: 0.012),
        verticalPieceAccent: .color(red: 0.38, green: 0.58, blue: 0.46),
        verticalPieceAccentEmission: .color(red: 0.012, green: 0.034, blue: 0.022),
        humanPreviewFill: .color(red: 0.60, green: 0.54, blue: 0.34, alpha: 0.22),
        humanPreviewEmission: .color(red: 0.040, green: 0.032, blue: 0.012),
        humanPreviewEdge: .color(red: 0.72, green: 0.64, blue: 0.40, alpha: 0.62),
        humanPreviewEdgeEmission: .color(red: 0.052, green: 0.042, blue: 0.016),
        aiPreviewFill: .color(red: 0.32, green: 0.52, blue: 0.44, alpha: 0.22),
        aiPreviewEmission: .color(red: 0.010, green: 0.034, blue: 0.024),
        aiPreviewEdge: .color(red: 0.44, green: 0.66, blue: 0.56, alpha: 0.60),
        aiPreviewEdgeEmission: .color(red: 0.016, green: 0.046, blue: 0.032),
        blockerCap: .color(red: 0.082, green: 0.118, blue: 0.088),
        blockerCapEmission: .color(red: 0.003, green: 0.006, blue: 0.004),
        trayBase: .color(red: 0.040, green: 0.072, blue: 0.054),
        trayBaseEmission: .color(red: 0.003, green: 0.006, blue: 0.004),
        shadowPlate: .color(red: 0.010, green: 0.020, blue: 0.016)
    )

    static let bronzeNight = SquartScenePalette(
        background: .color(red: 0.030, green: 0.024, blue: 0.024),
        environment: .color(red: 0.62, green: 0.42, blue: 0.28),
        fog: SquartSceneFog(startDistance: 24, endDistance: 42, densityExponent: 0.56),
        lighting: SquartSceneLighting(
            environmentIntensity: 0.25,
            ambientIntensity: 350,
            ambientTemperature: 4_050,
            keyIntensity: 90,
            keyTemperature: 3_950,
            fillIntensity: 255,
            fillTemperature: 4_300,
            rimIntensity: 225,
            rimTemperature: 4_700,
            shadowOpacity: 0.11
        ),
        emptyTile: .color(red: 0.150, green: 0.110, blue: 0.090),
        emptyTileEmission: .color(red: 0.008, green: 0.005, blue: 0.003),
        inactiveBlocker: .color(red: 0.082, green: 0.054, blue: 0.042),
        inactiveBlockerEmission: .color(red: 0.005, green: 0.003, blue: 0.002),
        horizontalPiece: .color(red: 0.48, green: 0.26, blue: 0.13),
        horizontalPieceEmission: .color(red: 0.040, green: 0.018, blue: 0.006),
        verticalPiece: .color(red: 0.24, green: 0.25, blue: 0.25),
        verticalPieceEmission: .color(red: 0.012, green: 0.013, blue: 0.013),
        horizontalPieceAccent: .color(red: 0.86, green: 0.52, blue: 0.24),
        horizontalPieceAccentEmission: .color(red: 0.090, green: 0.040, blue: 0.012),
        verticalPieceAccent: .color(red: 0.58, green: 0.60, blue: 0.60),
        verticalPieceAccentEmission: .color(red: 0.020, green: 0.026, blue: 0.026),
        humanPreviewFill: .color(red: 0.84, green: 0.44, blue: 0.18, alpha: 0.22),
        humanPreviewEmission: .color(red: 0.080, green: 0.032, blue: 0.008),
        humanPreviewEdge: .color(red: 0.96, green: 0.60, blue: 0.28, alpha: 0.64),
        humanPreviewEdgeEmission: .color(red: 0.120, green: 0.052, blue: 0.014),
        aiPreviewFill: .color(red: 0.44, green: 0.48, blue: 0.50, alpha: 0.22),
        aiPreviewEmission: .color(red: 0.018, green: 0.024, blue: 0.026),
        aiPreviewEdge: .color(red: 0.62, green: 0.66, blue: 0.68, alpha: 0.60),
        aiPreviewEdgeEmission: .color(red: 0.028, green: 0.036, blue: 0.038),
        blockerCap: .color(red: 0.120, green: 0.076, blue: 0.052),
        blockerCapEmission: .color(red: 0.010, green: 0.005, blue: 0.002),
        trayBase: .color(red: 0.060, green: 0.042, blue: 0.036),
        trayBaseEmission: .color(red: 0.006, green: 0.003, blue: 0.002),
        shadowPlate: .color(red: 0.012, green: 0.009, blue: 0.009)
    )

    init(
        background: PlatformColor,
        environment: PlatformColor,
        fog: SquartSceneFog,
        lighting: SquartSceneLighting,
        emptyTile: PlatformColor,
        emptyTileEmission: PlatformColor,
        inactiveBlocker: PlatformColor,
        inactiveBlockerEmission: PlatformColor,
        horizontalPiece: PlatformColor,
        horizontalPieceEmission: PlatformColor,
        verticalPiece: PlatformColor,
        verticalPieceEmission: PlatformColor,
        horizontalPieceAccent: PlatformColor,
        horizontalPieceAccentEmission: PlatformColor,
        verticalPieceAccent: PlatformColor,
        verticalPieceAccentEmission: PlatformColor,
        humanPreviewFill: PlatformColor,
        humanPreviewEmission: PlatformColor,
        humanPreviewEdge: PlatformColor,
        humanPreviewEdgeEmission: PlatformColor,
        aiPreviewFill: PlatformColor,
        aiPreviewEmission: PlatformColor,
        aiPreviewEdge: PlatformColor,
        aiPreviewEdgeEmission: PlatformColor,
        blockerCap: PlatformColor,
        blockerCapEmission: PlatformColor,
        trayBase: PlatformColor,
        trayBaseEmission: PlatformColor,
        shadowPlate: PlatformColor
    ) {
        self.background = background
        self.environment = environment
        self.fog = fog
        self.lighting = lighting
        self.emptyTile = emptyTile
        self.emptyTileEmission = emptyTileEmission
        self.inactiveBlocker = inactiveBlocker
        self.inactiveBlockerEmission = inactiveBlockerEmission
        self.horizontalPiece = horizontalPiece
        self.horizontalPieceEmission = horizontalPieceEmission
        self.verticalPiece = verticalPiece
        self.verticalPieceEmission = verticalPieceEmission
        self.horizontalPieceAccent = horizontalPieceAccent
        self.horizontalPieceAccentEmission = horizontalPieceAccentEmission
        self.verticalPieceAccent = verticalPieceAccent
        self.verticalPieceAccentEmission = verticalPieceAccentEmission
        self.humanPreviewFill = humanPreviewFill
        self.humanPreviewEmission = humanPreviewEmission
        self.humanPreviewEdge = humanPreviewEdge
        self.humanPreviewEdgeEmission = humanPreviewEdgeEmission
        self.aiPreviewFill = aiPreviewFill
        self.aiPreviewEmission = aiPreviewEmission
        self.aiPreviewEdge = aiPreviewEdge
        self.aiPreviewEdgeEmission = aiPreviewEdgeEmission
        self.blockerCap = blockerCap
        self.blockerCapEmission = blockerCapEmission
        self.trayBase = trayBase
        self.trayBaseEmission = trayBaseEmission
        self.shadowPlate = shadowPlate
    }
}

private extension PlatformColor {
    static func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> PlatformColor {
        PlatformColor(red: red, green: green, blue: blue, alpha: 1)
    }

    static func color(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> PlatformColor {
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
