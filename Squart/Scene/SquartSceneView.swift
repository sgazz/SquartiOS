import SwiftUI
import SceneKit
import UIKit

private final class LayoutAwareSceneView: SCNView {
    var onLayoutChange: ((CGSize) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutChange?(bounds.size)
    }
}

struct SquartSceneView: UIViewRepresentable {
    @AppStorage(SquartThemeStore.selectedThemeIDKey) private var selectedThemeID = SquartVisualTheme.defaultTheme.id

    let board: SquartBoard
    let viewportHint: CGSize
    let previewPositions: Set<BoardPosition>
    let aiPreviewPositions: Set<BoardPosition>
    let lastMovePositions: Set<BoardPosition>
    let moveAnimationToken: Int
    let resetCameraToken: Int
    let forceFitToken: Int
    let rotateLeftToken: Int
    let rotateRightToken: Int
    let onTileTapped: (BoardPosition) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            resetCameraToken: resetCameraToken,
            forceFitToken: forceFitToken,
            rotateLeftToken: rotateLeftToken,
            rotateRightToken: rotateRightToken,
            onTileTapped: onTileTapped
        )
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = LayoutAwareSceneView()
        sceneView.scene = context.coordinator.controller.scene
        sceneView.backgroundColor = .clear
        sceneView.antialiasingMode = .multisampling4X
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.isJitteringEnabled = false
        sceneView.onLayoutChange = { [weak coordinator = context.coordinator] size in
            coordinator?.controller.viewportDidChange(size)
        }
        context.coordinator.installGestures(on: sceneView)
        context.coordinator.controller.update(
            board: board,
            previewPositions: previewPositions,
            aiPreviewPositions: aiPreviewPositions,
            lastMovePositions: lastMovePositions,
            moveAnimationToken: moveAnimationToken,
            viewportSize: resolvedViewportSize(for: sceneView),
            visualTheme: visualTheme
        )
        return sceneView
    }

    func updateUIView(_ sceneView: SCNView, context: Context) {
        context.coordinator.onTileTapped = onTileTapped
        context.coordinator.resetCameraIfNeeded(resetCameraToken, sceneView: sceneView)
        context.coordinator.forceFitIfNeeded(forceFitToken, sceneView: sceneView)
        context.coordinator.rotateLeftIfNeeded(rotateLeftToken)
        context.coordinator.rotateRightIfNeeded(rotateRightToken)
        context.coordinator.controller.update(
            board: board,
            previewPositions: previewPositions,
            aiPreviewPositions: aiPreviewPositions,
            lastMovePositions: lastMovePositions,
            moveAnimationToken: moveAnimationToken,
            viewportSize: resolvedViewportSize(for: sceneView),
            visualTheme: visualTheme
        )
    }

    private var visualTheme: SquartVisualTheme {
        SquartVisualTheme(rawValue: selectedThemeID) ?? .defaultTheme
    }

    private func resolvedViewportSize(for sceneView: SCNView) -> CGSize {
        let bounds = sceneView.bounds.size
        if SquartSceneController.isUsableViewport(bounds) {
            return bounds
        }
        return viewportHint
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let controller = SquartSceneController()
        var onTileTapped: (BoardPosition) -> Void
        private var lastResetCameraToken: Int
        private var lastForceFitToken: Int
        private var lastRotateLeftToken: Int
        private var lastRotateRightToken: Int

        init(
            resetCameraToken: Int,
            forceFitToken: Int,
            rotateLeftToken: Int,
            rotateRightToken: Int,
            onTileTapped: @escaping (BoardPosition) -> Void
        ) {
            self.lastResetCameraToken = resetCameraToken
            self.lastForceFitToken = forceFitToken
            self.lastRotateLeftToken = rotateLeftToken
            self.lastRotateRightToken = rotateRightToken
            self.onTileTapped = onTileTapped
        }

        func installGestures(on sceneView: SCNView) {
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap(_:))
            )

            let panGesture = UIPanGestureRecognizer(
                target: self,
                action: #selector(handlePan(_:))
            )
            panGesture.maximumNumberOfTouches = 1

            let pinchGesture = UIPinchGestureRecognizer(
                target: self,
                action: #selector(handlePinch(_:))
            )

            [tapGesture, panGesture, pinchGesture].forEach { gesture in
                gesture.delegate = self
                gesture.cancelsTouchesInView = false
                sceneView.addGestureRecognizer(gesture)
            }
        }

        func resetCameraIfNeeded(_ token: Int, sceneView: SCNView) {
            guard token != lastResetCameraToken else {
                return
            }

            lastResetCameraToken = token
            controller.resetCamera(viewportSize: sceneView.bounds.size)
        }

        func rotateLeftIfNeeded(_ token: Int) {
            guard token != lastRotateLeftToken else {
                return
            }

            lastRotateLeftToken = token
            controller.rotateCameraLeft90()
        }

        func forceFitIfNeeded(_ token: Int, sceneView: SCNView) {
            guard token != lastForceFitToken else {
                return
            }

            lastForceFitToken = token
            controller.forceFitToViewport(viewportSize: sceneView.bounds.size, reason: "enter3D")
        }

        func rotateRightIfNeeded(_ token: Int) {
            guard token != lastRotateRightToken else {
                return
            }

            lastRotateRightToken = token
            controller.rotateCameraRight90()
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else {
                return
            }

            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)

            for result in hitResults {
                if let position = BoardNodeFactory.position(for: result.node) {
                    onTileTapped(position)
                    return
                }
            }
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = gesture.view else {
                return
            }

            let translation = gesture.translation(in: sceneView)
            controller.orbitCamera(deltaX: Float(translation.x))
            gesture.setTranslation(.zero, in: sceneView)
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            controller.zoomCamera(by: Float(gesture.scale))
            gesture.scale = 1
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            gestureRecognizer is UIPinchGestureRecognizer ||
                otherGestureRecognizer is UIPinchGestureRecognizer
        }
    }
}
