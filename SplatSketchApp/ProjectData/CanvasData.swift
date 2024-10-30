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
    
    init(name: String, drawing: PKDrawing, camera: Camera) {
        self.name = name
        self.drawingData = drawing.dataRepresentation()
        self.cameraData = CameraData(camera: camera)
    }
    
}
