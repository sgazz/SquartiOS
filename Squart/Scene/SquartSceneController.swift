import SceneKit

final class SquartSceneController {
    let scene = SCNScene()

    private enum NodeName {
        static let boardRoot = "squart.boardRoot"
        static let ambientLight = "squart.light.ambient"
        static let keyLight = "squart.light.key"
        static let fillLight = "squart.light.fill"
        static let rimLight = "squart.light.rim"
    }

    private let cameraController: CameraController
    private let boardRootNode = SCNNode()
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

        let didUpdateCamera = cameraController.configureForBoard(
            rows: board.rows,
            columns: board.columns,
            viewportSize: viewportSize
        )
        let needsBoardRefresh =
            board != lastBoard ||
            previewPositions != lastPreviewPositions ||
            aiPreviewPositions != lastAIPreviewPositions ||
            moveAnimationToken != lastMoveAnimationToken

        guard needsBoardRefresh || didUpdateCamera else {
            return
        }

        guard needsBoardRefresh else {
            return
        }

        let shouldAnimateMove = moveAnimationToken != lastMoveAnimationToken && !lastMovePositions.isEmpty
        lastBoard = board
        lastPreviewPositions = previewPositions
        lastAIPreviewPositions = aiPreviewPositions
        lastMoveAnimationToken = moveAnimationToken
        boardRootNode.childNodes.forEach { $0.removeFromParentNode() }
        boardRootNode.addChildNode(
            BoardNodeFactory.makeBoardNode(
                from: board,
                previewPositions: previewPositions,
                aiPreviewPositions: aiPreviewPositions,
                materials: materials
            )
        )

        if shouldAnimateMove {
            animateMove(at: lastMovePositions)
        }

        validateStaticSceneIntegrity()
    }

    // MARK: - Camera Controls

    func orbitCamera(deltaX: Float) {
        cameraController.orbitHorizontally(deltaX: deltaX)
    }

    func zoomCamera(by scale: Float) {
        cameraController.zoom(by: scale)
    }

    func resetCamera() {
        cameraController.reset()
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
}
