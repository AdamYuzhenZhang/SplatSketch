//
//  AppManager+Camera.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

import Foundation
import simd

extension AppManager {
    func createNewCamera() {
        self.activeCamera = Camera()
    }
    
    func getCameraViewMatrix() -> matrix_float4x4 {
        if let camera = self.activeCamera {
            return camera.viewMatrix()
        }
        return matrix_float4x4()
    }
}
