import SceneKit

final class CameraController {
    private enum Defaults {
        static let radius: Float = 14.8
        static let azimuth: Float = 0.0
        static let elevation: Float = 0.74

        static let minElevation: Float = 0.46
        static let maxElevation: Float = 1.20
        static let minOrthographicScale: Double = 4.8
        static let maxOrthographicScale: Double = 26.0
    }

    private let cameraNode = SCNNode()
    private var azimuth = Defaults.azimuth
    private var elevation = Defaults.elevation
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
        camera.wantsHDR = true
        camera.bloomIntensity = 0.08
        camera.bloomThreshold = 0.82
        camera.bloomBlurRadius = 5

        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
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

    func orbit(deltaX: Float, deltaY: Float) {
        azimuth -= deltaX * 0.0042
        elevation += deltaY * 0.0034
        elevation = elevation.clamped(to: Defaults.minElevation...Defaults.maxElevation)
        applyCameraPosition()
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
        elevation = Defaults.elevation
        orthographicScale = defaultOrthographicScale
        cameraNode.camera?.orthographicScale = orthographicScale
        applyCameraPosition()
    }

    private func applyCameraPosition() {
        let horizontalRadius = Defaults.radius * cos(elevation)
        let x = horizontalRadius * sin(azimuth)
        let y = Defaults.radius * sin(elevation)
        let z = horizontalRadius * cos(azimuth)

        cameraNode.position = SCNVector3(x, y, z)
        cameraNode.look(at: SCNVector3(0, 0, 0))
    }

    private static func defaultScale(rows: Int, columns: Int, viewportAspect: Double) -> Double {
        let desiredFill = 0.82
        let boardWidth = Double(columns) * 0.96 + 0.78
        let boardHeight = Double(rows) * 0.96 + 0.78
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
