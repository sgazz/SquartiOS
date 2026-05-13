import SceneKit

enum BoardNodeFactory {
    static let dominoNodeName = "domino"

    private static let tileSize: CGFloat = 0.88
    private static let gap: CGFloat = 0.08
    private static let tileNamePrefix = "tile"

    // MARK: - Board

    static func makeBoardNode(
        from board: SquartBoard,
        previewPositions: Set<BoardPosition>,
        aiPreviewPositions: Set<BoardPosition>,
        materials: SquartSceneMaterials
    ) -> SCNNode {
        let rootNode = SCNNode()
        let geometry = BoardGeometry(materials: materials)
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
                    isPreviewed: previewPositions.contains(position),
                    isAIPreviewed: aiPreviewPositions.contains(position),
                    geometry: geometry
                )

                tileNode.position = SCNVector3(
                    CGFloat(column) * spacing - xOffset,
                    yPosition(for: state),
                    CGFloat(row) * spacing - zOffset
                )
                rootNode.addChildNode(tileNode)
            }
        }

        addDominoNodes(
            to: rootNode,
            from: board,
            spacing: spacing,
            xOffset: xOffset,
            zOffset: zOffset,
            geometry: geometry
        )
        rootNode.addChildNode(makeBaseNode(rows: board.rows, columns: board.columns, materials: materials))
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

    static func dominoNodes(in rootNode: SCNNode, matching positions: Set<BoardPosition>) -> [SCNNode] {
        var matchingNodes: [SCNNode] = []

        rootNode.enumerateChildNodes { node, _ in
            guard node.name?.hasPrefix("\(dominoNodeName)_") == true else {
                return
            }

            if dominoPositions(from: node.name) == positions {
                matchingNodes.append(node)
            }
        }

        return matchingNodes
    }

    // MARK: - Tile Nodes

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
        isPreviewed: Bool,
        isAIPreviewed: Bool,
        geometry: BoardGeometry
    ) -> SCNNode {
        if state == .outside {
            let node = SCNNode()
            node.name = "\(tileNamePrefix)_\(position.row)_\(position.column)"
            return node
        }

        let node = SCNNode(geometry: tileGeometry(for: state, geometry: geometry))
        node.name = name(for: position)
        node.castsShadow = true

        if state == .inactive {
            node.addChildNode(makeBlockerCap(geometry: geometry))
        }

        if isPreviewed {
            node.addChildNode(makePreviewNode(style: .human, geometry: geometry))
        }

        if isAIPreviewed {
            node.addChildNode(makePreviewNode(style: .ai, geometry: geometry))
        }

        return node
    }

    // MARK: - Preview

    private static func makePreviewNode(style: PreviewStyle, geometry: BoardGeometry) -> SCNNode {
        let rootNode = SCNNode()

        let fillNode = SCNNode(geometry: style.fillGeometry(in: geometry))
        fillNode.position = SCNVector3(0, 0.018, 0)
        rootNode.addChildNode(fillNode)

        for z in [-0.39, 0.39] as [CGFloat] {
            let railNode = SCNNode(geometry: style.horizontalRailGeometry(in: geometry))
            railNode.position = SCNVector3(0, 0.035, z)
            rootNode.addChildNode(railNode)
        }

        for x in [-0.39, 0.39] as [CGFloat] {
            let railNode = SCNNode(geometry: style.verticalRailGeometry(in: geometry))
            railNode.position = SCNVector3(x, 0.035, 0)
            rootNode.addChildNode(railNode)
        }

        rootNode.position = SCNVector3(0, 0.09, 0)
        return rootNode
    }

    // MARK: - Pieces

    private static func addDominoNodes(
        to rootNode: SCNNode,
        from board: SquartBoard,
        spacing: CGFloat,
        xOffset: CGFloat,
        zOffset: CGFloat,
        geometry: BoardGeometry
    ) {
        var consumedPositions: Set<BoardPosition> = []

        for row in 0..<board.rows {
            for column in 0..<board.columns {
                let position = BoardPosition(row: row, column: column)

                guard !consumedPositions.contains(position) else {
                    continue
                }

                if isDominoOrigin(at: position, for: .horizontal, on: board, consumedPositions: consumedPositions) {
                    let nextPosition = position.offsetBy(rows: 0, columns: 1)
                    let node = makeDominoNode(for: .horizontal, positions: [position, nextPosition], geometry: geometry)
                    node.position = centerPosition(
                        between: position,
                        and: nextPosition,
                        spacing: spacing,
                        xOffset: xOffset,
                        zOffset: zOffset
                    )
                    rootNode.addChildNode(node)
                    consumedPositions.insert(position)
                    consumedPositions.insert(nextPosition)
                }
            }
        }

        for column in 0..<board.columns {
            for row in 0..<board.rows {
                let position = BoardPosition(row: row, column: column)

                guard !consumedPositions.contains(position) else {
                    continue
                }

                if isDominoOrigin(at: position, for: .vertical, on: board, consumedPositions: consumedPositions) {
                    let nextPosition = position.offsetBy(rows: 1, columns: 0)
                    let node = makeDominoNode(for: .vertical, positions: [position, nextPosition], geometry: geometry)
                    node.position = centerPosition(
                        between: position,
                        and: nextPosition,
                        spacing: spacing,
                        xOffset: xOffset,
                        zOffset: zOffset
                    )
                    rootNode.addChildNode(node)
                    consumedPositions.insert(position)
                    consumedPositions.insert(nextPosition)
                }
            }
        }
    }

    private static func makeDominoNode(for player: Player, positions: [BoardPosition], geometry: BoardGeometry) -> SCNNode {
        let node = SCNNode(geometry: player == .horizontal ? geometry.horizontalDomino : geometry.verticalDomino)
        node.name = dominoName(for: positions)
        node.castsShadow = true
        node.addChildNode(makeDominoTopLine(for: player, geometry: geometry))
        return node
    }

    private static func makeDominoTopLine(for player: Player, geometry: BoardGeometry) -> SCNNode {
        let node = SCNNode(geometry: player == .horizontal ? geometry.horizontalDominoTopLine : geometry.verticalDominoTopLine)
        node.position = SCNVector3(0, 0.098, 0)
        return node
    }

    private static func isDominoOrigin(
        at position: BoardPosition,
        for player: Player,
        on board: SquartBoard,
        consumedPositions: Set<BoardPosition>
    ) -> Bool {
        guard board.cellState(at: position) == .occupied(player) else {
            return false
        }

        let delta = player.moveDelta
        let nextPosition = position.offsetBy(rows: delta.rows, columns: delta.columns)
        return !consumedPositions.contains(nextPosition) &&
            board.cellState(at: nextPosition) == .occupied(player)
    }

    private static func centerPosition(
        between firstPosition: BoardPosition,
        and secondPosition: BoardPosition,
        spacing: CGFloat,
        xOffset: CGFloat,
        zOffset: CGFloat
    ) -> SCNVector3 {
        let firstX = CGFloat(firstPosition.column) * spacing - xOffset
        let firstZ = CGFloat(firstPosition.row) * spacing - zOffset
        let secondX = CGFloat(secondPosition.column) * spacing - xOffset
        let secondZ = CGFloat(secondPosition.row) * spacing - zOffset

        return SCNVector3(
            (firstX + secondX) / 2,
            0.17,
            (firstZ + secondZ) / 2
        )
    }

    private static func makeBlockerCap(geometry: BoardGeometry) -> SCNNode {
        let node = SCNNode(geometry: geometry.blockerCap)
        node.position = SCNVector3(0, 0.035, 0)
        return node
    }

    // MARK: - Base

    private static func makeBaseNode(rows: Int, columns: Int, materials: SquartSceneMaterials) -> SCNNode {
        let rootNode = SCNNode()
        let width = CGFloat(columns) * tileSize + CGFloat(columns + 1) * gap
        let length = CGFloat(rows) * tileSize + CGFloat(rows + 1) * gap

        let base = SCNBox(width: width + 0.34, height: 0.12, length: length + 0.34, chamferRadius: 0.14)
        base.materials = [materials.trayBase]

        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, -0.17, 0)
        baseNode.castsShadow = true
        rootNode.addChildNode(baseNode)

        let shadowPlate = SCNBox(width: width + 0.70, height: 0.025, length: length + 0.70, chamferRadius: 0.18)
        shadowPlate.materials = [materials.shadowPlate]

        let shadowNode = SCNNode(geometry: shadowPlate)
        shadowNode.position = SCNVector3(0, -0.25, 0)
        rootNode.addChildNode(shadowNode)

        return rootNode
    }

    // MARK: - Geometry Lookup

    private static func tileGeometry(for state: CellState, geometry: BoardGeometry) -> SCNGeometry {
        switch state {
        case .inactive:
            return geometry.inactiveTile
        case .empty:
            return geometry.emptyTile
        case .occupied:
            return geometry.occupiedTile
        case .outside:
            return geometry.outsideTile
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

    // MARK: - Names

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

    private static func dominoName(for positions: [BoardPosition]) -> String {
        let suffix = positions
            .map { "\($0.row)_\($0.column)" }
            .joined(separator: "_")
        return "\(dominoNodeName)_\(suffix)"
    }

    private static func dominoPositions(from nodeName: String?) -> Set<BoardPosition>? {
        guard let nodeName else {
            return nil
        }

        let parts = nodeName.split(separator: "_")

        guard
            parts.count == 5,
            parts[0] == dominoNodeName,
            let firstRow = Int(parts[1]),
            let firstColumn = Int(parts[2]),
            let secondRow = Int(parts[3]),
            let secondColumn = Int(parts[4])
        else {
            return nil
        }

        return [
            BoardPosition(row: firstRow, column: firstColumn),
            BoardPosition(row: secondRow, column: secondColumn)
        ]
    }
}

private enum PreviewStyle {
    case human
    case ai

    func fillGeometry(in geometry: BoardGeometry) -> SCNGeometry {
        switch self {
        case .human:
            return geometry.humanPreviewFill
        case .ai:
            return geometry.aiPreviewFill
        }
    }

    func horizontalRailGeometry(in geometry: BoardGeometry) -> SCNGeometry {
        switch self {
        case .human:
            return geometry.humanPreviewHorizontalRail
        case .ai:
            return geometry.aiPreviewHorizontalRail
        }
    }

    func verticalRailGeometry(in geometry: BoardGeometry) -> SCNGeometry {
        switch self {
        case .human:
            return geometry.humanPreviewVerticalRail
        case .ai:
            return geometry.aiPreviewVerticalRail
        }
    }
}

private struct BoardGeometry {
    let emptyTile: SCNGeometry
    let occupiedTile: SCNGeometry
    let inactiveTile: SCNGeometry
    let outsideTile: SCNGeometry
    let humanPreviewFill: SCNGeometry
    let humanPreviewHorizontalRail: SCNGeometry
    let humanPreviewVerticalRail: SCNGeometry
    let aiPreviewFill: SCNGeometry
    let aiPreviewHorizontalRail: SCNGeometry
    let aiPreviewVerticalRail: SCNGeometry
    let horizontalDomino: SCNGeometry
    let verticalDomino: SCNGeometry
    let horizontalDominoTopLine: SCNGeometry
    let verticalDominoTopLine: SCNGeometry
    let blockerCap: SCNGeometry

    init(materials: SquartSceneMaterials) {
        self.emptyTile = Self.box(width: 0.88, height: 0.105, length: 0.88, chamferRadius: 0.055, material: materials.emptyTile)
        self.occupiedTile = Self.box(width: 0.88, height: 0.10, length: 0.88, chamferRadius: 0.055, material: materials.emptyTile)
        self.inactiveTile = Self.box(width: 0.88, height: 0.07, length: 0.88, chamferRadius: 0.045, material: materials.inactiveBlocker)
        self.outsideTile = Self.box(width: 0.88, height: 0.01, length: 0.88, chamferRadius: 0, material: materials.outsideTile)
        self.humanPreviewFill = Self.box(width: 0.72, height: 0.018, length: 0.72, chamferRadius: 0.04, material: materials.humanPreviewFill)
        self.humanPreviewHorizontalRail = Self.previewHorizontalRail(material: materials.humanPreviewEdge)
        self.humanPreviewVerticalRail = Self.previewVerticalRail(material: materials.humanPreviewEdge)
        self.aiPreviewFill = Self.box(width: 0.72, height: 0.018, length: 0.72, chamferRadius: 0.04, material: materials.aiPreviewFill)
        self.aiPreviewHorizontalRail = Self.previewHorizontalRail(material: materials.aiPreviewEdge)
        self.aiPreviewVerticalRail = Self.previewVerticalRail(material: materials.aiPreviewEdge)
        self.horizontalDomino = Self.box(width: 1.68, height: 0.20, length: 0.80, chamferRadius: 0.08, material: materials.horizontalPiece)
        self.verticalDomino = Self.box(width: 0.80, height: 0.20, length: 1.68, chamferRadius: 0.08, material: materials.verticalPiece)
        self.horizontalDominoTopLine = Self.box(width: 1.12, height: 0.012, length: 0.050, chamferRadius: 0.008, material: materials.horizontalPieceAccent)
        self.verticalDominoTopLine = Self.box(width: 0.050, height: 0.012, length: 1.12, chamferRadius: 0.008, material: materials.verticalPieceAccent)
        self.blockerCap = Self.box(width: 0.58, height: 0.035, length: 0.58, chamferRadius: 0.035, material: materials.blockerCap)
    }

    private static func previewHorizontalRail(material: SCNMaterial) -> SCNGeometry {
        box(width: 0.76, height: 0.026, length: 0.035, chamferRadius: 0.012, material: material)
    }

    private static func previewVerticalRail(material: SCNMaterial) -> SCNGeometry {
        box(width: 0.035, height: 0.026, length: 0.76, chamferRadius: 0.012, material: material)
    }

    private static func box(
        width: CGFloat,
        height: CGFloat,
        length: CGFloat,
        chamferRadius: CGFloat,
        material: SCNMaterial
    ) -> SCNGeometry {
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: chamferRadius)
        box.materials = [material]
        return box
    }
}
