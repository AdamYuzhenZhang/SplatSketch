import Foundation
import simd
import Combine

class Camera: ObservableObject {
    // Position and orientation variables
    @Published var position: SIMD3<Float> = SIMD3(0, 0, -8)
    @Published var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var zoom: Float = 1.0

    func pan(deltaX: Float, deltaY: Float) {
        // Adjust the camera position based on pan
        position.x += deltaX * 0.01
        position.y -= deltaY * 0.01
    }

    func zoom(delta: Float) {
        // Adjust the zoom level
        let zoomAmount = delta
            let forward = forwardVector()
            position += forward * zoomAmount
        //print(delta)
    }

    func rotate(deltaX: Float, deltaY: Float) {
        // Adjust the rotation around the Y-axis
        rotation.y -= deltaX * 0.005
        rotation.x += deltaY * 0.005
    }
    
    func forwardVector() -> SIMD3<Float> {
        // Start with the forward direction in camera space (negative Z axis)
        var forward = SIMD3<Float>(0, 0, -1)
        
        // Create rotation matrices
        let rotationXMatrix = matrix_float4x4(rotationX: rotation.x)
        let rotationYMatrix = matrix_float4x4(rotationY: rotation.y)
        
        // Apply rotations
        let rotationMatrix = rotationYMatrix * rotationXMatrix
        let transformedForward = rotationMatrix * SIMD4(forward, 0)
        forward = SIMD3<Float>(transformedForward.x, transformedForward.y, transformedForward.z)

        
        // Normalize the vector
        return simd_normalize(forward)
    }

    func viewMatrix() -> matrix_float4x4 {
        var matrix = matrix_identity_float4x4
        // Apply scaling (zoom)
        //matrix = matrix_multiply(matrix, matrix_float4x4(scale: SIMD3(repeating: zoom)))
        // Apply rotation around Y and X axes
        matrix = matrix_multiply(matrix, matrix_float4x4(rotationY: rotation.y))
        matrix = matrix_multiply(matrix, matrix_float4x4(rotationX: rotation.x))
        // Apply translation
        matrix = matrix_multiply(matrix, matrix_float4x4(translation: position))
        return matrix
    }
}

