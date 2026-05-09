import SceneKit

enum BoardNodeFactory {
    static let dominoNodeName = "domino"

    private static let tileSize: CGFloat = 0.88
    private static let gap: CGFloat = 0.08
    private static let tileNamePrefix = "tile"

    static func makeBoardNode(
        from board: SquartBoard,
        previewPositions: Set<BoardPosition>
    ) -> SCNNode {
        let rootNode = SCNNode()
        let spacing = tileSize + gap
        let xOffset = CGFloat(board.columns - 1) * spacing / 2
        let zOffset = CGFloat(board.rows - 1) * spacing / 2

        for row in 0..<board.rows {
            for column in 0..<board.columns {
                let position = BoardPosition(row: row, column: column)
                let state = board.cellState(at: position) ?? .outside
                let tileNode = makeTileNode(
                    for: state,
                    at: position,
                    isPreviewed: previewPositions.contains(position)
                )

                tileNode.position = SCNVector3(
                    CGFloat(column) * spacing - xOffset,
                    yPosition(for: state),
                    CGFloat(row) * spacing - zOffset
                )
                rootNode.addChildNode(tileNode)
            }
        }

        rootNode.addChildNode(makeBaseNode(rows: board.rows, columns: board.columns))
        return rootNode
    }

    static func position(for node: SCNNode) -> BoardPosition? {
        var currentNode: SCNNode? = node

        while let node = currentNode {
            if let position = position(from: node.name) {
                return position
            }

            currentNode = node.parent
        }

        return nil
    }

    static func tileNode(in rootNode: SCNNode, at position: BoardPosition) -> SCNNode? {
        let expectedName = name(for: position)
        var matchingNode: SCNNode?

        rootNode.enumerateChildNodes { node, stop in
            if node.name == expectedName {
                matchingNode = node
                stop.pointee = true
            }
        }

        return matchingNode
    }

    private static func makeTileNode(
        for state: CellState,
        at position: BoardPosition,
        isPreviewed: Bool
    ) -> SCNNode {
        if state == .outside {
            let node = SCNNode()
            node.name = "\(tileNamePrefix)_\(position.row)_\(position.column)"
            return node
        }

        let geometry = SCNBox(
            width: tileSize,
            height: height(for: state),
            length: tileSize,
            chamferRadius: chamferRadius(for: state)
        )
        geometry.materials = [baseMaterial(for: state)]

        let node = SCNNode(geometry: geometry)
        node.name = name(for: position)
        node.castsShadow = true

        if case .occupied(let player) = state {
            node.addChildNode(makeDominoNode(for: player))
        }

        if state == .inactive {
            node.addChildNode(makeBlockerCap())
        }

        if isPreviewed {
            node.addChildNode(makePreviewNode())
        }

        return node
    }

    private static func makePreviewNode() -> SCNNode {
        let rootNode = SCNNode()
        let fill = SCNBox(width: 0.72, height: 0.018, length: 0.72, chamferRadius: 0.04)
        fill.materials = [ScenePalette.previewFill]

        let fillNode = SCNNode(geometry: fill)
        fillNode.position = SCNVector3(0, 0.018, 0)
        rootNode.addChildNode(fillNode)

        let railLength: CGFloat = 0.76
        let railThickness: CGFloat = 0.035
        let railHeight: CGFloat = 0.026

        for z in [-0.39, 0.39] as [CGFloat] {
            let rail = SCNBox(width: railLength, height: railHeight, length: railThickness, chamferRadius: 0.012)
            rail.materials = [ScenePalette.previewEdge]

            let railNode = SCNNode(geometry: rail)
            railNode.position = SCNVector3(0, 0.035, z)
            rootNode.addChildNode(railNode)
        }

        for x in [-0.39, 0.39] as [CGFloat] {
            let rail = SCNBox(width: railThickness, height: railHeight, length: railLength, chamferRadius: 0.012)
            rail.materials = [ScenePalette.previewEdge]

            let railNode = SCNNode(geometry: rail)
            railNode.position = SCNVector3(x, 0.035, 0)
            rootNode.addChildNode(railNode)
        }

        rootNode.position = SCNVector3(0, 0.09, 0)
        return rootNode
    }

    private static func makeDominoNode(for player: Player) -> SCNNode {
        let domino = SCNBox(
            width: player == .horizontal ? 0.76 : 0.32,
            height: 0.18,
            length: player == .horizontal ? 0.32 : 0.76,
            chamferRadius: 0.07
        )
        domino.materials = [player == .horizontal ? ScenePalette.horizontalDomino : ScenePalette.verticalDomino]

        let node = SCNNode(geometry: domino)
        node.name = dominoNodeName
        node.position = SCNVector3(0, 0.15, 0)
        node.castsShadow = true
        node.addChildNode(makeDominoTopLine(for: player))
        return node
    }

    private static func makeDominoTopLine(for player: Player) -> SCNNode {
        let line = SCNBox(
            width: player == .horizontal ? 0.46 : 0.045,
            height: 0.012,
            length: player == .horizontal ? 0.045 : 0.46,
            chamferRadius: 0.008
        )
        line.materials = [player == .horizontal ? ScenePalette.horizontalAccent : ScenePalette.verticalAccent]

        let node = SCNNode(geometry: line)
        node.position = SCNVector3(0, 0.098, 0)
        return node
    }

    private static func makeBlockerCap() -> SCNNode {
        let cap = SCNBox(width: 0.58, height: 0.035, length: 0.58, chamferRadius: 0.035)
        cap.materials = [ScenePalette.blockerCap]

        let node = SCNNode(geometry: cap)
        node.position = SCNVector3(0, 0.035, 0)
        return node
    }

    private static func makeBaseNode(rows: Int, columns: Int) -> SCNNode {
        let rootNode = SCNNode()
        let width = CGFloat(columns) * tileSize + CGFloat(columns + 1) * gap
        let length = CGFloat(rows) * tileSize + CGFloat(rows + 1) * gap

        let base = SCNBox(width: width + 0.34, height: 0.12, length: length + 0.34, chamferRadius: 0.14)
        base.materials = [ScenePalette.boardBase]

        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, -0.17, 0)
        baseNode.castsShadow = true
        rootNode.addChildNode(baseNode)

        let shadowPlate = SCNBox(width: width + 0.70, height: 0.025, length: length + 0.70, chamferRadius: 0.18)
        shadowPlate.materials = [ScenePalette.shadowPlate]

        let shadowNode = SCNNode(geometry: shadowPlate)
        shadowNode.position = SCNVector3(0, -0.25, 0)
        rootNode.addChildNode(shadowNode)

        return rootNode
    }

    private static func height(for state: CellState) -> CGFloat {
        switch state {
        case .outside:
            return 0.01
        case .inactive:
            return 0.07
        case .empty:
            return 0.105
        case .occupied:
            return 0.10
        }
    }

    private static func yPosition(for state: CellState) -> CGFloat {
        switch state {
        case .outside:
            return -0.16
        case .inactive:
            return -0.075
        case .empty:
            return 0
        case .occupied:
            return 0
        }
    }

    private static func chamferRadius(for state: CellState) -> CGFloat {
        switch state {
        case .outside:
            return 0
        case .inactive:
            return 0.045
        case .empty, .occupied:
            return 0.055
        }
    }

    private static func baseMaterial(for state: CellState) -> SCNMaterial {
        switch state {
        case .outside:
            return ScenePalette.outsideTile
        case .inactive:
            return ScenePalette.inactiveTile
        case .empty, .occupied:
            return ScenePalette.emptyTile
        }
    }

    private static func position(from nodeName: String?) -> BoardPosition? {
        guard let nodeName else {
            return nil
        }

        let parts = nodeName.split(separator: "_")

        guard
            parts.count == 3,
            parts[0] == tileNamePrefix,
            let row = Int(parts[1]),
            let column = Int(parts[2])
        else {
            return nil
        }

        return BoardPosition(row: row, column: column)
    }

    private static func name(for position: BoardPosition) -> String {
        "\(tileNamePrefix)_\(position.row)_\(position.column)"
    }
}

enum ScenePalette {
    static let background = color(red: 0.035, green: 0.035, blue: 0.034)
    static let environment = color(red: 0.62, green: 0.52, blue: 0.43)

    static let boardBase = material(
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
    static let emptyTile = material(
        color: color(red: 0.185, green: 0.176, blue: 0.162),
        emission: color(red: 0.010, green: 0.008, blue: 0.006),
        roughness: 0.78,
        metalness: 0.07
    )
    static let outsideTile = material(
        color: color(red: 0.035, green: 0.035, blue: 0.035, alpha: 0),
        roughness: 1,
        metalness: 0,
        transparency: 0
    )
    static let inactiveTile = material(
        color: color(red: 0.096, green: 0.080, blue: 0.064),
        emission: color(red: 0.010, green: 0.006, blue: 0.004),
        roughness: 0.92,
        metalness: 0.03
    )
    static let blockerCap = material(
        color: color(red: 0.135, green: 0.105, blue: 0.078),
        emission: color(red: 0.018, green: 0.010, blue: 0.005),
        roughness: 0.88,
        metalness: 0.05
    )
    static let horizontalDomino = material(
        color: color(red: 0.49, green: 0.36, blue: 0.24),
        emission: color(red: 0.045, green: 0.026, blue: 0.012),
        roughness: 0.60,
        metalness: 0.20
    )
    static let verticalDomino = material(
        color: color(red: 0.23, green: 0.30, blue: 0.305),
        emission: color(red: 0.014, green: 0.024, blue: 0.026),
        roughness: 0.62,
        metalness: 0.14
    )
    static let horizontalAccent = material(
        color: color(red: 0.83, green: 0.65, blue: 0.42),
        emission: color(red: 0.095, green: 0.055, blue: 0.020),
        roughness: 0.46,
        metalness: 0.28
    )
    static let verticalAccent = material(
        color: color(red: 0.55, green: 0.65, blue: 0.65),
        emission: color(red: 0.020, green: 0.035, blue: 0.035),
        roughness: 0.48,
        metalness: 0.18
    )
    static let previewFill = material(
        color: color(red: 0.86, green: 0.62, blue: 0.34, alpha: 0.20),
        emission: color(red: 0.10, green: 0.050, blue: 0.016),
        roughness: 0.36,
        metalness: 0.10,
        transparency: 0.42
    )
    static let previewEdge = material(
        color: color(red: 0.93, green: 0.72, blue: 0.46, alpha: 0.62),
        emission: color(red: 0.15, green: 0.080, blue: 0.026),
        roughness: 0.42,
        metalness: 0.20,
        transparency: 0.70
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
