import SceneKit

final class SquartSceneController {
    let scene = SCNScene()

    private let cameraController: CameraController
    private let boardRootNode = SCNNode()
    private var lastBoard: SquartBoard?
    private var lastPreviewPositions: Set<BoardPosition> = []
    private var lastMoveAnimationToken = 0

    init() {
        self.cameraController = CameraController(scene: scene)
        scene.background.contents = ScenePalette.background
        scene.rootNode.addChildNode(boardRootNode)
        scene.fogStartDistance = 24
        scene.fogEndDistance = 42
        scene.fogDensityExponent = 0.55
        scene.fogColor = ScenePalette.background
        addLighting()
    }

    func update(
        board: SquartBoard,
        previewPositions: Set<BoardPosition>,
        lastMovePositions: Set<BoardPosition>,
        moveAnimationToken: Int
    ) {
        guard
            board != lastBoard ||
                previewPositions != lastPreviewPositions ||
                moveAnimationToken != lastMoveAnimationToken
        else {
            return
        }

        let shouldAnimateMove = moveAnimationToken != lastMoveAnimationToken && !lastMovePositions.isEmpty
        lastBoard = board
        lastPreviewPositions = previewPositions
        lastMoveAnimationToken = moveAnimationToken
        boardRootNode.childNodes.forEach { $0.removeFromParentNode() }
        boardRootNode.addChildNode(
            BoardNodeFactory.makeBoardNode(
                from: board,
                previewPositions: previewPositions
            )
        )

        if shouldAnimateMove {
            animateMove(at: lastMovePositions)
        }
    }

    func orbitCamera(deltaX: Float, deltaY: Float) {
        cameraController.orbit(deltaX: deltaX, deltaY: deltaY)
    }

    func zoomCamera(by scale: Float) {
        cameraController.zoom(by: scale)
    }

    func resetCamera() {
        cameraController.reset()
    }

    private func animateMove(at positions: Set<BoardPosition>) {
        for position in positions {
            guard let tileNode = BoardNodeFactory.tileNode(in: boardRootNode, at: position) else {
                continue
            }

            let dominoNodes = tileNode.childNodes.filter { $0.name == BoardNodeFactory.dominoNodeName }

            for dominoNode in dominoNodes {
                let finalPosition = dominoNode.position
                dominoNode.position = SCNVector3(finalPosition.x, finalPosition.y + 0.18, finalPosition.z)
                dominoNode.scale = SCNVector3(0.94, 0.82, 0.94)

                let settle = SCNAction.group([
                    .move(to: finalPosition, duration: 0.24),
                    .scale(to: 1.0, duration: 0.24)
                ])
                settle.timingMode = .easeOut
                dominoNode.runAction(settle)
            }
        }
    }

    private func addLighting() {
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 130
        ambientLight.temperature = 4_200

        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        let keyLight = SCNLight()
        keyLight.type = .area
        keyLight.intensity = 980
        keyLight.temperature = 3_750
        keyLight.areaType = .rectangle
        keyLight.areaExtents = simd_float3(9, 7, 1)
        keyLight.castsShadow = true
        keyLight.shadowMode = .deferred
        keyLight.shadowRadius = 8
        keyLight.shadowSampleCount = 24
        keyLight.shadowColor = PlatformColor.black.withAlphaComponent(0.36)

        let keyNode = SCNNode()
        keyNode.light = keyLight
        keyNode.position = SCNVector3(-4.8, 8.6, 6.2)
        keyNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(keyNode)

        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 105
        fillLight.temperature = 4_800

        let fillNode = SCNNode()
        fillNode.light = fillLight
        fillNode.position = SCNVector3(4.5, 4.0, -4.0)
        scene.rootNode.addChildNode(fillNode)

        let rimLight = SCNLight()
        rimLight.type = .directional
        rimLight.intensity = 120
        rimLight.temperature = 5_600

        let rimNode = SCNNode()
        rimNode.light = rimLight
        rimNode.position = SCNVector3(5.5, 5.8, 7.0)
        rimNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(rimNode)

        scene.lightingEnvironment.contents = ScenePalette.environment
        scene.lightingEnvironment.intensity = 0.16
    }
}
