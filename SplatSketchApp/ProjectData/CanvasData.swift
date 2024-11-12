//
//  CanvasData.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation
import PencilKit

struct CanvasData: Codable {
    let name: String
    let drawingData: Data
    let cameraData: CameraData
    
    init(canvas: Canvas) {
        self.name = canvas.name
        self.cameraData = canvas.cameraData
        self.drawingData = canvas.drawing.dataRepresentation()
    }
}

struct CameraData: Codable {
    let position: SIMD3<Float>
    let lookAtTarget: SIMD3<Float>
    let rotation: SIMD3<Float>
    let fovy: Float
    let aspectRatio: Float
    
    init(camera: Camera) {
        self.position = camera.position
        self.lookAtTarget = camera.lookAtTarget
        self.rotation = camera.rotation
        self.fovy = camera.fovy
        self.aspectRatio = camera.aspectRatio
    }
}
