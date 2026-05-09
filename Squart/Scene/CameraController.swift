import SceneKit

final class CameraController {
    private enum Defaults {
        static let radius: Float = 14.8
        static let azimuth: Float = 0.62
        static let elevation: Float = 0.68
        static let orthographicScale: Double = 12.4

        static let minElevation: Float = 0.42
        static let maxElevation: Float = 1.18
        static let minOrthographicScale: Double = 7.8
        static let maxOrthographicScale: Double = 17.0
    }

    private let cameraNode = SCNNode()
    private var azimuth = Defaults.azimuth
    private var elevation = Defaults.elevation
    private var orthographicScale = Defaults.orthographicScale

    init(scene: SCNScene) {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = Defaults.orthographicScale
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
        orthographicScale = Defaults.orthographicScale
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
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
