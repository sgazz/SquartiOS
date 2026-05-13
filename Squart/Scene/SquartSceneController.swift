import SceneKit

final class SquartSceneController {
    let scene = SCNScene()
    static let minimumUsableViewportSide: CGFloat = 100

    private enum NodeName {
        static let boardRoot = "squart.boardRoot"
        static let ambientLight = "squart.light.ambient"
        static let keyLight = "squart.light.key"
        static let fillLight = "squart.light.fill"
        static let rimLight = "squart.light.rim"
    }

    private let cameraController: CameraController
    private let boardRootNode = SCNNode()
    private var boardRotationAngle: Float = 0
    private var boardPlanarSize: CGSize = .zero
    private var pendingAutoFit = true
    private var pendingForcedFit = false
    private var lastViewportSize: CGSize = .zero
    private var lastLayoutSignature: LayoutSignature?
    private var lastBoard: SquartBoard?
    private var lastPreviewPositions: Set<BoardPosition> = []
    private var lastAIPreviewPositions: Set<BoardPosition> = []
    private var lastMoveAnimationToken = 0
    private var visualTheme = SquartVisualTheme.defaultTheme
    private var materials = SquartSceneMaterials(theme: .defaultTheme)

    init() {
        self.cameraController = CameraController(scene: scene)
        setupScene()
    }

    // MARK: - Scene Setup

    private func setupScene() {
        boardRootNode.name = NodeName.boardRoot
        if scene.rootNode.childNode(withName: NodeName.boardRoot, recursively: false) == nil {
            scene.rootNode.addChildNode(boardRootNode)
        }
        applyBoardRotation(animated: false)

        applySceneStyle()
        validateStaticSceneIntegrity()
    }

    // MARK: - Updates

    func update(
        board: SquartBoard,
        previewPositions: Set<BoardPosition>,
        aiPreviewPositions: Set<BoardPosition>,
        lastMovePositions: Set<BoardPosition>,
        moveAnimationToken: Int,
        viewportSize: CGSize,
        visualTheme: SquartVisualTheme
    ) {
        let didChangeTheme = visualTheme != self.visualTheme
        if didChangeTheme {
            self.visualTheme = visualTheme
            materials.apply(theme: visualTheme, animated: true)
            applySceneStyle(animated: true)
        }

        if Self.isUsableViewport(viewportSize) {
            lastViewportSize = viewportSize
        }

        let layoutSignature = LayoutSignature(board: board)
        let isLayoutChange = layoutSignature != lastLayoutSignature
        if isLayoutChange {
            pendingAutoFit = true
        }
        let needsBoardRefresh =
            board != lastBoard ||
            previewPositions != lastPreviewPositions ||
            aiPreviewPositions != lastAIPreviewPositions ||
            moveAnimationToken != lastMoveAnimationToken

        if needsBoardRefresh || isLayoutChange {
            let shouldAnimateMove = moveAnimationToken != lastMoveAnimationToken && !lastMovePositions.isEmpty
            lastBoard = board
            lastLayoutSignature = layoutSignature
            lastPreviewPositions = previewPositions
            lastAIPreviewPositions = aiPreviewPositions
            lastMoveAnimationToken = moveAnimationToken
            boardRootNode.childNodes.forEach { $0.removeFromParentNode() }
            let boardContentNode =
                BoardNodeFactory.makeBoardNode(
                    from: board,
                    previewPositions: previewPositions,
                    aiPreviewPositions: aiPreviewPositions,
                    materials: materials
                )
            boardRootNode.addChildNode(boardContentNode)
            boardPlanarSize = planarBounds(for: boardContentNode)
            applyBoardRotation(animated: false)

            if shouldAnimateMove {
                animateMove(at: lastMovePositions)
            }

            validateStaticSceneIntegrity()
        }

        applyPendingOrDefaultFitIfNeeded()
    }

    // MARK: - Camera Controls

    func orbitCamera(deltaX: Float) {
        boardRotationAngle -= deltaX * 0.0032
        boardRotationAngle.formTruncatingRemainder(dividingBy: Float.pi * 2)
        applyBoardRotation(animated: false)
    }

    func zoomCamera(by scale: Float) {
        cameraController.zoom(by: scale)
    }

    func resetCamera(viewportSize: CGSize) {
        if Self.isUsableViewport(viewportSize) {
            lastViewportSize = viewportSize
        } else {
            #if DEBUG
            print("[Squart3D] resetCamera ignored invalid viewport=\(Int(viewportSize.width))x\(Int(viewportSize.height))")
            #endif
        }
        boardRotationAngle = 0
        applyBoardRotation(animated: true)
        _ = cameraController.configureDefaultFit(
            planarBoardSize: boardPlanarSize,
            viewportSize: lastViewportSize,
            applyZoom: true
        )
        pendingAutoFit = false
        cameraController.resetToDefaultFit()
    }

    func forceFitToViewport(viewportSize: CGSize, reason: String) {
        if Self.isUsableViewport(viewportSize) {
            lastViewportSize = viewportSize
        } else {
            #if DEBUG
            print("[Squart3D] forceFit pending reason=\(reason) rejected viewport=\(Int(viewportSize.width))x\(Int(viewportSize.height))")
            #endif
        }

        boardRotationAngle = 0
        applyBoardRotation(animated: false)
        pendingForcedFit = true
        applyPendingOrDefaultFitIfNeeded()

        #if DEBUG
        if Self.isUsableViewport(lastViewportSize) {
            print("[Squart3D] forceFit reason=\(reason) viewport=\(Int(lastViewportSize.width))x\(Int(lastViewportSize.height)) board=\(String(format: "%.2f", boardPlanarSize.width))x\(String(format: "%.2f", boardPlanarSize.height))")
        }
        #endif
    }

    func viewportDidChange(_ viewportSize: CGSize) {
        guard Self.isUsableViewport(viewportSize) else {
            #if DEBUG
            print("[Squart3D] viewport change ignored invalid=\(Int(viewportSize.width))x\(Int(viewportSize.height))")
            #endif
            return
        }

        lastViewportSize = viewportSize
        applyPendingOrDefaultFitIfNeeded()
    }

    func rotateCameraLeft90() {
        rotateBoardByQuarterTurns(1)
    }

    func rotateCameraRight90() {
        rotateBoardByQuarterTurns(-1)
    }

    // MARK: - Animation

    private func animateMove(at positions: Set<BoardPosition>) {
        for dominoNode in BoardNodeFactory.dominoNodes(in: boardRootNode, matching: positions) {
            let finalPosition = dominoNode.position
            dominoNode.position = SCNVector3(finalPosition.x, finalPosition.y + 0.18, finalPosition.z)
            dominoNode.scale = SCNVector3(0.96, 0.84, 0.96)

            let settle = SCNAction.group([
                .move(to: finalPosition, duration: 0.24),
                .scale(to: 1.0, duration: 0.24)
            ])
            settle.timingMode = .easeOut
            dominoNode.runAction(settle)
        }
    }

    private func rotateBoardByQuarterTurns(_ quarterTurns: Int) {
        guard quarterTurns != 0 else {
            return
        }

        let step = Float.pi / 2
        let snapped = (boardRotationAngle / step).rounded() * step
        boardRotationAngle = snapped + step * Float(quarterTurns)
        boardRotationAngle.formTruncatingRemainder(dividingBy: Float.pi * 2)
        applyBoardRotation(animated: true)
    }

    private func applyBoardRotation(animated: Bool) {
        let apply = {
            self.boardRootNode.eulerAngles = SCNVector3(0, self.boardRotationAngle, 0)
        }

        guard animated else {
            apply()
            return
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.24
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        apply()
        SCNTransaction.commit()
    }

    // MARK: - Lighting

    private func applySceneStyle(animated: Bool = false) {
        let changes = {
            self.scene.background.contents = self.materials.background
            self.scene.fogStartDistance = self.materials.fog.startDistance
            self.scene.fogEndDistance = self.materials.fog.endDistance
            self.scene.fogDensityExponent = self.materials.fog.densityExponent
            self.scene.fogColor = self.materials.background
            self.scene.lightingEnvironment.contents = self.materials.environment
            self.scene.lightingEnvironment.intensity = self.materials.lighting.environmentIntensity
            self.setupLightingIfNeeded(self.materials.lighting)
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

    private func setupLightingIfNeeded(_ lighting: SquartSceneLighting) {
        upsertLightNode(named: NodeName.ambientLight) { node in
            let ambientLight = node.light ?? SCNLight()
            node.light = ambientLight

            ambientLight.type = .ambient
            ambientLight.intensity = lighting.ambientIntensity
            ambientLight.temperature = lighting.ambientTemperature
        }

        upsertLightNode(named: NodeName.keyLight) { node in
            let keyLight = node.light ?? SCNLight()
            node.light = keyLight

            keyLight.type = .area
            keyLight.intensity = lighting.keyIntensity
            keyLight.temperature = lighting.keyTemperature
            keyLight.areaType = .rectangle
            keyLight.areaExtents = simd_float3(18, 18, 1)
            keyLight.castsShadow = true
            keyLight.shadowMode = .deferred
            keyLight.shadowRadius = 18
            keyLight.shadowSampleCount = 24
            keyLight.shadowColor = PlatformColor.black.withAlphaComponent(lighting.shadowOpacity)

            node.position = SCNVector3(0, 8.5, 0)
            node.look(at: SCNVector3(0, 0, 0))
        }

        upsertLightNode(named: NodeName.fillLight) { node in
            let fillLight = node.light ?? SCNLight()
            node.light = fillLight

            fillLight.type = .omni
            fillLight.intensity = lighting.fillIntensity
            fillLight.temperature = lighting.fillTemperature

            node.position = SCNVector3(-4.8, 4.6, -4.8)
        }

        upsertLightNode(named: NodeName.rimLight) { node in
            let rimLight = node.light ?? SCNLight()
            node.light = rimLight

            rimLight.type = .omni
            rimLight.intensity = lighting.rimIntensity
            rimLight.temperature = lighting.rimTemperature

            node.position = SCNVector3(4.8, 4.6, 4.8)
        }
    }

    private func upsertLightNode(named name: String, configure: (SCNNode) -> Void) {
        let node = scene.rootNode.childNode(withName: name, recursively: false) ?? SCNNode()
        node.name = name
        configure(node)

        if node.parent == nil {
            scene.rootNode.addChildNode(node)
        }
    }

    private func validateStaticSceneIntegrity() {
        #if DEBUG
        let staticNodeNames = [
            NodeName.ambientLight,
            NodeName.keyLight,
            NodeName.fillLight,
            NodeName.rimLight,
            NodeName.boardRoot,
            CameraController.cameraNodeName
        ]

        for name in staticNodeNames {
            let count = scene.rootNode.childNodes.filter { $0.name == name }.count
            assert(count == 1, "Expected one SceneKit node named \(name), found \(count).")
        }

        assert(boardRootNode.childNodes.count <= 1, "Board root should contain a single rebuilt board content node.")
        #endif
    }

    private func planarBounds(for boardNode: SCNNode) -> CGSize {
        let bounds = boardNode.boundingBox
        let width = CGFloat(bounds.max.x - bounds.min.x)
        let depth = CGFloat(bounds.max.z - bounds.min.z)
        return CGSize(width: max(width, 0), height: max(depth, 0))
    }

    private func applyPendingOrDefaultFitIfNeeded() {
        guard
            Self.isUsableViewport(lastViewportSize),
            boardPlanarSize.width > 0, boardPlanarSize.height > 0
        else {
            return
        }

        if pendingForcedFit {
            _ = cameraController.configureDefaultFit(
                planarBoardSize: boardPlanarSize,
                viewportSize: lastViewportSize,
                applyZoom: false
            )
            cameraController.resetToDefaultFit()
            #if DEBUG
            print("[Squart3D] forceFit applied viewport=\(Int(lastViewportSize.width))x\(Int(lastViewportSize.height)) board=\(String(format: "%.2f", boardPlanarSize.width))x\(String(format: "%.2f", boardPlanarSize.height))")
            #endif
            pendingForcedFit = false
            pendingAutoFit = false
            return
        }

        if pendingAutoFit {
            if cameraController.configureDefaultFit(
                planarBoardSize: boardPlanarSize,
                viewportSize: lastViewportSize,
                applyZoom: true
            ) {
                #if DEBUG
                print("[Squart3D] autoFit applied viewport=\(Int(lastViewportSize.width))x\(Int(lastViewportSize.height)) board=\(String(format: "%.2f", boardPlanarSize.width))x\(String(format: "%.2f", boardPlanarSize.height))")
                #endif
                pendingAutoFit = false
            }
        } else {
            _ = cameraController.configureDefaultFit(
                planarBoardSize: boardPlanarSize,
                viewportSize: lastViewportSize,
                applyZoom: false
            )
        }
    }

    static func isUsableViewport(_ size: CGSize) -> Bool {
        guard size.width.isFinite, size.height.isFinite else {
            return false
        }
        guard !size.width.isNaN, !size.height.isNaN else {
            return false
        }
        return size.width >= minimumUsableViewportSide && size.height >= minimumUsableViewportSide
    }
}

private struct LayoutSignature: Equatable {
    let rows: Int
    let columns: Int
    let outsideCount: Int

    init(board: SquartBoard) {
        rows = board.rows
        columns = board.columns
        var count = 0
        for row in 0..<board.rows {
            for column in 0..<board.columns {
                if board.cellState(at: BoardPosition(row: row, column: column)) == .outside {
                    count += 1
                }
            }
        }
        outsideCount = count
    }
}
