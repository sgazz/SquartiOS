import SwiftUI
import SceneKit
import UIKit

struct SquartSceneView: UIViewRepresentable {
    let board: SquartBoard
    let previewPositions: Set<BoardPosition>
    let aiPreviewPositions: Set<BoardPosition>
    let lastMovePositions: Set<BoardPosition>
    let moveAnimationToken: Int
    let resetCameraToken: Int
    let onTileTapped: (BoardPosition) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            resetCameraToken: resetCameraToken,
            onTileTapped: onTileTapped
        )
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = context.coordinator.controller.scene
        sceneView.backgroundColor = .clear
        sceneView.antialiasingMode = .multisampling4X
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.isJitteringEnabled = false
        context.coordinator.installGestures(on: sceneView)
        context.coordinator.controller.update(
            board: board,
            previewPositions: previewPositions,
            aiPreviewPositions: aiPreviewPositions,
            lastMovePositions: lastMovePositions,
            moveAnimationToken: moveAnimationToken,
            viewportSize: sceneView.bounds.size
        )
        return sceneView
    }

    func updateUIView(_ sceneView: SCNView, context: Context) {
        context.coordinator.onTileTapped = onTileTapped
        context.coordinator.resetCameraIfNeeded(resetCameraToken)
        context.coordinator.controller.update(
            board: board,
            previewPositions: previewPositions,
            aiPreviewPositions: aiPreviewPositions,
            lastMovePositions: lastMovePositions,
            moveAnimationToken: moveAnimationToken,
            viewportSize: sceneView.bounds.size
        )
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let controller = SquartSceneController()
        var onTileTapped: (BoardPosition) -> Void
        private var lastResetCameraToken: Int

        init(
            resetCameraToken: Int,
            onTileTapped: @escaping (BoardPosition) -> Void
        ) {
            self.lastResetCameraToken = resetCameraToken
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

        func resetCameraIfNeeded(_ token: Int) {
            guard token != lastResetCameraToken else {
                return
            }

            lastResetCameraToken = token
            controller.resetCamera()
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
