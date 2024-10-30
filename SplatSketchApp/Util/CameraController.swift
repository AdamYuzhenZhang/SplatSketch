//
//  CameraController.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/23/24.
//

import Foundation
import simd

class CameraController: ObservableObject {
    @Published var position: SIMD3<Float> = SIMD3(0, 0, -3)
    @Published var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var zoom: Float = 1.0

    func pan(deltaX: Float, deltaY: Float) {
        position.x += deltaX * 0.005
        position.y -= deltaY * 0.005
    }

    func zoom(delta: Float) {
        zoom *= delta
        zoom = max(0.1, min(zoom, 10.0))
    }

    func rotate(delta: Float) {
        rotation.y += delta
    }
}
