import SceneKit

final class CameraController {
    static let cameraNodeName = "squart.camera"
    // Squart SceneKit convention:
    // - board plane is X/Z
    // - +Y is vertical/up
    // Camera stays fixed in top-down view; board rotation is handled by SquartSceneController.

    private enum Defaults {
        static let height: Float = 14.8
        static let topDownPitch = -Float.pi / 2
        static let targetFill: Double = 0.86
        static let minimumUsableViewportSide: CGFloat = 100

        static let minOrthographicScale: Double = 4.2
        static let maxOrthographicScale: Double = 26.0
    }

    private let cameraNode = SCNNode()
    private var defaultOrthographicScale = 10.2
    private var orthographicScale = 10.2
    private var fitSignature: FitSignature?

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
    func configureDefaultFit(
        planarBoardSize: CGSize,
        viewportSize: CGSize,
        applyZoom: Bool
    ) -> Bool {
        guard Self.isUsableViewport(viewportSize) else {
            return false
        }
        guard planarBoardSize.width > 0, planarBoardSize.height > 0 else {
            return false
        }

        let aspect = Self.viewportAspect(for: viewportSize)
        let signature = FitSignature(planarSize: planarBoardSize, viewportAspect: aspect)
        guard signature != fitSignature else {
            return false
        }

        fitSignature = signature
        defaultOrthographicScale = Self.defaultScale(
            planarBoardSize: planarBoardSize,
            viewportAspect: aspect
        )

        if applyZoom {
            orthographicScale = defaultOrthographicScale
            cameraNode.camera?.orthographicScale = orthographicScale
            applyCameraPosition()
        }

        return true
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

    func resetToDefaultFit() {
        orthographicScale = defaultOrthographicScale
        cameraNode.camera?.orthographicScale = orthographicScale
        applyCameraPosition(animated: true)
    }

    private func applyCameraPosition(animated: Bool = false) {
        let apply = {
            // Deterministic top-down transform:
            // - board plane: X/Z
            // - vertical axis: +Y
            // - camera looks straight down (-Y) with zero roll
            self.cameraNode.position = SCNVector3(0, Defaults.height, 0)
            self.cameraNode.eulerAngles = SCNVector3(Defaults.topDownPitch, 0, 0)
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

    private static func defaultScale(planarBoardSize: CGSize, viewportAspect: Double) -> Double {
        // orthographicScale is measured on the projection axis (vertical by default),
        // so visible world height is approximately orthographicScale * 2.
        let halfBoardWidth = Double(planarBoardSize.width) / 2
        let halfBoardHeight = Double(planarBoardSize.height) / 2
        let scaleForWidth = halfBoardWidth / (Defaults.targetFill * viewportAspect)
        let scaleForHeight = halfBoardHeight / Defaults.targetFill

        return max(scaleForWidth, scaleForHeight)
            .clamped(to: Defaults.minOrthographicScale...Defaults.maxOrthographicScale)
    }

    private static func viewportAspect(for size: CGSize) -> Double {
        guard Self.isUsableViewport(size) else {
            return 1
        }

        return max(0.35, min(2.4, Double(size.width / size.height)))
    }

    private static func isUsableViewport(_ size: CGSize) -> Bool {
        guard size.width.isFinite, size.height.isFinite else {
            return false
        }
        guard !size.width.isNaN, !size.height.isNaN else {
            return false
        }
        return size.width >= Defaults.minimumUsableViewportSide &&
            size.height >= Defaults.minimumUsableViewportSide
    }
}

private struct FitSignature: Equatable {
    let widthBucket: Int
    let heightBucket: Int
    let aspectBucket: Int

    init(planarSize: CGSize, viewportAspect: Double) {
        widthBucket = Int((Double(planarSize.width) * 100).rounded())
        heightBucket = Int((Double(planarSize.height) * 100).rounded())
        aspectBucket = Int((viewportAspect * 100).rounded())
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
