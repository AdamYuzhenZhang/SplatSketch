//
//  CameraData.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation

struct CameraData: Codable {
    let position: SIMD3<Float>
    let rotation: SIMD3<Float>
    let zoom: Float
    
    init(camera: Camera) {
        self.position = camera.position
        self.rotation = camera.rotation
        self.zoom = camera.zoom
    }
}
