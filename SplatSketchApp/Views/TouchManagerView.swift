//
//  TouchManagerView.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/23/24.
//
/*
import UIKit

class TouchManagerView: UIView {
    var metalView: MetalKitSceneView
    var canvasView: CanvasView
    
    init(frame: CGRect, metalView: MetalKitSceneView, canvasView: CanvasView) {
        self.metalView = metalView
        self.canvasView = canvasView
        super.init(frame: frame)
        self.isUserInteractionEnabled = true

        self.addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    private func addGestureRecognizers() {
            // Pan Gesture
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)

            // Pinch Gesture
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
            pinchGesture.delegate = self
            self.addGestureRecognizer(pinchGesture)

            // Rotation Gesture
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
            rotationGesture.delegate = self
            self.addGestureRecognizer(rotationGesture)
        }
    
}


extension TouchManagerView: UIGestureRecognizerDelegate {

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touch = gesture.touches(for: self)?.first
        if touch?.type == .pencil {
            // Forward the gesture to CanvasView (for drawing)
            canvasView.handlePanGesture(gesture)
        } else {
            // Forward the gesture to MetalKitSceneView (for model manipulation)
            metalView.handlePanGesture(gesture)
        }
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        // Similar logic as pan gesture
        metalView.handlePinchGesture(gesture)
    }

    @objc func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        // Similar logic as pan gesture
        metalView.handleRotationGesture(gesture)
    }

    // Allow simultaneous gesture recognition
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
*/
