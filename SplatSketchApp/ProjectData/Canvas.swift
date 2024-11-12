//
//  Canvas.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation
import PencilKit
import simd

public class Canvas {
    let name: String
    var drawing = PKDrawing()
    
    
    var position: SIMD3<Float>
    var orientation: simd_quatf
    var width: Float
    var height: Float
    var textureURL: URL
    // var texture: MTLTexture
    var cameraData: CameraData  // Camera information when canvas first created
    
    init (name: String, camera: Camera, textureURL: URL) {
        self.name = name
        // set up canvas transforms with current camera
        let forward = camera.forwardVector()
        let distance: Float = 2
        self.position = camera.position + forward * distance
        //let viewRotationMatrix = camera.viewMatrix().rotationMatrix()
        //let invertedRotationMatrix = simd_inverse(viewRotationMatrix)
        //self.orientation = simd_quatf(invertedRotationMatrix)
        let toCamera = simd_normalize(camera.position - self.position)
        let worldUp = SIMD3<Float>(0, 1, 0)
        let right = simd_normalize(simd_cross(toCamera, worldUp))
        let up = simd_cross(right, toCamera)
        let rotationMatrix = float3x3(columns: (right, up, -toCamera))
        self.orientation = simd_quaternion(rotationMatrix)
        //let canvasForward = SIMD3<Float>(0, 0, -1)
        //self.orientation = simd_quaternion(canvasForward, toCamera)
        
        // calculate the size
        self.height = 2 * distance * tan(camera.fovy / 2) // 2
        self.width = self.height * camera.aspectRatio // 3
       
        
        self.cameraData = CameraData(camera: camera)
        
        self.textureURL = textureURL
    }
    
}
