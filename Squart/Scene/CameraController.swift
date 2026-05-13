import SceneKit

final class CameraController {
    static let cameraNodeName = "squart.camera"

    private enum Defaults {
        static let radius: Float = 14.8
        static let azimuth: Float = 0.0
        static let elevation: Float = 1.47

        static let minOrthographicScale: Double = 4.2
        static let maxOrthographicScale: Double = 26.0
    }

    private let cameraNode = SCNNode()
    private var azimuth = Defaults.azimuth
    private var defaultOrthographicScale = 10.2
    private var orthographicScale = 10.2
    private var boardSize: (rows: Int, columns: Int)?
    private var viewportAspect: Double = 1

    init(scene: SCNScene) {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = orthographicScale
        camera.zNear = 0.1
        camera.zFar = 100
        camera.wantsHDR = false
        camera.bloomIntensity = 0
        camera.bloomThreshold = 1
        camera.bloomBlurRadius = 0

        cameraNode.name = Self.cameraNodeName
        cameraNode.camera = camera
        if scene.rootNode.childNode(withName: Self.cameraNodeName, recursively: false) == nil {
            scene.rootNode.addChildNode(cameraNode)
        }
        applyCameraPosition()
    }

    @discardableResult
    func configureForBoard(rows: Int, columns: Int, viewportSize: CGSize) -> Bool {
        let nextViewportAspect = Self.viewportAspect(for: viewportSize)

        guard
            boardSize?.rows != rows ||
                boardSize?.columns != columns ||
                abs(viewportAspect - nextViewportAspect) > 0.02
        else {
            return false
        }

        boardSize = (rows, columns)
        viewportAspect = nextViewportAspect
        defaultOrthographicScale = Self.defaultScale(
            rows: rows,
            columns: columns,
            viewportAspect: nextViewportAspect
        )
        orthographicScale = defaultOrthographicScale
        cameraNode.camera?.orthographicScale = orthographicScale
        applyCameraPosition()
        return true
    }

    func orbitHorizontally(deltaX: Float) {
        azimuth -= deltaX * 0.0018
        azimuth.formTruncatingRemainder(dividingBy: Float.pi * 2)
        applyCameraPosition()
    }

    func rotateByQuarterTurns(_ quarterTurns: Int) {
        guard quarterTurns != 0 else {
            return
        }

        let step = Float.pi / 2
        azimuth += step * Float(quarterTurns)
        azimuth.formTruncatingRemainder(dividingBy: Float.pi * 2)
        applyCameraPosition(animated: true)
    }

    func zoom(by scale: Float) {
        guard scale > 0 else {
            return
        }

        orthographicScale /= Double(scale)
        orthographicScale = orthographicScale.clamped(
            to: Defaults.minOrthographicScale...Defaults.maxOrthographicScale
        )
        cameraNode.camera?.orthographicScale = orthographicScale
    }

    func reset() {
        azimuth = Defaults.azimuth
        orthographicScale = defaultOrthographicScale
        cameraNode.camera?.orthographicScale = orthographicScale
        applyCameraPosition(animated: true)
    }

    private func applyCameraPosition(animated: Bool = false) {
        let horizontalRadius = Defaults.radius * cos(Defaults.elevation)
        let x = horizontalRadius * sin(azimuth)
        let y = Defaults.radius * sin(Defaults.elevation)
        let z = horizontalRadius * cos(azimuth)

        let apply = {
            self.cameraNode.position = SCNVector3(x, y, z)
            self.cameraNode.look(at: SCNVector3(0, 0, 0))
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

    private static func defaultScale(rows: Int, columns: Int, viewportAspect: Double) -> Double {
        let desiredFill = 0.91
        let boardWidth = Double(columns) * 0.96 + 0.44
        let boardHeight = Double(rows) * 0.96 + 0.44
        let scaleForWidth = boardWidth / (desiredFill * viewportAspect)
        let scaleForHeight = boardHeight / desiredFill

        return max(scaleForWidth, scaleForHeight)
            .clamped(to: Defaults.minOrthographicScale...Defaults.maxOrthographicScale)
    }

    private static func viewportAspect(for size: CGSize) -> Double {
        guard size.width > 0, size.height > 0 else {
            return 1
        }

        return max(0.35, min(2.4, Double(size.width / size.height)))
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
